//
//  ApplyPlanSheet.swift
//  Trading_Terminal
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Plan Type

enum ApplyPlanType {
    case basic, business

    var title: String {
        switch self {
        case .basic:    return "Apply Basic Plan"
        case .business: return "Apply Business Plan"
        }
    }

    var volumeId: Int {
        switch self {
        case .basic:    return 2
        case .business: return 3
        }
    }
}

// MARK: - Apply Plan Sheet

struct ApplyPlanSheet: View {

    let plan: ApplyPlanType
    @ObservedObject var viewModel: LimitsViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Form fields
    @State private var ein     = ""
    @State private var website = ""

    // File data + names
    @State private var file1Data: Data?; @State private var file1Name = ""
    @State private var file2Data: Data?; @State private var file2Name = ""
    @State private var file3Data: Data?; @State private var file3Name = ""
    @State private var file4Data: Data?; @State private var file4Name = ""

    // File picker
    @State private var activeFilePicker: FilePurpose?

    // Local validation
    @State private var validationMessage = ""
    @State private var showValidation    = false

    private let purple = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let darkBG = Color(red: 0.08, green: 0.10, blue: 0.16)

    var body: some View {
        Group {
            if #available(iOS 16.4, *) {
                content
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(20)
//                    .presentationBackground(darkBG)
            } else {
                content
            }
        }
        .onChange(of: viewModel.applyDidSucceed) { success in
            if success {
                viewModel.resetApplyState()
                dismiss()
            }
        }
    }

    // MARK: - Content

    private var content: some View {
        ZStack {
            darkBG.ignoresSafeArea()

            VStack(spacing: 0) {

                // Header
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.resetApplyState()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)

                    Text(plan.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 20)

                // Form
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        Text("Tax Document")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(purple)

                        // EIN — both plans
                        AVField(label: "EIN *",
                                placeholder: "Provide Govt. Issued EIN No.",
                                text: $ein)
                      

                        // Website — Business only
                        if plan == .business {
                            AVField(label: "Website *",
                                    placeholder: "Provide Website",
                                    text: $website,
                                    keyboard: .URL)
                          
                        }

                        // EIN doc — both plans
                        FilePickerRow(label: "EIN Issuance Document *",
                                      fileName: file1Name,
                                      onTap: { activeFilePicker = .einDoc })

                        // Business only
                        if plan == .business {
                            FilePickerRow(label: "Owner's Photo ID *",
                                          fileName: file2Name,
                                          onTap: { activeFilePicker = .ownerPhoto })
                            FilePickerRow(label: "Business Registration *",
                                          fileName: file3Name,
                                          onTap: { activeFilePicker = .bizReg })
                            FilePickerRow(label: "Proof of Business Address *",
                                          fileName: file4Name,
                                          onTap: { activeFilePicker = .bizAddress })
                        }

                        // API error banner
                        if let apiError = viewModel.applyErrorMessage {
                            Text(apiError)
                                .font(.system(size: 13))
                                .foregroundColor(.red.opacity(0.9))
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }

                // Bottom buttons
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.resetApplyState()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 50)
                            .background(Color(red: 0.18, green: 0.20, blue: 0.30))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isSubmitting)

                    Button(action: handleApply) {
                        Group {
                            if viewModel.isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Apply")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(purple.opacity(viewModel.isSubmitting ? 0.6 : 1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isSubmitting)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(darkBG)
            }
        }
        .sheet(item: $activeFilePicker) { purpose in
            DocumentPicker(allowedTypes: purpose.allowedTypes) { url in
                handlePickedFile(url: url, purpose: purpose)
            }
        }
        .alert("Missing Info", isPresented: $showValidation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    // MARK: - Validate & Submit

    private func handleApply() {
        let trimmedEIN = ein.trimmingCharacters(in: .whitespaces)
        guard !trimmedEIN.isEmpty else {
            validationMessage = "Please enter your EIN number."
            showValidation = true; return
        }
        if plan == .business {
            guard !website.trimmingCharacters(in: .whitespaces).isEmpty else {
                validationMessage = "Please provide your website URL."
                showValidation = true; return
            }
        }
        guard file1Data != nil else {
            validationMessage = "Please select an EIN Issuance Document."
            showValidation = true; return
        }
        if plan == .business {
            guard file2Data != nil else {
                validationMessage = "Please select Owner's Photo ID."
                showValidation = true; return
            }
            guard file3Data != nil else {
                validationMessage = "Please select Business Registration document."
                showValidation = true; return
            }
            guard file4Data != nil else {
                validationMessage = "Please select Proof of Business Address."
                showValidation = true; return
            }
        }

        let form = ApplyPlanForm(
            taxId:     trimmedEIN,
            website:   website.trimmingCharacters(in: .whitespaces),
            file1Data: file1Data, file1Name: file1Name,
            file2Data: file2Data, file2Name: file2Name,
            file3Data: file3Data, file3Name: file3Name,
            file4Data: file4Data, file4Name: file4Name
        )

        viewModel.submitPlan(type: plan, form: form)
    }

    // MARK: - File Handling

    private func handlePickedFile(url: URL, purpose: FilePurpose) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url) else {
            validationMessage = "Could not read the selected file."
            showValidation = true; return
        }
        let name = url.lastPathComponent
        switch purpose {
        case .einDoc:     file1Data = data; file1Name = name
        case .ownerPhoto: file2Data = data; file2Name = name
        case .bizReg:     file3Data = data; file3Name = name
        case .bizAddress: file4Data = data; file4Name = name
        }
    }
}

// MARK: - File Purpose

private enum FilePurpose: String, Identifiable {
    case einDoc, ownerPhoto, bizReg, bizAddress
    var id: String { rawValue }

    var allowedTypes: [UTType] {
        switch self {
        case .einDoc, .bizReg, .bizAddress: return [.pdf, .jpeg, .png, .image]
        case .ownerPhoto:                   return [.jpeg, .png, .image, .pdf]
        }
    }
}

// MARK: - Document Picker

private struct DocumentPicker: UIViewControllerRepresentable {
    let allowedTypes: [UTType]
    let onPicked: (URL) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onPicked: onPicked) }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPicked: (URL) -> Void
        init(onPicked: @escaping (URL) -> Void) { self.onPicked = onPicked }
        func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPicked(url)
        }
    }
}

// MARK: - Text Field


private struct AVField: View {

    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.70))

            TextField(placeholder, text: $text)
                .focused($isFocused)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .padding(14)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.12, green: 0.15, blue: 0.22))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isFocused
                            ? Color.purple
                            : Color.white.opacity(0.12),
                            lineWidth: 1
                        )
                }
        }
    }
}

// MARK: - File Picker Row

private struct FilePickerRow: View {
    let label: String
    let fileName: String
    let onTap: () -> Void
    private let purple = Color(red: 0.45, green: 0.35, blue: 0.90)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.70))
            HStack(spacing: 0) {
                Button(action: onTap) {
                    Text("Choose File")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(purple, lineWidth: 1.5)
                        }
                }
                .buttonStyle(.plain)
                .padding(.leading, 10)

                Text(fileName.isEmpty ? "No File Chosen" : fileName)
                    .font(.system(size: 13))
                    .foregroundColor(fileName.isEmpty ? .white.opacity(0.35) : .white.opacity(0.75))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.horizontal, 12)
                Spacer()
            }
            .frame(height: 50)
            .background(Color(red: 0.12, green: 0.15, blue: 0.22))
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
        }
    }
}

// MARK: - Preview

#Preview("Basic") {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ApplyPlanSheet(plan: .basic, viewModel: LimitsViewModel())
        }
}

#Preview("Business") {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ApplyPlanSheet(plan: .business, viewModel: LimitsViewModel())
        }
}
