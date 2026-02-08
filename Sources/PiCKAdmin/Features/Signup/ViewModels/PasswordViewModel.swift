import Foundation
import Observation

@Observable
public final class PasswordViewModel {
    public var password = ""
    public var passwordConfirm = ""
    public var errorMessage: String?
    public var isPasswordValid = false
    
    public init() {}
    
    public var isFormValid: Bool {
        !password.isEmpty && !passwordConfirm.isEmpty
    }
    
    public func validatePassword() {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&()])[A-Za-z\\d!@#$%^&()]{8,30}$"
        let isMatched = password.range(of: passwordRegex, options: .regularExpression) != nil

        if password != passwordConfirm {
            errorMessage = "비밀번호가 일치하지 않습니다"
        } else if !isMatched {
            errorMessage = "8~30자 영문자, 숫자, 특수문자를 포함해주세요"
        } else {
            isPasswordValid = true
        }
    }
}