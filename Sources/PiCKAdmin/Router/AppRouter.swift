import Foundation
import Observation
import SwiftUI

@Observable
public final class AppRouter: @unchecked Sendable {
    public var path: [AppRoute] = []
    public var selectedTab: Int = 2

    public init() {
        NotificationCenter.default.addObserver(
            forName: .authSessionExpired,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            Task { @MainActor in
                self?.selectedTab = 2
                self?.replace(with: .signin)
            }
        }
    }

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

struct AppRouterKey: EnvironmentKey {
    static let defaultValue: AppRouter = AppRouter()
}

extension EnvironmentValues {
    var appRouter: AppRouter {
        get { self[AppRouterKey.self] }
        set { self[AppRouterKey.self] = newValue }
    }
}
