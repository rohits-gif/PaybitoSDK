//
//  EditBankDetailsView.swift
//  Trading_Terminal
//

import SwiftUI
import UniformTypeIdentifiers

struct AddBankDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Focus Fields
    enum Field: Hashable {
        case name, account, code, bankName, address
    }

    @FocusState private var focusedField: Field?

    // ✅ Matches the actual class name in BankDetailsViewModel.swift
    @StateObject private var viewModel = AddBankDetailsViewModel()
    @State private var showFileImporter = false

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        header
                        accountSection
                        bankSection
                        verificationSection
                        noteSection

                        if let err = viewModel.errorMessage {
                            feedbackBanner(text: err, isError: true)
                        }
                        if let ok = viewModel.successMessage {
                            feedbackBanner(text: ok, isError: false)
                        }
                    }
                    .padding()
                }
                bottomButtons
            }

            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [
                .pdf,
                .png,
                .jpeg
            ],
            allowsMultipleSelection: false
        ) { result in
            do {
                let file = try result.get().first
                if let url = file {
                    viewModel.handleBankDocument(url: url)
                }
            } catch {
                viewModel.errorMessage = "Failed to select file."
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { focusedField = nil }
        .onAppear     { viewModel.fetchExistingBankDetails() }
    }

    // MARK: - Header

    var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Bank Details")
                    .foregroundColor(.white)
                    .font(.title2.bold())

                Text(viewModel.submissionStatus == .notSubmitted
                     ? "Bank details not submitted."
                     : "Bank details on file.")
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Spacer()

            Text(viewModel.submissionStatus.label)
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .foregroundColor(.white)
                .font(.caption)
        }
    }

    // MARK: - Account Section

    var accountSection: some View {
        sectionCard(title: "Account Information", icon: "person") {
            inputField("Account Holder's Name *",
                       text: $viewModel.name,
                       field: .name)
            inputField("IBAN / Account Number *",
                       text: $viewModel.accountNumber,
                       field: .account)

            HStack {
                dropdown("Account Type *",
                         selection: $viewModel.accountType,
                         options: viewModel.accountOptions)
                dropdown("Code Type *",
                         selection: $viewModel.codeType,
                         options: viewModel.codeOptions)
            }

            inputField("Enter Code *",
                       text: $viewModel.code,
                       field: .code)
        }
    }

    // MARK: - Bank Section

    var bankSection: some View {
        sectionCard(title: "Bank Information", icon: "building.columns") {
            inputField("Bank Name *",
                       text: $viewModel.bankName,
                       field: .bankName)
            inputField("Bank Address *",
                       text: $viewModel.address,
                       field: .address)
        }
    }

    // MARK: - Note Section

    var noteSection: some View {
        Text("Note: Ensure all bank details are accurate before submission. Any discrepancies may result in transaction delays or rejection. Your bank information is encrypted and securely stored.")
            .font(.caption)
            .foregroundColor(.gray)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
    }

    // MARK: - Feedback Banner

    func feedbackBanner(text: String, isError: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isError ? "exclamationmark.circle" : "checkmark.circle")
                .foregroundColor(isError ? .red : .green)
            Text(text)
                .foregroundColor(.white)
                .font(.caption)
            Spacer()
            Button { viewModel.clearAlerts()
                dismiss()} label: {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(12)
        .background((isError ? Color.red : Color.green).opacity(0.15))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke((isError ? Color.red : Color.green).opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Bottom Buttons

    var bottomButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                focusedField = nil
                viewModel.clearAlerts()
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.inputBackground)
                .cornerRadius(28)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)

            Button(action: {
                focusedField = nil
                viewModel.persistBankDetailsToServer()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                    Text("Save")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.accentPurple, Color(red: 0.45, green: 0.25, blue: 0.80)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .opacity(viewModel.isLoading ? 0.6 : 1.0)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.navbarBackground.ignoresSafeArea(edges: .bottom))
    }

    // MARK: - Section Card

    func sectionCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.accentPurple.opacity(0.2))
                    .cornerRadius(10)

                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("Your \(title.lowercased())")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            content()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.cardBorder.opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Input Field

    func inputField(_ title: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(.gray)
                .font(.caption)

            TextField("", text: text)
                .focused($focusedField, equals: field)
                .foregroundColor(.white)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.inputBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            focusedField == field ? Color.accentPurple : Color.white.opacity(0.08),
                            lineWidth: focusedField == field ? 1.5 : 1
                        )
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .contentShape(Rectangle())
                .onTapGesture { focusedField = field }
                .animation(.easeInOut(duration: 0.15), value: focusedField)
        }
        .contentShape(Rectangle())
        .onTapGesture { focusedField = field }
    }

    // MARK: - Dropdown

    func dropdown(_ title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(.gray)
                .font(.caption)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection.wrappedValue = option }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.inputBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            }
        }
    }
    var verificationSection: some View {
        sectionCard(title: "Bank Verification Document", icon: "doc.text") {
            VStack(alignment: .leading, spacing: 16) {

                // Accepted document list
                VStack(alignment: .leading, spacing: 10) {
                    Text("PLEASE UPLOAD ONE OF THE FOLLOWING:")
                        .foregroundColor(.gray)
                        .font(.caption)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(viewModel.bankDocOptions, id: \.self) { item in
                            HStack(alignment: .top, spacing: 6) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 5, height: 5)
                                    .padding(.top, 6)

                                Text(item)
                                    .foregroundColor(.white.opacity(0.85))
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)

                                Spacer()
                            }
                        }
                    }
                }

                // Required info box
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)

                        Text("Uploaded document should show:")
                            .foregroundColor(.white)
                            .font(.caption.bold())
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        requirementRow("Account Holder Name")
                        requirementRow("Bank Name")
                        requirementRow("Account Number (partially masked if needed)")
                        requirementRow("Routing / IFSC / SWIFT details (as applicable)")
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.08))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                )

                // Form row
                HStack(alignment: .top, spacing: 12) {
                    dropdown(
                        "Bank Account Verification Document Type *",
                        selection: $viewModel.selectedBankDocType,
                        options: viewModel.bankDocOptions
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Upload Bank Verification Document *")
                            .foregroundColor(.gray)
                            .font(.caption)

                        Button {
                            showFileImporter = true
                        } label: {
                            if let fileName = viewModel.bankDocFileName {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)

                                    Text(fileName)
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .lineLimit(1)

                                    Spacer()

                                    Button {
                                        viewModel.removeBankDocument()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.inputBackground)
                                .cornerRadius(10)
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "icloud.and.arrow.up")
                                        .foregroundColor(.gray)
                                        .font(.title3)

                                    Text("Click to upload")
                                        .foregroundColor(.white)
                                        .font(.caption)

                                    Text("PDF, JPG, PNG (Max 5 MB)")
                                        .foregroundColor(.gray)
                                        .font(.caption2)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            style: StrokeStyle(
                                                lineWidth: 1,
                                                dash: [6]
                                            )
                                        )
                                        .foregroundColor(Color.white.opacity(0.15))
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    func requirementRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 4, height: 4)
                .padding(.top, 6)

            Text(text)
                .foregroundColor(.white.opacity(0.9))
                .font(.caption)
        }
    }

    
}

// MARK: - Preview

struct BankDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AddBankDetailsView()
            .preferredColorScheme(.dark)
    }
}
