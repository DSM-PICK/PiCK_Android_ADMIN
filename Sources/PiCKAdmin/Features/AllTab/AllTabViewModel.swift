import Foundation
import Observation
import SwiftUI

struct MyNameDTO: Decodable {
    let name: String
    let grade: Int
    let classNum: Int
}

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
        // Router logic will be handled in View or AppRouter
    }
    
    @MainActor
    public func resign() async {
        // Implement resign API logic if needed
        JwtStore.shared.clearTokens()
    }
}
