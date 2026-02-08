import Foundation
import Observation

@Observable
public final class EmailVerifyViewModel {
    public var email: String = ""
    public var code: String = ""
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var isCodeVerified: Bool = false
    public var isEmailSent: Bool = false
    
    public init() {}
    
    @MainActor
    public func sendEmail() async {
        guard !email.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIClient.shared.requestVoid(
                MailAPI.emailSend(email: email + "@dsm.hs.kr", title: "회원가입 인증", message: "회원가입 인증")
            )
            isEmailSent = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "인증 코드 전송에 실패했습니다"
        }
        
        isLoading = false
    }
    
    @MainActor
    public func verifyCode() async {
        guard !email.isEmpty && !code.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIClient.shared.requestVoid(
                MailAPI.codeCheck(email: email + "@dsm.hs.kr", code: code)
            )
            isCodeVerified = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "인증 코드 확인에 실패했습니다"
        }
        
        isLoading = false
    }
}
