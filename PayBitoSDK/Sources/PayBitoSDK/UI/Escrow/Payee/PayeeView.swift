import SwiftUI

// MARK: - Hex Color Helper (static factory avoids init conflict)

extension Color {
    static func hex(_ hex: String) -> Color {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Theme

enum AppTheme {
    static let background    = Color.hex("0D0D14")
    static let surface       = Color.hex("13131E")
    static let surfaceRaised = Color.hex("1A1A28")
    static let border        = Color.hex("2A2A3D")
    static let accent        = Color.hex("6C8EF5")
    static let accentGreen   = Color.hex("4CD964")
    static let textPrimary   = Color.white
    static let textSecondary = Color.hex("8A8A9A")
    static let payeeTag      = Color.hex("2ECC71")
}

// MARK: - Models

enum ContractStatus: String, CaseIterable, Identifiable {
    case allStatuses     = "All Statuses"
    case draft           = "Draft"
    case created         = "Created"
    case pending         = "Pending"
    case funded          = "Funded"
    case partiallyFunded = "Partially Funded"
    case completed       = "Completed"
    case cancelled       = "Cancelled"
    case disputed        = "Disputed"
    case inReview        = "In Review"
    case releaseApproved = "Release Approved"
    case rejected        = "Rejected"

    var id: String { rawValue }

    var statusColor: Color {
        switch self {
        case .allStatuses:      return .white
        case .draft:            return Color.hex("8A8A9A")
        case .created:          return Color.hex("6C8EF5")
        case .pending:          return Color.hex("F5A623")
        case .funded:           return Color.hex("4CD964")
        case .partiallyFunded:  return Color.hex("A8E6CF")
        case .completed:        return Color.hex("2ECC71")
        case .cancelled:        return Color.hex("E74C3C")
        case .disputed:         return Color.hex("E74C3C")
        case .inReview:         return Color.hex("9B59B6")
        case .releaseApproved:  return Color.hex("1ABC9C")
        case .rejected:         return Color.hex("C0392B")
        }
    }
}

struct EscrowContract: Identifiable {
    let id: String
    let title: String
    let amount: String
    let payer: String
    let contractStatus: ContractStatus
    let fundingStatus: String
    let created: String
}

// MARK: - Status Filter Dropdown

struct StatusFilterDropdown: View {
    @Binding var selected: ContractStatus
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {

            // Trigger button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    if selected != .allStatuses {
                        Circle()
                            .fill(selected.statusColor)
                            .frame(width: 7, height: 7)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                    }
                    Text(selected.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.surfaceRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isExpanded ? AppTheme.accent.opacity(0.6) : AppTheme.border,
                            lineWidth: 1
                        )
                )
                .cornerRadius(8)
            }

            // Dropdown list
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(ContractStatus.allCases) { status in
                        Button {
                            withAnimation(.spring(response: 0.25)) {
                                selected = status
                                isExpanded = false
                            }
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    if status == selected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(AppTheme.accent)
                                    } else if status != .allStatuses {
                                        Circle()
                                            .fill(status.statusColor)
                                            .frame(width: 7, height: 7)
                                    }
                                }
                                .frame(width: 14, height: 14)

                                Text(status.rawValue)
                                    .font(.system(size: 13))
                                    .foregroundColor(
                                        status == selected
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary
                                    )
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                status == selected
                                    ? AppTheme.accent.opacity(0.08)
                                    : Color.clear
                            )
                        }
                        .buttonStyle(.plain)

                        if status.id != ContractStatus.allCases.last?.id {
                            Rectangle()
                                .fill(AppTheme.border)
                                .frame(height: 1)
                        }
                    }
                }
                .background(AppTheme.surfaceRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 8)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95, anchor: .topTrailing).combined(with: .opacity),
                    removal:   .scale(scale: 0.95, anchor: .topTrailing).combined(with: .opacity)
                ))
                .zIndex(10)
            }
        }
    }
}

// MARK: - Contract Row

struct ContractRow: View {
    let contract: EscrowContract

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(contract.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("ID: \(contract.id)")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                Text(contract.amount)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.accentGreen)
            }

            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)

            HStack(spacing: 16) {
                LabelValue(label: "PAYER", value: contract.payer)
                LabelValue(label: "FUNDING", value: contract.fundingStatus)
                Spacer()
                StatBadge(status: contract.contractStatus)
            }

            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textSecondary)
                Text(contract.created)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(14)
        .background(AppTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct LabelValue: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .tracking(0.8)
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
        }
    }
}

struct StatBadge: View {
    let status: ContractStatus

    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(status.statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.statusColor.opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(status.statusColor.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(6)
    }
}

// MARK: - Empty State

struct EmptyContractsView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
            Text("No contracts found")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Main View

struct EscrowContractsView: View {
    @State private var searchText: String = ""
    @State private var selectedStatus: ContractStatus = .allStatuses
    @State private var isDropdownExpanded: Bool = false
    @State private var currentPage: Int = 1

    // Sample data — replace with your API response
    let contracts: [EscrowContract] = [
        EscrowContract(
            id: "ESC-001", title: "Website Redesign Project",
            amount: "$4,500.00", payer: "John Smith",
            contractStatus: .funded, fundingStatus: "Fully Funded",
            created: "May 28, 2026"
        ),
        EscrowContract(
            id: "ESC-002", title: "Mobile App Development",
            amount: "$12,000.00", payer: "Acme Corp",
            contractStatus: .inReview, fundingStatus: "Partially Funded",
            created: "May 30, 2026"
        ),
        EscrowContract(
            id: "ESC-003", title: "Logo & Branding Package",
            amount: "$800.00", payer: "Sarah Lee",
            contractStatus: .pending, fundingStatus: "Awaiting",
            created: "Jun 01, 2026"
        ),
    ]

    var filteredContracts: [EscrowContract] {
        contracts.filter { contract in
            let matchesStatus = selectedStatus == .allStatuses
                || contract.contractStatus == selectedStatus
            let matchesSearch = searchText.isEmpty
                || contract.title.localizedCaseInsensitiveContains(searchText)
                || contract.id.localizedCaseInsensitiveContains(searchText)
            return matchesStatus && matchesSearch
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Title row
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Escrow Contracts")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        HStack(spacing: 6) {
                            Text("Contracts where you are the payee")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                            Text("PAYEE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.payeeTag)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(AppTheme.payeeTag.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(AppTheme.payeeTag.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(5)
                        }
                    }
                    Spacer()
                    Button {
                        // Create action
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("Create")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(AppTheme.accent)
                        .cornerRadius(9)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 14)

                // ── Search + Filter row
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                        TextField("Search by contract ID or title...", text: $searchText)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)
                            .tint(AppTheme.accent)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.surfaceRaised)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .cornerRadius(9)

                    StatusFilterDropdown(
                        selected: $selectedStatus,
                        isExpanded: $isDropdownExpanded
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

                // ── Column headers
                HStack {
                    Text("CONTRACT")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("AMOUNT")
                        .frame(width: 90, alignment: .trailing)
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .tracking(0.8)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                Rectangle()
                    .fill(AppTheme.border)
                    .frame(height: 1)
                    .padding(.horizontal, 16)

                // ── Contract list
                ScrollView {
                    if filteredContracts.isEmpty {
                        EmptyContractsView()
                    } else {
                        VStack(spacing: 10) {
                            ForEach(filteredContracts) { contract in
                                ContractRow(contract: contract)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    }
                }
                .onTapGesture {
                    if isDropdownExpanded {
                        withAnimation(.spring(response: 0.25)) {
                            isDropdownExpanded = false
                        }
                    }
                }

                // ── Pagination
                Rectangle()
                    .fill(AppTheme.border)
                    .frame(height: 1)

                HStack {
                    Button {
                        if currentPage > 1 { currentPage -= 1 }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Prev")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(currentPage > 1 ? AppTheme.textPrimary : AppTheme.textSecondary)
                    }
                    .disabled(currentPage <= 1)

                    Spacer()

                    Text("Page \(currentPage)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)

                    Spacer()

                    Button {
                        currentPage += 1
                    } label: {
                        HStack(spacing: 4) {
                            Text("Next")
                                .font(.system(size: 13))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppTheme.surface)
            }

            // ── Dismiss dropdown on outside tap
            if isDropdownExpanded {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.25)) {
                            isDropdownExpanded = false
                        }
                    }
                    .ignoresSafeArea()
                    .zIndex(5)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#Preview {
    EscrowContractsView()
}
