import Foundation
import Observation

@Observable
public final class SigninViewModel {
    public var email: String = ""
    public var password: String = ""
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var isSigninSuccessful: Bool = false

    public init() {}

    public var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    @MainActor
    public func signin() async {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIClient.shared.request(
                AuthAPI.signin(email: email, password: password),
                responseType: SigninResponse.self
            )

            JwtStore.shared.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )

            isSigninSuccessful = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "로그인에 실패했습니다"
        }

        isLoading = false
    }

    @MainActor
    public func clearError() {
        errorMessage = nil
    }
}
