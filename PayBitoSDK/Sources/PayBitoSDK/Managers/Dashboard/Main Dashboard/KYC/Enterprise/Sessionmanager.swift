import Foundation

// MARK: - SessionManager
/// Persists session credentials to UserDefaults.
/// Call `SessionManager.shared.save(...)` after a successful login response,
/// and `SessionManager.shared.clear()` on logout.
final class SessionManager {

    static let shared = SessionManager()
    private init() {}

    // MARK: - UserDefaults Keys
    private enum Key {
        static let adminUserId = "kSessionAdminUserId"
        static let uuid        = "kSessionUUID"
        static let bearerToken = "kSessionBearerToken"
        static let userId      = "kSessionUserId"
        static let userName    = "kSessionUserName"
        static let userEmail   = "kSessionUserEmail"
    }

    private let defaults = UserDefaults.standard

    // MARK: - Accessors

    var adminUserId: String {
        get { defaults.string(forKey: Key.adminUserId) ?? defaults.string(forKey: "Bmerchant_id") ?? "" }
        set {
            defaults.set(newValue, forKey: Key.adminUserId)
            print("🔐 [SessionManager] adminUserId saved: \(newValue)")
        }
    }

    var uuid: String {
        get { defaults.string(forKey: Key.uuid) ?? defaults.string(forKey: "Buuid") ?? "" }
        set {
            defaults.set(newValue, forKey: Key.uuid)
            print("🔐 [SessionManager] uuid saved: \(newValue)")
        }
    }

    var bearerToken: String {
        get { defaults.string(forKey: Key.bearerToken) ?? "" }
        set {
            defaults.set(newValue, forKey: Key.bearerToken)
            // Mirror into AuthTokenManager so the service layer picks it up
            AuthTokenManager.shared.setToken(newValue)
            print("🔐 [SessionManager] bearerToken saved")
        }
    }

    var userId: String {
        get { defaults.string(forKey: Key.userId) ?? "" }
        set { defaults.set(newValue, forKey: Key.userId) }
    }

    var userName: String {
        get { defaults.string(forKey: Key.userName) ?? "" }
        set { defaults.set(newValue, forKey: Key.userName) }
    }

    var userEmail: String {
        get { defaults.string(forKey: Key.userEmail) ?? "" }
        set { defaults.set(newValue, forKey: Key.userEmail) }
    }

    /// Returns true when a valid session exists (token is non-empty).
    var isLoggedIn: Bool {
        !bearerToken.isEmpty && !adminUserId.isEmpty
    }

    // MARK: - Convenience Save
    /// Call this right after a successful login API response.
    func save(
        adminUserId: String,
        uuid: String,
        bearerToken: String,
        userId: String = "",
        userName: String = "",
        userEmail: String = ""
    ) {
        self.adminUserId  = adminUserId
        self.uuid         = uuid
        self.bearerToken  = bearerToken
        self.userId       = userId
        self.userName     = userName
        self.userEmail    = userEmail
        print("✅ [SessionManager] Session saved — adminUser=\(adminUserId) uuid=\(uuid)")
    }

    // MARK: - Clear on Logout
    func clear() {
        [Key.adminUserId, Key.uuid, Key.bearerToken,
         Key.userId, Key.userName, Key.userEmail].forEach {
            defaults.removeObject(forKey: $0)
        }
        AuthTokenManager.shared.clearToken()
        print("🚪 [SessionManager] Session cleared")
    }
}
