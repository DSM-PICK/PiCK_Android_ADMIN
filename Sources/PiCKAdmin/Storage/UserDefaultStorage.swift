import Foundation

public enum UserDefaultKey: String {
    case hasLaunchedBefore
    case deviceToken
    case accessToken
    case refreshToken
}

public final class UserDefaultStorage: @unchecked Sendable {
    public static let shared = UserDefaultStorage()

    private let defaults = UserDefaults.standard

    private init() {}

    public func set<T>(to value: T, forKey key: UserDefaultKey) {
        defaults.set(value, forKey: key.rawValue)
    }

    public func get<T>(forKey key: UserDefaultKey) -> T? {
        return defaults.object(forKey: key.rawValue) as? T
    }

    public func remove(forKey key: UserDefaultKey) {
        defaults.removeObject(forKey: key.rawValue)
    }

    public func getString(forKey key: UserDefaultKey) -> String? {
        return defaults.string(forKey: key.rawValue)
    }

    public func getBool(forKey key: UserDefaultKey) -> Bool {
        return defaults.bool(forKey: key.rawValue)
    }
}
