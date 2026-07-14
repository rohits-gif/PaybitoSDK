import SwiftUI
import PhotosUI
import UIKit

struct ProfileView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ProfileViewModel()

    @State private var photosItem: PhotosPickerItem?
    @State private var showPhotoOptions = false
    @State private var showCamera = false

    // MARK: - Computed

    private var fullName: String {
        let name = "\(vm.firstName) \(vm.lastName)"
            .trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "—" : name
    }

    private var initials: String {
        let parts = fullName.split(separator: " ")
        return parts.prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }

    // MARK: - UI

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.bbDarkBG.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerRow

                    avatarCard
                        .padding(.horizontal, 16)
                        .padding(.top, 20)

                    contactCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    businessCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    accountCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    Spacer().frame(height: 100)
                }
            }

            // FAB
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.bbAccentBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color.bbAccentBlue.opacity(0.5),
                            radius: 12,
                            x: 0,
                            y: 6)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 28)

            // Loader
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: .white)
                    )
            }
        }
        .onAppear {
            vm.fetchProfile()
        }

        // Photo selection from gallery
        .onChange(of: photosItem) { newItem in
            guard let newItem else { return }

            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    uploadImage(uiImage)
                }
            }
        }

        // Bottom sheet options
        .confirmationDialog(
            "Profile Photo",
            isPresented: $showPhotoOptions,
            titleVisibility: .visible
        ) {
            Button("Take Photo") {
                showCamera = true
            }

            PhotosPicker(
                selection: $photosItem,
                matching: .images
            ) {
                Text("Choose from Gallery")
            }

            Button("Cancel", role: .cancel) { }
        }

        // Camera sheet
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                uploadImage(image)
            }
        }

        .onChange(of: vm.uploadSuccess) { success in
            guard let success else { return }

            if success {
                print("🎉 Upload success")
            } else {
                print("💥 Upload failed")
            }
        }
    }

    // MARK: - Upload Helper

    private func uploadImage(_ image: UIImage) {
        let uuid = UserDefaults.standard.string(forKey: "Buuid") ?? ""
        vm.uploadProfileImage(image, uuid: uuid)
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Profile")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("View and manage your account information")
                    .font(.system(size: 12))
                    .foregroundColor(Color.bbLabelGray)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 4)
    }

    // MARK: - Avatar Card

    private var avatarCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bbCardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.bbBorder, lineWidth: 1)
                )

            VStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {

                    if let image = vm.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(red: 0.45,
                                        green: 0.35,
                                        blue: 0.85))
                            .frame(width: 90, height: 90)
                            .overlay(
                                Text(initials.isEmpty ? "?" : initials)
                                    .font(.system(size: 32,
                                                  weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }

                    // Camera button
                    Button {
                        showPhotoOptions = true
                    } label: {
                        Circle()
                            .fill(Color(red: 0.10,
                                        green: 0.12,
                                        blue: 0.20))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            )
                    }
                    .offset(x: 2, y: 2)
                }
                .padding(.top, 20)

                Text(fullName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text(vm.organization.isEmpty ? "—" : vm.organization)
                    .font(.system(size: 13))
                    .foregroundColor(Color.bbLabelGray)

                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.system(size: 12))

                    Text("ID: \(vm.merchantId)")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(Color(red: 0.18,
                                  green: 0.22,
                                  blue: 0.36))
                .cornerRadius(20)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Contact Card

    private var contactCard: some View {
        ProfileSectionCard(
            icon: "creditcard.fill",
            title: "Contact Information",
            borderColor: .bbAccentBlue
        ) {
            ProfileRow(label: "Email", value: vm.email)
            BBDivider()
            ProfileRow(label: "Phone", value: vm.phone)
            BBDivider()
            ProfileRow(label: "Country") {
                CountryBadge(text: vm.country.isEmpty ? "—" : vm.country)
            }
        }
    }

    // MARK: - Business Card

    private var businessCard: some View {
        ProfileSectionCard(
            icon: "building.columns.fill",
            title: "Business Address Details",
            borderColor: Color.bbAccentGreen
        ) {
            ProfileRow(label: "Address", value: vm.address)
            BBDivider()
            ProfileRow(label: "City", value: vm.city)
            BBDivider()
            ProfileRow(label: "State", value: vm.state)
            BBDivider()
            ProfileRow(label: "Zip Code", value: vm.zip)
            BBDivider()
            ProfileRow(label: "Country") {
                CountryBadge(text: vm.country.isEmpty ? "—" : vm.country)
            }
        }
    }

    // MARK: - Account Card

    private var accountCard: some View {
        ProfileSectionCard(
            icon: "shield.fill",
            title: "Account Details",
            borderColor: Color.orange
        ) {
            ProfileRow(label: "Merchant ID", value: vm.merchantId)
            BBDivider()
            ProfileRow(label: "Organization", value: vm.organization)
            BBDivider()
            ProfileRow(label: "Member Since", value: vm.memberSince)
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {

    var sourceType: UIImagePickerController.SourceType
    var completion: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context)
    -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate {

        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info:
            [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.completion(image)
            }

            parent.dismiss()
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            parent.dismiss()
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Reusable Components

private struct ProfileSectionCard<Content: View>: View {
    let icon: String
    let title: String
    let borderColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.white)

                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()
            .background(Color.bbCardBG)

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal)
        }
        .background(Color.bbCardBG)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: 1.5)
        )
    }
}

private struct ProfileRow<Content: View>: View {
    let label: String
    let content: () -> Content

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(Color.bbLabelGray)

            Spacer()

            content()
        }
        .padding(.vertical, 14)
    }

    init(label: String,
         @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
}

extension ProfileRow where Content == AnyView {
    init(label: String, value: String) {
        self.label = label
        self.content = {
            AnyView(
                Text(value.isEmpty ? "—" : value)
                    .foregroundColor(.white)
            )
        }
    }
}

private struct CountryBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 7)
            .background(Color.green)
            .cornerRadius(20)
    }
}

#Preview {
    ProfileView()
}
