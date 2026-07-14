// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message

//
//import SwiftUI
//import Alamofire
//import CryptoSwift
//
//// MARK: - CaptchaResponse (shared with PuzzleCaptchaVC)
//// If this struct is already defined globally in your project, delete it here.
//// struct CaptchaResponse: Codable { ... }
//
//struct LoginCaptchaView: View {
//
//    // Changed signature: now emits (gRecaptchaResponse, sessionId)
//    var onVerified: (String, String) -> Void
//    var onCancel:   () -> Void
//
//    // ── Captcha data ──────────────────────────────────────────────
//    @State private var baseUIImage:  UIImage?
//    @State private var pieceUIImage: UIImage?
//    @State private var targetX:   CGFloat = 0   // positionX from API (300-px space)
//    @State private var targetY:   CGFloat = 0   // positionY from API (300-px space)
//    @State private var sessionId: String  = ""
//
//    // ── Slider/UI state ───────────────────────────────────────────
//    @State private var sliderValue:  CGFloat = 0    // 0…1
//    @State private var isLoading     = true
//    @State private var verified      = false
//    @State private var shakeOffset:  CGFloat = 0
//    @State private var secondsLeft   = 60
//    @State private var captchaTimer: Timer?
//
//    // ── Constants ─────────────────────────────────────────────────
//    private let pieceW:    CGFloat = 70
//    private let pieceH:    CGFloat = 70
//    private let naturalW:  CGFloat = 300
//    private let naturalH:  CGFloat = 200
//    private let tolerance: CGFloat = 5
//    private let thumbSize: CGFloat = 44
//
//    private let captchaURL = "https://captcha.paybito.com:7443/CaptchaService/captcha/generateCaptcha/200/300/50"
//
//    private let purple     = Color(red: 0.45, green: 0.35, blue: 0.90)
//    private let headerGrad = LinearGradient(
//        colors: [Color(red: 0.50, green: 0.30, blue: 0.95),
//                 Color(red: 0.40, green: 0.25, blue: 0.85)],
//        startPoint: .leading, endPoint: .trailing
//    )
//
//    // MARK: - Body
//
//    var body: some View {
//        VStack(spacing: 0) {
//            headerBar
//            bodySection
//            footerBar
//        }
//        .background(Color(red: 0.08, green: 0.10, blue: 0.16))
//        .cornerRadius(20)
//        .onAppear {
//            fetchCaptcha()
//            startTimer()
//        }
//        .onDisappear {
//            captchaTimer?.invalidate()
//        }
//    }
//
//    // MARK: - Header
//
//    private var headerBar: some View {
//        headerGrad
//            .frame(height: 64)
//            .overlay {
//                HStack(spacing: 10) {
//                    Image(systemName: "checkmark.shield.fill")
//                        .font(.system(size: 22)).foregroundColor(.white)
//                    Text("Security Verification")
//                        .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
//                    Spacer()
//                    Button(action: cancel) {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
//                            .frame(width: 36, height: 36)
//                    }
//                    .buttonStyle(.plain)
//                }
//                .padding(.horizontal, 20)
//            }
//    }
//
//    // MARK: - Body section
//
//    private var bodySection: some View {
//        VStack(spacing: 16) {
//            puzzleArea
//                .padding(.top, 20)
//
//            HStack {
//                Text("Slide to verify")
//                    .font(.system(size: 17, weight: .bold)).foregroundColor(.white)
//                Spacer()
//            }
//            .padding(.horizontal, 20)
//
//            sliderTrack
//                .padding(.horizontal, 20)
//
//            HStack(spacing: 8) {
//                Image(systemName: "info.circle.fill")
//                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.45))
//                Text("Drag the slider to match the puzzle piece")
//                    .font(.system(size: 12)).foregroundColor(.white.opacity(0.55))
//                Spacer()
//            }
//            .padding(.horizontal, 20)
//
//            HStack {
//                Spacer()
//                Text("renew in \(secondsLeft) sec")
//                    .font(.system(size: 13)).foregroundColor(.white.opacity(0.55))
//                Button(action: refreshCaptcha) {
//                    Image(systemName: "arrow.2.circlepath")
//                        .font(.system(size: 16)).foregroundColor(purple)
//                }
//                .buttonStyle(.plain)
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 4)
//        }
//        .background(Color(red: 0.10, green: 0.12, blue: 0.18))
//    }
//
//    // MARK: - Footer
//
//    private var footerBar: some View {
//        HStack(spacing: 8) {
//            Button(action: refreshCaptcha) {
//                Text("Refresh")
//                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
//                    .frame(width: 110, height: 48)
//                    .background(Color(red: 0.40, green: 0.30, blue: 0.85))
//                    .cornerRadius(12)
//            }
//            .buttonStyle(.plain)
//
//            Button(action: cancel) {
//                Text("Cancel")
//                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
//                    .frame(width: 110, height: 48)
//                    .background(Color(red: 0.90, green: 0.38, blue: 0.38))
//                    .cornerRadius(12)
//            }
//            .buttonStyle(.plain)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 72)
//        .background(Color(red: 0.08, green: 0.10, blue: 0.16))
//    }
//
//    // MARK: - Puzzle image area
//
//    private var puzzleArea: some View {
//        GeometryReader { geo in
//            let displayW = geo.size.width
//            let displayH = geo.size.height
//            let scaleX = displayW / naturalW
//            let scaleY = displayH / naturalH
//
//            let pieceDispW = pieceW * scaleX
//            let pieceDispH = pieceH * scaleY
//
//            let pieceDispX = (sliderValue * (naturalW - pieceW)) * scaleX
//            let pieceDispY = targetY * scaleY
//
//            ZStack(alignment: .topLeading) {
//                if isLoading {
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color.white.opacity(0.08))
//                    ProgressView()
//                        .tint(.white)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                } else if let bg = baseUIImage {
//                    // Base image with cutout hole
//                    Image(uiImage: bg)
//                        .resizable()
//                        .frame(width: displayW, height: displayH)
//                        .clipped()
//
//                    // Draggable puzzle piece
//                    if let piece = pieceUIImage {
//                        Image(uiImage: piece)
//                            .resizable()
//                            .frame(width: pieceDispW, height: pieceDispH)
//                            .shadow(color: .white.opacity(0.7), radius: 6, x: 0, y: 0)
//                            .offset(x: pieceDispX + shakeOffset, y: pieceDispY)
//                            .animation(.interactiveSpring(), value: sliderValue)
//                    }
//
//                    // Verified overlay
//                    if verified {
//                        Color.green.opacity(0.25)
//                            .frame(width: displayW, height: displayH)
//                        Image(systemName: "checkmark.circle.fill")
//                            .resizable().scaledToFit()
//                            .frame(width: 60, height: 60)
//                            .foregroundColor(.green)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    }
//                } else {
//                    // Error fallback
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color.white.opacity(0.05))
//                    Text("Tap Refresh to reload")
//                        .font(.system(size: 13)).foregroundColor(.white.opacity(0.55))
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//            }
//        }
//        .frame(height: 170)
//        .cornerRadius(10)
//        .padding(.horizontal, 20)
//    }
//
//    // MARK: - Slider track
//
//    private var sliderTrack: some View {
//        GeometryReader { geo in
//            let trackW = geo.size.width
//            let thumbX = sliderValue * (trackW - thumbSize)
//
//            ZStack(alignment: .leading) {
//                Capsule()
//                    .fill(Color(red: 0.18, green: 0.20, blue: 0.30))
//                    .frame(height: 8)
//                    .padding(.vertical, (thumbSize - 8) / 2)
//
//                Capsule()
//                    .fill(verified ? Color.green : purple)
//                    .frame(width: thumbX + thumbSize / 2, height: 8)
//                    .padding(.vertical, (thumbSize - 8) / 2)
//                    .animation(.interactiveSpring(), value: sliderValue)
//
//                Circle()
//                    .fill(verified ? Color.green : purple)
//                    .frame(width: thumbSize, height: thumbSize)
//                    .overlay {
//                        Image(systemName: verified ? "checkmark" : "chevron.right.2")
//                            .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
//                    }
//                    .shadow(color: .black.opacity(0.30), radius: 4, x: 0, y: 2)
//                    .offset(x: thumbX)
//                    .animation(.interactiveSpring(), value: sliderValue)
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { drag in
//                                guard !verified, !isLoading else { return }
//                                let raw = drag.location.x - thumbSize / 2
//                                sliderValue = min(max(raw / (trackW - thumbSize), 0), 1)
//                            }
//                            .onEnded { _ in
//                                guard !verified, !isLoading else { return }
//                                checkVerification()
//                            }
//                    )
//            }
//        }
//        .frame(height: thumbSize)
//    }
//
//    // MARK: - Network
//
//    private func fetchCaptcha() {
//        isLoading    = true
//        sliderValue  = 0
//        verified     = false
//        baseUIImage  = nil
//        pieceUIImage = nil
//
//        guard let url = URL(string: captchaURL) else { isLoading = false; return }
//
//        Alamofire.request(url, method: .get)
//            .responseData { response in
//                switch response.result {
//                case .success(let data):
//                    guard let resp = try? JSONDecoder().decode(CaptchaResponse.self, from: data),
//                          let base64Part = resp.baseImage.split(separator: ",").last,
//                          let imgData    = Data(base64Encoded: String(base64Part)),
//                          let rawImage   = UIImage(data: imgData)
//                    else {
//                        DispatchQueue.main.async { self.isLoading = false }
//                        return
//                    }
//
//                    let px     = CGFloat(Double(resp.positionX ?? "0") ?? 0)
//                    let py     = CGFloat(Double(resp.positionY) ?? 0)
//                    let sid    = resp.sessionId ?? ""
//                    let shape  = ["circle", "star", "puzzle", "heart", "triangle"].randomElement()!
//                    let pSize  = CGSize(width: self.pieceW, height: self.pieceH)
//                    let origin = CGPoint(x: px, y: py)
//
//                    let bgImg    = self.createBaseWithCutout(baseImage: rawImage, at: origin, size: pSize, shape: shape)
//                    let pieceImg = self.createCutoutPiece(from: rawImage, at: origin, size: pSize, shape: shape)
//
//                    DispatchQueue.main.async {
//                        self.targetX     = px
//                        self.targetY     = py
//                        self.sessionId   = sid
//                        self.baseUIImage  = bgImg
//                        self.pieceUIImage = pieceImg
//                        self.isLoading   = false
//                    }
//
//                case .failure:
//                    DispatchQueue.main.async { self.isLoading = false }
//                }
//            }
//    }
//
//    // MARK: - Verification logic
//
//    /// Maps slider 0…1 to pixel offset in the 300-px natural space, exactly as PuzzleCaptchaVC does.
//    private func checkVerification() {
//        let maxRange  = naturalW - pieceW           // 230
//        let userPixel = sliderValue * maxRange      // pixel position in 300-px space
//
//        if abs(userPixel - targetX) <= tolerance {
//            verified = true
//            captchaTimer?.invalidate()
//            let hash = computeHash()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//                onVerified(hash, sessionId)
//            }
//        } else {
//            // Shake and snap back
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { shakeOffset =  12 }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { shakeOffset = -12 }
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
//                withAnimation(.spring()) { shakeOffset = 0; sliderValue = 0 }
//            }
//        }
//    }
//
//    /// SHA256( "{posX}:{CAPTCHA_SECRET}:{posY}" ) — identical to PuzzleCaptchaVC.sha256HashWithCryptoSwift
//    private func computeHash() -> String {
//        let input = "\(Int(targetX)):\(CAPTCHA_SECRET):\(Int(targetY))"
//        return input.sha256()
//    }
//
//    // MARK: - Timer
//
//    private func startTimer() {
//        captchaTimer?.invalidate()
//        captchaTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            if secondsLeft > 0 { secondsLeft -= 1 }
//            else { refreshCaptcha() }
//        }
//    }
//
//    private func refreshCaptcha() {
//        captchaTimer?.invalidate()
//        secondsLeft = 60
//        startTimer()
//        fetchCaptcha()
//    }
//
//    private func cancel() {
//        captchaTimer?.invalidate()
//        onCancel()
//    }
//
//    // MARK: - Image helpers (ported 1-to-1 from PuzzleCaptchaVC)
//
//    private func createCutoutPiece(from image: UIImage, at position: CGPoint, size: CGSize, shape: String) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
//        guard let ctx = UIGraphicsGetCurrentContext() else { UIGraphicsEndImageContext(); return nil }
//        let path = getShapePath(at: CGPoint(x: size.width / 2, y: size.height / 2), size: size, type: shape)
//        ctx.addPath(path.cgPath)
//        ctx.clip()
//        image.draw(at: CGPoint(x: -position.x, y: -position.y))
//        let piece = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return piece
//    }
//
//    private func createBaseWithCutout(baseImage: UIImage, at position: CGPoint, size: CGSize, shape: String) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(baseImage.size, false, baseImage.scale)
//        let ctx = UIGraphicsGetCurrentContext()
//        baseImage.draw(at: .zero)
//        let path = getShapePath(at: CGPoint(x: position.x + size.width / 2,
//                                             y: position.y + size.height / 2), size: size, type: shape)
//        ctx?.addPath(path.cgPath)
//        ctx?.setBlendMode(.clear)
//        ctx?.fillPath()
//        let result = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return result
//    }
//
//    private func getShapePath(at center: CGPoint, size: CGSize, type: String) -> UIBezierPath {
//        switch type {
//
//        case "circle":
//            return UIBezierPath(ovalIn: CGRect(x: center.x - size.width / 2,
//                                               y: center.y - size.height / 2,
//                                               width: size.width, height: size.height))
//
//        case "triangle":
//            let p = UIBezierPath()
//            p.move(to: CGPoint(x: center.x,              y: center.y - size.height / 2))
//            p.addLine(to: CGPoint(x: center.x - size.width / 2, y: center.y + size.height / 2))
//            p.addLine(to: CGPoint(x: center.x + size.width / 2, y: center.y + size.height / 2))
//            p.close(); return p
//
//        case "star":
//            let p = UIBezierPath()
//            let r = size.width / 2
//            let inc = CGFloat.pi * 2 / 10
//            for i in 0..<10 {
//                let angle = CGFloat(i) * inc
//                let len   = i % 2 == 0 ? r : r / 2
//                let pt    = CGPoint(x: center.x + len * cos(angle), y: center.y + len * sin(angle))
//                i == 0 ? p.move(to: pt) : p.addLine(to: pt)
//            }
//            p.close(); return p
//
//        case "heart":
//            let p  = UIBezierPath()
//            let cr = size.width / 4
//            let hh = size.height / 2
//            let qh = size.height / 4
//            p.move(to: CGPoint(x: center.x, y: center.y + hh))
//            p.addCurve(to: CGPoint(x: center.x - size.width / 2, y: center.y - qh),
//                       controlPoint1: CGPoint(x: center.x - size.width / 4, y: center.y + hh),
//                       controlPoint2: CGPoint(x: center.x - size.width / 2, y: center.y))
//            p.addArc(withCenter: CGPoint(x: center.x - cr, y: center.y - qh),
//                     radius: cr, startAngle: .pi, endAngle: 0, clockwise: true)
//            p.addArc(withCenter: CGPoint(x: center.x + cr, y: center.y - qh),
//                     radius: cr, startAngle: .pi, endAngle: 0, clockwise: true)
//            p.addCurve(to: CGPoint(x: center.x, y: center.y + hh),
//                       controlPoint1: CGPoint(x: center.x + size.width / 2, y: center.y),
//                       controlPoint2: CGPoint(x: center.x + size.width / 4, y: center.y + hh))
//            p.close(); return p
//
//        case "puzzle":
//            let p   = UIBezierPath()
//            let ps  = min(size.width, size.height) * 0.6
//            let tab = ps * 0.25
//            let cr  = tab
//            let l   = center.x - ps / 2, r = center.x + ps / 2
//            let t   = center.y - ps / 2, b = center.y + ps / 2
//            let mx  = center.x,          my = center.y
//            p.move(to: CGPoint(x: l, y: t))
//            p.addLine(to: CGPoint(x: mx - tab, y: t))
//            p.addCurve(to: CGPoint(x: mx + tab, y: t),
//                       controlPoint1: CGPoint(x: mx - cr, y: t - tab),
//                       controlPoint2: CGPoint(x: mx + cr, y: t - tab))
//            p.addLine(to: CGPoint(x: r, y: t))
//            p.addLine(to: CGPoint(x: r, y: b))
//            p.addLine(to: CGPoint(x: l, y: b))
//            p.addLine(to: CGPoint(x: l, y: my + tab))
//            p.addCurve(to: CGPoint(x: l, y: my - tab),
//                       controlPoint1: CGPoint(x: l - tab, y: my + cr),
//                       controlPoint2: CGPoint(x: l - tab, y: my - cr))
//            p.addLine(to: CGPoint(x: l, y: t))
//            p.close(); return p
//
//        default:
//            return UIBezierPath(rect: CGRect(x: center.x - size.width / 2,
//                                             y: center.y - size.height / 2,
//                                             width: size.width, height: size.height))
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    ZStack {
//        Color.black.ignoresSafeArea()
//        LoginCaptchaView(onVerified: { h, s in print("hash: \(h) sid: \(s)") },
//                         onCancel: {})
//            .padding(20)
//    }
//}



import SwiftUI
import Alamofire

// MARK: - Constants
private let kRecaptchaSiteKey      = "pbk_live_fb3223b4540ecc8f45c1fae4c582b8b0"
private let kRecaptchaParentOrigin = "app://com.paybito.broker.ios"  // ← iOS specific
private let kRecaptchaGenerate     = "https://recaptcha.paybito.com/v1/internal/generate"
private let kRecaptchaSolve        = "https://recaptcha.paybito.com/v1/internal/solve"

// MARK: - Captcha API Models

private struct RecaptchaGenerateResponse: Codable {
    let sessionId:        String?
    let baseImage:        String
    let pieceImage:       String?   // server sends pre-cut piece
    let positionY:        Double?   // Y of piece in natural space
    let pieceSize:        Int?      // e.g. 50
    let imageWidth:       Int?      // e.g. 300
    let imageHeight:      Int?      // e.g. 200
    let refreshTimeoutMs: Int?
    // NOTE: positionX is NOT returned by API
    // The piece starts at X=0 and user drags to correct X
}

private struct RecaptchaSolveResponse: Codable {
    let ok:    Bool?    // ← API returns "ok" not "success"
    let token: String?
    let error: String?
}

// MARK: - LoginCaptchaView

struct LoginCaptchaView: View {

    var onVerified: (_ gRecaptchaResponse: String) -> Void
    var onCancel:   () -> Void

    // ── Captcha data ──────────────────────────────────────────────
    @State private var baseUIImage:   UIImage?
    @State private var pieceUIImage:  UIImage?
    @State private var targetY:       CGFloat = 0   // Y of piece (natural space)
    @State private var apiPieceSize:  CGFloat = 50
    @State private var apiImageW:     CGFloat = 300
    @State private var apiImageH:     CGFloat = 200
    @State private var sessionId:     String  = ""

    // ── Slider state ──────────────────────────────────────────────
    @State private var sliderValue:  CGFloat = 0    // 0…1
    @State private var isLoading     = true
    @State private var isSolving     = false
    @State private var verified      = false
    @State private var shakeOffset:  CGFloat = 0
    @State private var secondsLeft   = 60
    @State private var captchaTimer: Timer?
    @State private var errorMessage: String? = nil

    private let displayH:  CGFloat = 180
    private let thumbSize: CGFloat = 44

    private let purple     = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let headerGrad = LinearGradient(
        colors: [Color(red: 0.50, green: 0.30, blue: 0.95),
                 Color(red: 0.40, green: 0.25, blue: 0.85)],
        startPoint: .leading, endPoint: .trailing
    )

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            bodySection
            footerBar
        }
        .background(Color(red: 0.08, green: 0.10, blue: 0.16))
        .cornerRadius(20)
        .onAppear { fetchCaptcha(); startTimer() }
        .onDisappear { captchaTimer?.invalidate() }
    }

    // MARK: - Header

    private var headerBar: some View {
        headerGrad.frame(height: 64)
            .overlay {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 22)).foregroundColor(.white)
                    Text("Security Verification")
                        .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Button(action: cancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
            }
    }

    // MARK: - Body section

    private var bodySection: some View {
        VStack(spacing: 16) {
            puzzleArea.padding(.top, 20)

            HStack {
                Text("Slide to verify")
                    .font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                Spacer()
                if isSolving { ProgressView().tint(.white).scaleEffect(0.8) }
            }
            .padding(.horizontal, 20)

            sliderTrack.padding(.horizontal, 20)

            if let err = errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14)).foregroundColor(.red.opacity(0.8))
                    Text(err)
                        .font(.system(size: 12)).foregroundColor(.red.opacity(0.8))
                    Spacer()
                }
                .padding(.horizontal, 20)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14)).foregroundColor(.white.opacity(0.45))
                    Text("Drag the slider to align the piece with the slot")
                        .font(.system(size: 12)).foregroundColor(.white.opacity(0.55))
                    Spacer()
                }
                .padding(.horizontal, 20)
            }

            HStack {
                Spacer()
                Text("renew in \(secondsLeft) sec")
                    .font(.system(size: 13)).foregroundColor(.white.opacity(0.55))
                Button(action: refreshCaptcha) {
                    Image(systemName: "arrow.2.circlepath")
                        .font(.system(size: 16)).foregroundColor(purple)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
        }
        .background(Color(red: 0.10, green: 0.12, blue: 0.18))
    }

    // MARK: - Footer

    private var footerBar: some View {
        HStack(spacing: 8) {
            Text("Powered by PayBito reCAPTCHA")
                       .font(.system(size: 11, weight: .medium))
                       .foregroundColor(.white.opacity(0.55))
                       .minimumScaleFactor(0.8)

                   
            Button(action: refreshCaptcha) {
                Text("Refresh")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    .frame(width: 110, height: 48)
                    .background(Color(red: 0.40, green: 0.30, blue: 0.85))
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)

            Button(action: cancel) {
                Text("Cancel")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    .frame(width: 110, height: 48)
                    .background(Color(red: 0.90, green: 0.38, blue: 0.38))
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity).frame(height: 72)
        .background(Color(red: 0.08, green: 0.10, blue: 0.16))
    }

    // MARK: - Puzzle area
    //
    // The piece starts at X=0 and slides right.
    // slider 0→1 maps to piece X: 0 → (apiImageW - apiPieceSize)
    // userSliderX sent to server = Int(sliderValue * (apiImageW - apiPieceSize))

    private var puzzleArea: some View {
        GeometryReader { geo in
            let displayW   = geo.size.width
            let scaleX     = displayW / apiImageW
            let scaleY     = displayH  / apiImageH

            let pieceDispW = apiPieceSize * scaleX
            let pieceDispH = apiPieceSize * scaleY

            // Piece X in screen space
            let maxNatural = apiImageW - apiPieceSize        // 250
            let pieceDispX = (sliderValue * maxNatural) * scaleX
            let pieceDispY = targetY * scaleY

            ZStack(alignment: .topLeading) {
                if isLoading {
                    RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.08))
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if let bg = baseUIImage {
                    // Background (server already drew the hole)
                    Image(uiImage: bg)
                        .resizable()
                        .frame(width: displayW, height: displayH)
                        .clipped()

                    // Sliding piece (server pre-cut)
                    if let piece = pieceUIImage {
                        Image(uiImage: piece)
                            .resizable()
                            .frame(width: pieceDispW, height: pieceDispH)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 2)
                            .offset(x: pieceDispX + shakeOffset, y: pieceDispY)
                            .animation(.interactiveSpring(), value: sliderValue)
                    }

                    if verified {
                        Color.green.opacity(0.25)
                            .frame(width: displayW, height: displayH)
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().scaledToFit().frame(width: 60, height: 60)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                } else {
                    RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.05))
                    Text("Tap Refresh to reload")
                        .font(.system(size: 13)).foregroundColor(.white.opacity(0.55))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .frame(height: displayH)
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }

    // MARK: - Slider track

    private var sliderTrack: some View {
        GeometryReader { geo in
            let trackW = geo.size.width
            let thumbX = sliderValue * (trackW - thumbSize)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(red: 0.18, green: 0.20, blue: 0.30))
                    .frame(height: 8)
                    .padding(.vertical, (thumbSize - 8) / 2)

                Capsule()
                    .fill(verified ? Color.green : purple)
                    .frame(width: max(thumbX + thumbSize / 2, 0), height: 8)
                    .padding(.vertical, (thumbSize - 8) / 2)
                    .animation(.interactiveSpring(), value: sliderValue)

                Circle()
                    .fill(verified ? Color.green : purple)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay {
                        if isSolving {
                            ProgressView().tint(.white).scaleEffect(0.7)
                        } else {
                            Image(systemName: verified ? "checkmark" : "chevron.right.2")
                                .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        }
                    }
                    .shadow(color: .black.opacity(0.30), radius: 4, x: 0, y: 2)
                    .offset(x: thumbX)
                    .animation(.interactiveSpring(), value: sliderValue)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { drag in
                                guard !verified, !isLoading, !isSolving else { return }
                                let raw = drag.location.x - thumbSize / 2
                                sliderValue = min(max(raw / (trackW - thumbSize), 0), 1)
                            }
                            .onEnded { _ in
                                guard !verified, !isLoading, !isSolving else { return }
                                solveCaptcha()
                            }
                    )
            }
        }
        .frame(height: thumbSize)
    }

    // MARK: - Step 1: Generate
    // Payload: { sitekey, parentOrigin }
    // parentOrigin MUST be "app://com.paybito.broker.ios" for iOS

    private func fetchCaptcha() {
        isLoading    = true
        isSolving    = false
        sliderValue  = 0
        verified     = false
        baseUIImage  = nil
        pieceUIImage = nil
        errorMessage = nil

        let params: [String: Any] = [
            "sitekey":      kRecaptchaSiteKey,
            "parentOrigin": kRecaptchaParentOrigin
        ]

        Alamofire.request(kRecaptchaGenerate,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    #if DEBUG
                    print("📥 GENERATE:", String(data: data, encoding: .utf8) ?? "nil")
                    #endif

                    guard
                        let resp     = try? JSONDecoder().decode(
                                           RecaptchaGenerateResponse.self, from: data),
                        let b64Base  = resp.baseImage.split(separator: ",").last,
                        let baseData = Data(base64Encoded: String(b64Base)),
                        let bgImage  = UIImage(data: baseData)
                    else {
                        DispatchQueue.main.async { self.isLoading = false }
                        return
                    }

                    let py    = CGFloat(resp.positionY  ?? 0)
                    let imgW  = CGFloat(resp.imageWidth  ?? 300)
                    let imgH  = CGFloat(resp.imageHeight ?? 200)
                    let pSize = CGFloat(resp.pieceSize   ?? 50)
                    let sid   = resp.sessionId ?? ""

                    // Decode server pieceImage (pre-cut by server)
                    var pImage: UIImage? = nil
                    if let pieceStr  = resp.pieceImage,
                       !pieceStr.isEmpty,
                       let b64Piece  = pieceStr.split(separator: ",").last,
                       let pieceData = Data(base64Encoded: String(b64Piece)) {
                        pImage = UIImage(data: pieceData)
                    }

                    #if DEBUG
                    print("📐 positionY:\(py) pieceSize:\(pSize) imgW:\(imgW) imgH:\(imgH) hasPiece:\(pImage != nil)")
                    #endif

                    DispatchQueue.main.async {
                        self.apiImageW    = imgW
                        self.apiImageH    = imgH
                        self.apiPieceSize = pSize
                        self.targetY      = py
                        self.sessionId    = sid
                        self.baseUIImage  = bgImage  // server already drew hole
                        self.pieceUIImage = pImage
                        self.isLoading    = false
                    }

                case .failure(let err):
                    #if DEBUG
                    print("❌ GENERATE ERROR:", err)
                    #endif
                    DispatchQueue.main.async { self.isLoading = false }
                }
            }
    }

    // MARK: - Step 2: Solve
    //
    // Payload: { sitekey, sessionId, userSliderX, parentOrigin }
    // NO signals needed
    //
    // userSliderX = pixel X where piece landed in natural (300px) space
    // slider 0→1 maps to 0 → (apiImageW - apiPieceSize) = 250
    // So: userSliderX = Int(sliderValue * (apiImageW - apiPieceSize))
    //
    // Server checks if userSliderX matches the hole position.
    // Response: { "ok": true, "token": "JWT..." }

    private func solveCaptcha() {
        let maxNatural  = apiImageW - apiPieceSize       // 300 - 50 = 250
        let userSliderX = Int(round(sliderValue * maxNatural))

        isSolving    = true
        errorMessage = nil

        #if DEBUG
        print("📤 SOLVE userSliderX:\(userSliderX) sliderValue:\(String(format:"%.4f",sliderValue))")
        #endif

        let params: [String: Any] = [
            "sitekey":      kRecaptchaSiteKey,
            "sessionId":    sessionId,
            "userSliderX":  userSliderX,
            "parentOrigin": kRecaptchaParentOrigin
        ]

        Alamofire.request(kRecaptchaSolve,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default)
            .responseData { response in
                DispatchQueue.main.async {
                    self.isSolving = false

                    switch response.result {
                    case .success(let data):
                        #if DEBUG
                        print("📥 SOLVE:", String(data: data, encoding: .utf8) ?? "nil")
                        #endif

                        guard let resp = try? JSONDecoder().decode(
                                RecaptchaSolveResponse.self, from: data)
                        else {
                            self.errorMessage = "Verification failed. Try again."
                            self.shakeAndReset(); return
                        }

                        // Check "ok": true AND token exists
                        if resp.ok == true,
                           let token = resp.token, !token.isEmpty {
                            self.verified = true
                            self.captchaTimer?.invalidate()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.onVerified(token)
                            }
                        } else {
                            self.errorMessage = resp.error ?? "Position mismatch. Try again."
                            self.shakeAndReset()
                        }

                    case .failure:
                        self.errorMessage = "Network error. Please try again."
                        self.shakeAndReset()
                    }
                }
            }
    }

    // MARK: - Shake + reset

    private func shakeAndReset() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { shakeOffset =  12 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { shakeOffset = -12 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            withAnimation(.spring()) { shakeOffset = 0; sliderValue = 0 }
        }
    }

    // MARK: - Timer

    private func startTimer() {
        captchaTimer?.invalidate()
        captchaTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsLeft > 0 { secondsLeft -= 1 }
            else { refreshCaptcha() }
        }
    }

    private func refreshCaptcha() {
        captchaTimer?.invalidate()
        secondsLeft = 60
        startTimer()
        fetchCaptcha()
    }

    private func cancel() {
        captchaTimer?.invalidate()
        onCancel()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        LoginCaptchaView(
            onVerified: { token in print("✅ token:", token) },
            onCancel:   { print("cancelled") }
        )
        .padding(20)
    }
}
