import SwiftUI
import Observation

@Observable
public final class AppRouter: @unchecked Sendable {
    public var path: [AppRoute] = []
    public var selectedTab: Int = 2

    public init() {}

    public func navigate(to route: AppRoute) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func replace(with route: AppRoute) {
        path = [route]
    }
}

// MARK: - Environment Key
struct AppRouterKey: EnvironmentKey {
    static let defaultValue: AppRouter = AppRouter()
}

extension EnvironmentValues {
    var appRouter: AppRouter {
        get { self[AppRouterKey.self] }
        set { self[AppRouterKey.self] = newValue }
    }
}
