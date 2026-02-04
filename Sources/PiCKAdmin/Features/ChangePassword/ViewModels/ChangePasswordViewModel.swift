import Foundation
import Observation
import SwiftUI

@Observable
public final class ChangePasswordViewModel {
    public var email: String = ""
    public var code: String = ""
    public var isVerificationSent: Bool = false
    public var errorMessage: String?
    public var successMessage: String?
    public var navigateToNewPassword: Bool = false
    
    public init() {}
    
    @MainActor
    public func sendVerificationCode() async {
        guard !email.isEmpty else {
            errorMessage = "이메일을 입력해주세요"
            return
        }
        
        errorMessage = nil
        
        do {
            try await APIClient.shared.requestVoid(
                MailAPI.emailSend(email: email)
            )
            isVerificationSent = true
            successMessage = "이메일로 코드가 전송되었어요!"
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "이메일 전송에 실패했습니다"
        }
    }
    
    @MainActor
    public func verifyCode() async {
        guard !email.isEmpty && !code.isEmpty else {
            errorMessage = "모든 필드를 입력해주세요"
            return
        }
        
        errorMessage = nil
        
        do {
            try await APIClient.shared.requestVoid(
                MailAPI.codeCheck(email: email, code: code)
            )
            navigateToNewPassword = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "인증에 실패했습니다"
        }
    }
}
