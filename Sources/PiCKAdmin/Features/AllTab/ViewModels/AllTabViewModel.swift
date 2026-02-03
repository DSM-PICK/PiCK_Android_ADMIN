import Foundation
import Observation
import SwiftUI

@Observable
public final class AllTabViewModel {
    public var teacherName: String = "선생님"
    public var showLogoutAlert: Bool = false
    public var showResignAlert: Bool = false
    
    public init() {}
    
    @MainActor
    public func fetchMyName() async {
        do {
            let response = try await APIClient.shared.request(
                AdminAPI.getMyName(),
                responseType: MyNameDTO.self
            )
            self.teacherName = response.name
        } catch {
            print("Failed to fetch my name: \(error)")
        }
    }
    
    @MainActor
    public func logout() {
        JwtStore.shared.clearTokens()
    }
    
    @MainActor
    public func resign() async {
        do {
            try await APIClient.shared.requestVoid(AuthAPI.deleteAccount())
            JwtStore.shared.clearTokens()
        } catch {
            print("Failed to resign: \(error)")
        }
    }
}
