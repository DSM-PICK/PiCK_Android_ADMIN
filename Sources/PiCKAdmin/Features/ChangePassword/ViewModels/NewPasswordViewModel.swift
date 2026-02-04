import Foundation
import Observation
import SwiftUI

@Observable
public final class NewPasswordViewModel {
    public var password: String = ""
    public var passwordCheck: String = ""
    public var errorMessage: String?
    public var successMessage: String?
    public var isSuccess: Bool = false
    
    public let accountId: String
    public let code: String
    
    public init(accountId: String, code: String) {
        self.accountId = accountId
        self.code = code
    }
    
    @MainActor
    public func changePassword() async {
        guard !password.isEmpty && !passwordCheck.isEmpty else {
            errorMessage = "모든 필드를 입력해주세요"
            return
        }
        
        guard password == passwordCheck else {
            errorMessage = "비밀번호가 일치하지 않습니다"
            return
        }
        
        errorMessage = nil
        
        do {
            try await APIClient.shared.requestVoid(
                AuthAPI.changePassword(adminId: accountId, code: code, password: password)
            )
            successMessage = "비밀번호가 변경되었습니다"
            isSuccess = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "비밀번호 변경에 실패했습니다"
        }
    }
}
