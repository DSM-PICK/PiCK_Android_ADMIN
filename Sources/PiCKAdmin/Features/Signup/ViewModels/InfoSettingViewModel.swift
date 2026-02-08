import Foundation
import Observation

@Observable
public final class InfoSettingViewModel {
    public var name = ""
    public var selectedGrade = 0
    public var selectedClass = 0
    public var isTeacher = false
    public var showGradeClassPicker = false
    public var isLoading = false
    public var errorMessage: String?
    public var isSignupSuccessful = false
    
    public init() {}
    
    public var isFormValid: Bool {
        if name.isEmpty { return false }
        if isTeacher {
            return selectedGrade != 0 && selectedClass != 0
        }
        return true
    }
    
    @MainActor
    public func signup(secretKey: String, accountId: String, code: String, password: String) async {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let deviceToken = UserDefaultStorage.shared.getString(forKey: .deviceToken) ?? ""
            let response = try await APIClient.shared.request(
                AuthAPI.signup(
                    accountId: accountId,
                    password: password,
                    name: name,
                    grade: selectedGrade,
                    classNum: selectedClass,
                    code: code,
                    deviceToken: deviceToken,
                    secretKey: secretKey
                ),
                responseType: SigninResponse.self
            )

            JwtStore.shared.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )

            isSignupSuccessful = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "회원가입에 실패했습니다"
        }
        
        isLoading = false
    }
}
