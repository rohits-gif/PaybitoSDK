//
//  BusinessActivityViewModel.swift
//  PaymentsTerminal
//

import Foundation
import SwiftUI

// ════════════════════════════════════════════════════════════════════
// MARK: - Model
// ════════════════════════════════════════════════════════════════════

struct BusinessActivityOption: Identifiable, Equatable {
    let id          = UUID()
    let mcc:         String
    let description: String

    var displayLabel:   String { "\(mcc) \u{2013} \(description)" }
    var selectionValue: String { "\(mcc) - \(description)" }

    var risk:      String { BusinessActivityRiskClassifier.risk(for: mcc)  }
    var riskColor: Color  { BusinessActivityRiskClassifier.color(for: mcc) }

    static func == (lhs: BusinessActivityOption, rhs: BusinessActivityOption) -> Bool {
        lhs.mcc == rhs.mcc && lhs.description == rhs.description
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Risk Classifier
// ════════════════════════════════════════════════════════════════════

enum BusinessActivityRiskClassifier {

    private static let highRisk: Set<String> = [
        "6051","6211","5967","5966","5968","7273","7321","7995","7801",
        "6012","5962","6536","6537","6538","6539","9754","7802","4829"
    ]
    private static let mediumRisk: Set<String> = [
        "4722","5969","5961","5963","5964","5965","5960","7511","5499","5169"
    ]
    private static let healthcare: Set<String> = [
        "8011","8021","8031","8041","8042","8043","8044","8049",
        "8050","8062","8071","8099","5912","5047","7280"
    ]
    private static let financial: Set<String> = [
        "6010","6011","6012","6300","6381","6399","6211","6050",
        "6051","6513","6530","6535","6536","6537","6538","6539","6760"
    ]

    static func risk(for mcc: String) -> String {
        if highRisk.contains(mcc)   { return "High Risk"   }
        if healthcare.contains(mcc) { return "Healthcare"  }
        if financial.contains(mcc)  { return "Financial"   }
        if mediumRisk.contains(mcc) { return "Medium Risk" }
        return "Standard"
    }

    static func color(for mcc: String) -> Color {
        switch risk(for: mcc) {
        case "High Risk":   return Color(red: 0.92, green: 0.22, blue: 0.20)
        case "Healthcare":  return Color(red: 0.20, green: 0.60, blue: 0.80)
        case "Financial":   return Color(red: 0.20, green: 0.60, blue: 0.80)
        case "Medium Risk": return Color(red: 0.98, green: 0.55, blue: 0.10)
        default:            return Color(red: 0.20, green: 0.55, blue: 0.85)
        }
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Load State
// ════════════════════════════════════════════════════════════════════

enum BusinessActivityLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

// ════════════════════════════════════════════════════════════════════
// MARK: - ViewModel
// ════════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════════
// MARK: - ViewModel
// ════════════════════════════════════════════════════════════════════

@MainActor
final class BusinessActivityViewModel: ObservableObject {

    @Published private(set) var options:   [BusinessActivityOption] = []
    @Published private(set) var loadState: BusinessActivityLoadState = .idle
    @Published var showPicker: Bool = false

    private let service: GetMerchantCategoryServiceProtocol

    init(service: GetMerchantCategoryServiceProtocol = GetMerchantCategoryService.shared) {
        self.service = service
        bizLog("🏗️  [BusinessActivityViewModel] initialized")
    }

    func filtered(by query: String) -> [BusinessActivityOption] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return options }
        return options.filter {
            $0.mcc.contains(q)                                 ||
            $0.description.localizedCaseInsensitiveContains(q) ||
            $0.risk.localizedCaseInsensitiveContains(q)
        }
    }

    func fetchIfNeeded() {
        guard loadState != .loaded, loadState != .loading else {
            bizLog("ℹ️  [BusinessActivityViewModel] skipping fetch — already \(loadState)")
            return
        }
        fetch()
    }

    func retry() {
        bizLog("🔄 [BusinessActivityViewModel] retry triggered")
        loadState = .idle
        fetch()
    }

    private func fetch() {
        loadState = .loading
        bizLog("🚀 [BusinessActivityViewModel] starting fetch…")

        // ── Read UUID from UserDefaults — same key used by all other services ──
        let uuid = UserDefaults.standard.string(forKey: "Buuid") ?? ""

        guard !uuid.isEmpty else {
            bizLog("❌ [BusinessActivityViewModel] UUID missing in UserDefaults key 'Buuid'")
            loadState = .failed("User UUID is missing. Please log in again.")
            return
        }

        bizLog("🔑 [BusinessActivityViewModel] uuid: \(uuid)")

        service.fetchMCCList(uuid: uuid) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                self.options = items.map {
                    BusinessActivityOption(mcc: $0.mcc, description: $0.description)
                }
                self.loadState = .loaded
                bizLog("✅ [BusinessActivityViewModel] loaded \(items.count) options")
                self.options.prefix(5).forEach {
                    bizLog("   • \($0.displayLabel)  [\($0.risk)]")
                }

            case .failure(let error):
                self.loadState = .failed(error.localizedDescription)
                bizLog("❌ [BusinessActivityViewModel] fetch failed: \(error.localizedDescription)")
            }
        }
    }
}
// ════════════════════════════════════════════════════════════════════
// MARK: - BusinessActivityPickerSheet
// ════════════════════════════════════════════════════════════════════

struct BusinessActivityPickerSheet: View {

    @ObservedObject var vm: BusinessActivityViewModel
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    private enum C {
        static let bg     = Color(red: 0.07, green: 0.08, blue: 0.14)
        static let card   = Color(red: 0.10, green: 0.12, blue: 0.19)
        static let field  = Color(red: 0.12, green: 0.14, blue: 0.22)
        static let purple = Color(red: 0.47, green: 0.35, blue: 0.95)
        static let border = Color(white: 0.22)
        static let gray   = Color(white: 0.55)
        static let red    = Color(red: 0.92, green: 0.22, blue: 0.20)
    }

    private var filtered: [BusinessActivityOption] { vm.filtered(by: searchText) }

    var body: some View {
        NavigationView {
            ZStack {
                C.bg.ignoresSafeArea()
                contentView
            }
            .navigationTitle("Business Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(C.purple)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // FIX: extract switch into a separate computed property so the
    // type-checker never sees it inside a ZStack ViewBuilder closure.
    @ViewBuilder
    private var contentView: some View {
        switch vm.loadState {
        case .idle, .loading:
            loadingView
        case .failed(let msg):
            errorView(message: msg)
        case .loaded:
            listView
        }
    }

    // ── Loading ───────────────────────────────────────────────────
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.3)
                .tint(C.purple)
            Text("Loading business activities\u{2026}")
                .font(.system(size: 14))
                .foregroundColor(C.gray)
        }
    }

    // ── Error + Retry ─────────────────────────────────────────────
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(C.red)
            Text("Failed to load")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(C.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                bizLog("🔄 [BusinessActivityPickerSheet] retry tapped")
                vm.retry()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(C.purple).cornerRadius(8)
            }
        }
        .padding(24)
    }

    // ── List ──────────────────────────────────────────────────────
    private var listView: some View {
        VStack(spacing: 0) {
            searchBar
            countBadge
            Divider().background(C.border)
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(filtered) { opt in
                        pickerRow(opt)
                        Divider()
                            .background(Color(white: 0.15))
                            .padding(.horizontal, 16)
                    }
                    if filtered.isEmpty { emptyState }
                }
                .padding(.bottom, 24)
            }
        }
    }

    // ── Search bar ────────────────────────────────────────────────
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(C.gray)
                .font(.system(size: 14))
            TextField("Search MCC code or description\u{2026}", text: $searchText)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .tint(C.purple)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(white: 0.50))
                        .font(.system(size: 15))
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(C.field)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(C.border, lineWidth: 1))
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    // ── Count badge ───────────────────────────────────────────────
    private var countBadge: some View {
        HStack {
            Text("\(filtered.count) of \(vm.options.count) activities")
                .font(.system(size: 11))
                .foregroundColor(Color(white: 0.40))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(Color(red: 0.08, green: 0.09, blue: 0.15))
    }

    // ── Empty state ───────────────────────────────────────────────
    // FIX: replaced curly-quote string literal with straight quotes
    // to eliminate "String interpolation can only appear inside a string literal"
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 30))
                .foregroundColor(Color(white: 0.35))
            Text("No results for \"\(searchText)\"")
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }

    // ── Row ───────────────────────────────────────────────────────
    private func pickerRow(_ opt: BusinessActivityOption) -> some View {
        let isSelected = selected == opt.selectionValue
        return Button {
            bizLog("✅ [BusinessActivityPickerSheet] selected: MCC \(opt.mcc) -> '\(opt.selectionValue)'")
            selected = opt.selectionValue
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Text(opt.mcc)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color(red: 0.20, green: 0.24, blue: 0.36))
                    .cornerRadius(5)
                    .frame(width: 56, alignment: .center)

                VStack(alignment: .leading, spacing: 3) {
                    Text(opt.description)
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? C.purple : .white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(opt.risk)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(opt.riskColor)
                        .cornerRadius(4)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(C.purple)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? C.purple.opacity(0.09) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Debug helper
// ════════════════════════════════════════════════════════════════════

private func bizLog(_ msg: String) {
#if DEBUG
    print(msg)
#endif
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ════════════════════════════════════════════════════════════════════

#Preview {
    BusinessActivityPickerSheet(
        vm: BusinessActivityViewModel(),
        selected: .constant("")
    )
}
