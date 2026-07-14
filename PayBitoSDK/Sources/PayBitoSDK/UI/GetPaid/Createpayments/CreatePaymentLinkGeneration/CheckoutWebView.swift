//
//  CheckoutWebView.swift
//  Trading_Terminal
//

import SwiftUI
import WebKit

struct CheckoutWebView: UIViewRepresentable {
    let url:   URL
    let email: String
    var onLoadingChanged: ((Bool) -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(email: email, onLoadingChanged: onLoadingChanged)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        if !context.coordinator.email.isEmpty {
            let safeEmail = context.coordinator.safeEmail
            let earlyScript = WKUserScript(
                source: "window.__prefillEmail = '\(safeEmail)';",
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
            config.userContentController.addUserScript(earlyScript)
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate {
        let email: String
        var onLoadingChanged: ((Bool) -> Void)?
        weak var webView: WKWebView?
        private var timer: Timer?
        private var attempts = 0

        var safeEmail: String {
            email
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "'",  with: "\\'")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
        }

        init(email: String, onLoadingChanged: ((Bool) -> Void)? = nil) {
            self.email = email
            self.onLoadingChanged = onLoadingChanged
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async { self.onLoadingChanged?(true) }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async { self.onLoadingChanged?(false) }
            guard !email.isEmpty else { return }
            timer?.invalidate()
            attempts = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.startRetryTimer()
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.onLoadingChanged?(false) }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.onLoadingChanged?(false) }
        }

        private func startRetryTimer() {
            if let wv = webView { inject(into: wv) { _ in } }

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
                guard let self, let wv = self.webView else { t.invalidate(); return }
                self.attempts += 1
                if self.attempts > 20 { t.invalidate(); return }
                self.inject(into: wv) { found in
                    if found {
                        debugPrint("[CheckoutWebView] ✅ injected on attempt \(self.attempts)")
                        t.invalidate()
                    } else {
                        debugPrint("[CheckoutWebView] ⏳ attempt \(self.attempts) — not ready")
                    }
                }
            }
        }

        private func inject(into webView: WKWebView, completion: @escaping (Bool) -> Void) {
            let safe = safeEmail
            let js = """
            (function() {
                var exchangeName = "\(UserDefaults.standard.string(forKey: "companyName") ?? "Brand")";
                
                if (document.title && document.title.match(/Paybito/i)) {
                    document.title = document.title.replace(/Paybito/gi, exchangeName);
                }
                
                var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
                var node;
                while (node = walker.nextNode()) {
                    if (node.nodeValue && node.nodeValue.match(/Paybito/i)) {
                        node.nodeValue = node.nodeValue.replace(/Paybito/gi, exchangeName);
                    }
                }

                var emailVal = '\(safe)' || window.__prefillEmail || '';
                if (!emailVal) return 'NO_EMAIL';

                var selectors = [
                    'input[type="email"]',
                    'input[name="email"]',
                    'input[name="buyerEmail"]',
                    'input[name="customerEmail"]',
                    'input[id*="email" i]',
                    'input[placeholder*="email" i]',
                    'input[placeholder*="Enter your email" i]',
                    'input[placeholder*="email address" i]',
                    'input[autocomplete="email"]',
                    'input[autocomplete="username"]'
                ];

                var el = null;
                for (var i = 0; i < selectors.length; i++) {
                    var found = document.querySelector(selectors[i]);
                    if (found) { el = found; break; }
                }

                if (!el) {
                    var allInputs = document.querySelectorAll('input');
                    for (var j = 0; j < allInputs.length; j++) {
                        var inp = allInputs[j];
                        var ph = (inp.placeholder || '').toLowerCase();
                        var nm = (inp.name || '').toLowerCase();
                        var id = (inp.id || '').toLowerCase();
                        if (ph.includes('email') || nm.includes('email') || id.includes('email')) {
                            el = inp; break;
                        }
                    }
                }

                if (!el) return 'NOT_FOUND';
                
                if (el.value === emailVal && el.readOnly === true) return 'ALREADY_SET';

                try {
                    var setter = Object.getOwnPropertyDescriptor(
                        window.HTMLInputElement.prototype, 'value'
                    ).set;
                    setter.call(el, emailVal);
                } catch(e) {
                    el.value = emailVal;
                }
                
                el.readOnly = true;
                el.style.pointerEvents = 'none';

                ['input', 'change', 'keydown', 'keypress', 'keyup', 'blur', 'focus'].forEach(function(name) {
                    el.dispatchEvent(new Event(name, { bubbles: true, cancelable: true }));
                });

                el.dispatchEvent(new KeyboardEvent('keyup', {
                    bubbles: true, cancelable: true,
                    key: emailVal.slice(-1),
                    keyCode: emailVal.charCodeAt(emailVal.length - 1)
                }));

                el.focus();
                return 'OK';
            })();
            """

            webView.evaluateJavaScript(js) { result, error in
                let res = result as? String ?? ""
                if let error { debugPrint("[CheckoutWebView] JS error: \(error)") }
                debugPrint("[CheckoutWebView] inject → \(res)")
                completion(res == "OK" || res == "ALREADY_SET")
            }
        }

        deinit { timer?.invalidate() }
    }
}

// MARK: - Full screen sheet wrapper

struct CheckoutSheet: View {
    let checkoutURL: URL
    let email:       String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            // ── Dynamic Header ────────────────────────────────────
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(UserDefaults.standard.string(forKey: "companyName") ?? "Brand")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Color.clear.frame(width: 32, height: 32) // Balance
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .padding(.top, 16)
            .background(Color(red: 0.08, green: 0.09, blue: 0.14).ignoresSafeArea(edges: .top))

            // ── WebView ───────────────────────────────────────────
            ZStack {
                CheckoutWebView(url: checkoutURL, email: email) { loading in
                    isLoading = loading
                }
                
                if isLoading {
                    ZStack {
                        Color(red: 0.08, green: 0.09, blue: 0.14)
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.4)
                            Text("Loading Checkout…")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(red: 0.60, green: 0.65, blue: 0.78))
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: isLoading)
                }
            }
        }
    }
}
