import Foundation

@MainActor
public final class SigninViewModel: ObservableObject {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isSigninSuccessful: Bool = false

    public init() {}

    public var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

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

    public func clearError() {
        errorMessage = nil
    }
}
