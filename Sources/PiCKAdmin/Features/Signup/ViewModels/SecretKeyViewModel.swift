import Foundation
import Observation

@Observable
public final class SecretKeyViewModel {
    public var secretKey: String = ""
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var isSecretKeyValid: Bool = false
    
    public init() {}
    
    public var isFormValid: Bool {
        !secretKey.isEmpty
    }

    @MainActor
    public func checkSecretKey() async {
        guard !secretKey.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIClient.shared.requestVoid(
                AuthAPI.secretKey(secretKey: secretKey)
            )
            isSecretKeyValid = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "시크릿 키 확인에 실패했습니다"
        }
        
        isLoading = false
    }
}
