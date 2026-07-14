import Foundation
import Combine

final class BuyerInfoViewModel: ObservableObject {

    @Published var profiles: [BuyerInfoProfile] = []
    @Published var isLoading = false
    @Published var toast: ToastState? = nil
    @Published var deleteTarget: BuyerInfoProfile? = nil
    @Published var isDeleting = false
    @Published var isReadOnly = false

    private let service: BuyerInfoService

    init(service: BuyerInfoService = .shared) {
        self.service = service
    }

    // MARK: FETCH
    func fetchProfiles() {
        isLoading = true

        service.fetchAll { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let profiles):
                    self?.profiles = profiles

                case .failure(let error):
                    self?.toast = ToastState(
                        message: error.localizedDescription,
                        isSuccess: false
                    )
                }
            }
        }
    }

    // MARK: DELETE
    func confirmDelete() {
        guard !isReadOnly else {
            toast = ToastState(
                message: "You need write access to perform this operation",
                isSuccess: false
            )
            return
        }

        guard let target = deleteTarget else { return }

        isDeleting = true

        service.delete(id: target.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isDeleting = false

                switch result {
                case .success:
                    self?.toast = ToastState(
                        message: "Profile deleted",
                        isSuccess: true
                    )
                    self?.deleteTarget = nil
                    self?.fetchProfiles()

                case .failure(let error):
                    self?.toast = ToastState(
                        message: error.localizedDescription,
                        isSuccess: false
                    )
                }
            }
        }
    }

    func requestDelete(profile: BuyerInfoProfile) {
        deleteTarget = profile
    }

    func cancelDelete() {
        deleteTarget = nil
    }

    func clearToast() {
        toast = nil
    }
}

struct ToastState: Equatable {
    let message: String
    let isSuccess: Bool
}
