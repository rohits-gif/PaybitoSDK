////
////  AddBuyerInfoView.swift
////  Trading_Terminal
////
////  Created by Sk Jasimuddin on 14/04/26.
////
//
//import SwiftUI
//
//    struct AddBuyerInfoView: View {
//        
//        @Environment(\.dismiss) private var dismiss
//        
//        @State private var profileName: String = ""
//        
//        @State private var fullName = false
//        @State private var shippingAddress = false
//        @State private var phoneNumber = false
//        @State private var companyName = false
//        @State private var taxId = false
//        @State private var cryptoAddress = false
//        @State private var orderNotes = false
//        
//        private let bgGradient = LinearGradient(
//            colors: [
//                Color(red: 0.05, green: 0.07, blue: 0.12),
//                Color(red: 0.02, green: 0.04, blue: 0.08)
//            ],
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        
//        private let cardBg = Color(red: 0.10, green: 0.12, blue: 0.18)
//        private let borderColor = Color.white.opacity(0.08)
//        private let purple = Color(red: 0.60, green: 0.35, blue: 0.95)
//        private let subtitleColor = Color.gray.opacity(0.7)
//        
//        var body: some View {
//            ZStack {
//                bgGradient.ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    
//                    // HEADER
//                    HStack(spacing: 12) {
//                        Button(action: { dismiss() }) {
//                            Image(systemName: "chevron.left")
//                                .foregroundColor(.white)
//                        }
//                        
//                        Image(systemName: "plus")
//                            .foregroundColor(purple)
//                        
//                        Text("New Buyer Info Profile")
//                            .font(.system(size: 18, weight: .bold))
//                            .foregroundColor(.white)
//                        
//                        Spacer()
//                    }
//                    .padding(16)
//                    
//                    Divider().background(Color.white.opacity(0.1))
//                    
//                    // CONTENT
//                    ScrollView {
//                        VStack(alignment: .leading, spacing: 20) {
//                            
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("PROFILE NAME *")
//                                    .font(.system(size: 11, weight: .semibold))
//                                    .foregroundColor(.gray)
//                                
//                                TextField("", text: $profileName)
//                                    .overlay(
//                                        Group {
//                                            if profileName.isEmpty {
//                                                Text("e.g. Standard Checkout Form")
//                                                    .foregroundColor(subtitleColor)
//                                                    .padding(.leading, 12)
//                                            }
//                                        },
//                                        alignment: .leading
//                                    )
//                                    .padding()
//                                    .background(Color.white.opacity(0.08))
//                                    .cornerRadius(10)
//                                    .foregroundColor(.white)
//                            }
//                            
//                            HStack {
//                                Circle().fill(purple).frame(width: 8, height: 8)
//                                Text("Standard Fields")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 14, weight: .semibold))
//                            }
//                            
//                            fieldCard("envelope", "Email Address", "Used for order confirmation", true, .constant(true))
//                            fieldCard("person", "Full Name", "Buyer's full legal name", false, $fullName)
//                            fieldCard("location", "Shipping Address", "Street, city, state, country, ZIP", false, $shippingAddress)
//                            fieldCard("phone", "Phone Number", "Contact number for delivery", false, $phoneNumber)
//                            fieldCard("building.2", "Company Name", "Business name (if applicable)", false, $companyName)
//                            fieldCard("doc.text", "Tax ID / VAT Number", "For business invoicing", false, $taxId)
//                            fieldCard("creditcard", "Crypto Refund Address", "For potential refunds in crypto", false, $cryptoAddress)
//                            fieldCard("pencil", "Order Notes", "Additional instructions from buyer", false, $orderNotes)
//                            
//                            HStack {
//                                Image(systemName: "plus.circle").foregroundColor(purple)
//                                Text("Custom Fields").foregroundColor(.white)
//                                Spacer()
//                                Text("0").foregroundColor(purple)
//                                Button("+ Add Field") {}
//                                    .foregroundColor(purple)
//                            }
//                            
//                            Text("No custom fields yet — add up to 3")
//                                .foregroundColor(subtitleColor)
//                                .font(.system(size: 12))
//                                .frame(maxWidth: .infinity, alignment: .center)
//                            
//                            Spacer(minLength: 100)
//                        }
//                        .padding(16)
//                    }
//                    
//                    // BUTTONS
//                    HStack(spacing: 12) {
//                        
//                        Button("Cancel") {
//                            dismiss()
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 25)
//                                .stroke(purple, lineWidth: 1.5)
//                        )
//                        .foregroundColor(.white)
//                        
//                        Button(action: {}) {
//                            HStack {
//                                Image(systemName: "checkmark")
//                                Text("Save Profile")
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(
//                                LinearGradient(
//                                    colors: [purple, Color.blue],
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//                            .cornerRadius(25)
//                        }
//                        .foregroundColor(.white)
//                    }
//                    .padding(16)
//                    .background(Color.black.opacity(0.2))
//                }
//            }
//            .navigationBarHidden(true)
//        }
//        
//        // FIELD CARD
//        func fieldCard(_ icon: String, _ title: String, _ subtitle: String, _ isRequired: Bool, _ isOn: Binding<Bool>) -> some View {
//            HStack {
//                Image(systemName: icon)
//                    .foregroundColor(.white.opacity(0.8))
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    HStack(spacing: 6) {
//                        Text(title).foregroundColor(.white)
//                        if isRequired {
//                            Text("REQUIRED")
//                                .foregroundColor(purple)
//                                .font(.system(size: 10, weight: .bold))
//                        }
//                    }
//                    Text(subtitle)
//                        .foregroundColor(subtitleColor)
//                        .font(.system(size: 12))
//                }
//                
//                Spacer()
//                
//                Toggle("", isOn: isOn)
//                    .toggleStyle(SwitchToggleStyle(tint: purple))
//            }
//            .padding()
//            .background(cardBg)
//            .cornerRadius(14)
//            .overlay(
//                RoundedRectangle(cornerRadius: 14)
//                    .stroke(borderColor)
//            )
//        }
//    }
//
//    #Preview {
//        AddBuyerInfoView()
//    }





// MARK: - AddEditBuyerInfoView.swift
// Form screen — mirrors React's ProfileForm + Add/Edit card exactly
import SwiftUI

enum BuyerInfoMode {
    case add
    case edit(BuyerInfoProfile)
}

struct AddEditBuyerInfoView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: AddEditBuyerInfoViewModel

    private let purple = Color(r: 0.60, g: 0.35, b: 0.95)
    private let blue   = Color(r: 0.20, g: 0.55, b: 0.95)
    private let cardBg = Color(r: 0.10, g: 0.12, b: 0.18)

    private let bg = LinearGradient(
        colors: [
            Color(r: 0.05, g: 0.07, b: 0.12),
            Color(r: 0.02, g: 0.04, b: 0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    init(mode: BuyerInfoMode) {
        switch mode {
        case .add:
            _vm = StateObject(wrappedValue: AddEditBuyerInfoViewModel())

        case .edit(let profile):
            _vm = StateObject(
                wrappedValue: AddEditBuyerInfoViewModel(editing: profile)
            )
        }
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                Divider()
                    .background(Color.white.opacity(0.08))

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        profileNameField
                        standardFieldsSection

                        Divider()
                            .background(Color.white.opacity(0.08))

                        customFieldsSection
                        defaultProfileToggle

                        Spacer(minLength: 100)
                    }
                    .padding(16)
                }

                bottomButtons
            }

            if let t = vm.toast {
                ToastView(
                    message: t.message,
                    isSuccess: t.isSuccess
                )
            }
        }
        .navigationBarHidden(true)
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(purple.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: vm.isEditing ? "square.and.pencil" : "plus")
                    .foregroundColor(purple)
            }

            Text(vm.isEditing ? "Edit Buyer Info Profile" : "New Buyer Info Profile")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(16)
    }

    private var profileNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PROFILE NAME *")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)

            ZStack(alignment: .leading) {
                if vm.profileName.isEmpty {
                    Text("e.g. Standard Checkout Form")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal, 14)
                }

                TextField("", text: $vm.profileName)
                    .foregroundColor(.white)
                    .padding(14)
                    .onChange(of: vm.profileName) { _ in
                        vm.clearNameError()
                    }
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        vm.nameError.isEmpty
                        ? Color.clear
                        : Color.red,
                        lineWidth: 1
                    )
            )

            if !vm.nameError.isEmpty {
                Text(vm.nameError)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
    }

    private var standardFieldsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(purple)
                    .frame(width: 8, height: 8)

                Text("Standard Fields")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            ForEach($vm.stdFields) { $field in
                StdFieldRow(
                    field: $field,
                    purple: purple,
                    cardBg: cardBg
                )
            }
        }
    }

    private var customFieldsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .foregroundColor(purple)

                Text("Custom Fields")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                if !vm.customFields.isEmpty {
                    Text("\(vm.customFields.count)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(purple)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(purple.opacity(0.12))
                        .cornerRadius(6)
                }

                Spacer()

                if vm.customFields.count < vm.maxCustomFields {
                    Button {
                        withAnimation {
                            vm.addCustomField()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add Field")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                }
            }

            if vm.customFields.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "text.cursor")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.3))

                    Text("No custom fields yet — add up to \(vm.maxCustomFields)")
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.white.opacity(0.04))
                .cornerRadius(12)
            }

            ForEach(vm.customFields.indices, id: \.self) { idx in
                CustomFieldRow(
                    field: $vm.customFields[idx],
                    index: idx,
                    isExpanded: vm.expandedCustomIndex == idx,
                    fieldTypes: vm.fieldTypes,
                    purple: purple,
                    cardBg: cardBg,
                    onToggle: {
                        vm.toggleExpandCustom(at: idx)
                    },
                    onRemove: {
                        vm.removeCustomField(at: idx)
                    }
                )
            }
        }
    }

    private var defaultProfileToggle: some View {
        HStack(spacing: 16) {
            Toggle("", isOn: $vm.isDefaultProfile)
                .toggleStyle(SwitchToggleStyle(tint: purple))
                .labelsHidden()

            VStack(alignment: .leading, spacing: 2) {
                Text("Set as Default Profile")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text("This profile will be pre-selected at checkout")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.7))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            Button("Cancel") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(purple, lineWidth: 1.5)
            )
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .semibold))

            Button {
                vm.save {
                    dismiss()
                }
            } label: {
                if vm.isSaving {
                    ProgressView()
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("Save Profile")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [purple, blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .semibold))
            .cornerRadius(25)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct StdFieldRow: View {
    @Binding var field: StdField
    let purple: Color
    let cardBg: Color

    var body: some View {
        HStack {
            Image(systemName: field.icon)
                .foregroundColor(.white)

            VStack(alignment: .leading) {
                Text(field.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                Text(field.helpText)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            if !field.locked {
                Toggle("", isOn: $field.enabled)
                    .labelsHidden()
            }
        }
        .padding()
        .background(cardBg)
        .cornerRadius(12)
    }
}

struct CustomFieldRow: View {
    @Binding var field: CustomField
    let index: Int
    let isExpanded: Bool
    let fieldTypes: [String]
    let purple: Color
    let cardBg: Color
    let onToggle: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(purple.opacity(0.15))
                            .frame(width: 28, height: 28)

                        Image(systemName: "pencil")
                            .foregroundColor(purple)
                            .font(.system(size: 12))
                    }

                    Text(field.label.isEmpty ? "Untitled Field" : field.label)
                        .foregroundColor(field.label.isEmpty ? .gray : .white)
                        .font(.system(size: 13, weight: .semibold))
                }

                Spacer()

                Button(action: onToggle) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.6))
                }

                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding(12)

            if isExpanded {
                Divider().background(Color.white.opacity(0.08))

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            Text("FIELD LABEL *")
                                .font(.caption2)
                                .foregroundColor(.gray)

                            TextField(
                                "e.g. Company Registration No.",
                                text: $field.label
                            )
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        }

                        VStack(alignment: .leading) {
                            Text("FIELD TYPE")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.65))

                            Picker("", selection: $field.type) {
                                ForEach(fieldTypes, id: \.self) {
                                    Text($0.capitalized).tag($0)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }

                    HStack(spacing: 12) {
                        TextField("Hint text for buyers", text: $field.placeholder)
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        TextField("Shown below field", text: $field.helpText)
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
                .padding(12)
            }
        }
        .background(cardBg)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08))
        )
    }
}
#Preview {
    AddEditBuyerInfoView(mode: .add)
}
