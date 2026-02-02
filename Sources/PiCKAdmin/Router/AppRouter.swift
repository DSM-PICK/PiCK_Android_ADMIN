import SwiftUI
import Foundation

public final class AppRouter: ObservableObject {
    @Published public var path: [AppRoute] = []

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
