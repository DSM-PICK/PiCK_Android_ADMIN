import SwiftUI

struct SigninView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = SigninViewModel()
    @State var emailText: String = ""
    @State var passwordText: String = ""
    @State var dismissCount: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            PiCKTextField(
                text: $emailText,
                placeholder: "학교 이메일을 입력해주세요",
                titleText: "이메일",
                showEmail: true,
                dismissTrigger: dismissCount
            )
            .padding(.horizontal, 24)
            .padding(.top, 50)

            PiCKTextField(
                text: $passwordText,
                placeholder: "비밀번호를 입력해주세요",
                titleText: "비밀번호",
                isSecurity: true,
                dismissTrigger: dismissCount
            )
            .padding(.horizontal, 24)
            .padding(.top, 44)

            forgotPasswordLinkSection
            Spacer()
            signupLinkSection
            signinButton
        }
        .onTapGesture { dismissCount += 1 }
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationBarBackButtonHidden(true)
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    router.pop()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.Normal.black)
                }
            }
        }
        #endif
        .overlay(alignment: .top) {
            if viewModel.errorMessage != nil {
                errorToast
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text("PiCK")
                    .foregroundColor(.Primary.primary500)
                Text("에 로그인하기")
            }
            .pickText(type: .heading2)

            Text("PiCK 계정으로 로그인 해주세요.")
                .pickText(type: .body1, textColor: .Gray.gray600)
        }
        .padding(.top, 80)
        .padding(.leading, 24)
    }

    private var forgotPasswordLinkSection: some View {
        UnderLineButton(
            prefixText: "비밀번호를 잊어버리셨나요? ",
            buttonText: "비밀번호 변경",
            action: {
                router.navigate(to: .changePassword)
            }
        )
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 24)
        .padding(.top, 12)
    }

    private var signupLinkSection: some View {
        UnderLineButton(
            prefixText: "PiCK 계정이 없으세요? ",
            buttonText: "회원가입",
            action: {
                router.navigate(to: .secretKey)
            }
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    private var signinButton: some View {
        PiCKButton(
            buttonText: "로그인하기",
            isEnabled: !emailText.isEmpty && !passwordText.isEmpty,
            isLoading: viewModel.isLoading,
            action: {
                viewModel.email = emailText
                viewModel.password = passwordText
                Task {
                    await viewModel.signin()
                    if viewModel.isSigninSuccessful {
                        router.replace(with: .home)
                    }
                }
            }
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }

    private var errorToast: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.Error.error)
            Text(viewModel.errorMessage ?? "")
                .pickText(type: .body2, textColor: .Normal.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.Gray.gray800)
        .cornerRadius(8)
        .padding(.top, 60)
        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                withAnimation {
                    viewModel.errorMessage = nil
                }
            }
        }
    }
}
