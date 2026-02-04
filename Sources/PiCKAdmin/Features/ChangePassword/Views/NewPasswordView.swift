import SwiftUI

struct NewPasswordView: View {
    let accountId: String
    let code: String
    var router: AppRouter
    @State var viewModel: NewPasswordViewModel
    @Environment(\.dismiss) var dismiss

    init(accountId: String, code: String, router: AppRouter) {
        self.accountId = accountId
        self.code = code
        self.router = router
        self._viewModel = State(initialValue: NewPasswordViewModel(accountId: accountId, code: code))
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            VStack(alignment: .leading, spacing: 0) {
                headerSection
                
                passwordTextField
                
                passwordCheckTextField

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .pickText(type: .body1, textColor: .Error.error)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }

                Spacer()
                nextButton
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: viewModel.isSuccess) { _, success in
            if success {
                JwtStore.shared.clearTokens()
                router.popToRoot()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .overlay(alignment: .top) {
             if let successMessage = viewModel.successMessage {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text(successMessage)
                            .pickText(type: .body1, textColor: .Normal.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.Primary.primary500)
                    .cornerRadius(8)
                    .padding(.top, 60)
                }
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewModel.successMessage = nil
                    }
                }
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: viewModel.successMessage)
    }

    private var navigationBar: some View {
        ZStack {
            Text("비밀번호 변경")
                .pickText(type: .subTitle1, textColor: .Normal.black)

            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.Normal.black)
                }
                .padding(.leading, 16)

                Spacer()
            }
        }
        .frame(height: 56)
        .background(Color.Normal.white)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text("새 비밀번호")
                    .foregroundColor(Color.Primary.primary500)
                Text("를 입력해주세요")
            }
            .pickText(type: .heading2)

            Text("새로운 비밀번호를 입력해주세요")
                .pickText(type: .body1, textColor: .Gray.gray600)
        }
        .padding(.top, 58)
        .padding(.leading, 24)
    }

    private var passwordTextField: some View {
        PiCKTextField(
            text: $viewModel.password,
            placeholder: "8~24자, 영문, 숫자, 특수문자",
            titleText: "비밀번호",
            isSecurity: true
        )
        .padding(.horizontal, 24)
        .padding(.top, 50)
    }
    
    private var passwordCheckTextField: some View {
        PiCKTextField(
            text: $viewModel.passwordCheck,
            placeholder: "비밀번호를 다시 입력해주세요",
            titleText: "비밀번호 확인",
            isSecurity: true
        )
        .padding(.horizontal, 24)
        .padding(.top, 44)
    }

    private var nextButton: some View {
        PiCKButton(
            buttonText: "확인",
            isEnabled: !viewModel.password.isEmpty && !viewModel.passwordCheck.isEmpty,
            action: { 
                Task {
                    await viewModel.changePassword() 
                }
            }
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}
