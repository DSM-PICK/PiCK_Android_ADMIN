import Foundation

public final class JwtStore: ObservableObject, @unchecked Sendable {
    public static let shared = JwtStore()

    private let storage = UserDefaultStorage.shared

    public var accessToken: String? {
        get { storage.getString(forKey: .accessToken) }
        set {
            if let value = newValue {
                storage.set(to: value, forKey: .accessToken)
            } else {
                storage.remove(forKey: .accessToken)
            }
        }
    }

    public var refreshToken: String? {
        get { storage.getString(forKey: .refreshToken) }
        set {
            if let value = newValue {
                storage.set(to: value, forKey: .refreshToken)
            } else {
                storage.remove(forKey: .refreshToken)
            }
        }
    }

    public var hasValidToken: Bool {
        guard let token = accessToken, !token.isEmpty else {
            return false
        }
        // TODO: Add JWT expiration check
        return true
    }

    private init() {}

    public func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    public func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }
}
