import SwiftUI

struct PasswordView: View {
    let secretKey: String
    let accountId: String
    let code: String
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = PasswordViewModel()
    @State var passwordText: String = ""
    @State var passwordConfirmText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Text("회원가입")
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

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 0) {
                    Text("PiCK")
                        .foregroundColor(.Primary.primary500)
                    Text("에 회원가입하기")
                }
                .pickText(type: .heading2)

                Text("사용할 비밀번호를 입력해주세요.")
                    .pickText(type: .body1, textColor: .Gray.gray600)
            }
            .padding(.top, 58)
            .padding(.leading, 24)

            PiCKTextField(
                text: $passwordText,
                placeholder: "8~30자 영문자, 숫자, 특수문자 포함하세요",
                titleText: "비밀번호",
                isSecurity: true
            )
            .padding(.horizontal, 24)
            .padding(.top, 50)

            PiCKTextField(
                text: $passwordConfirmText,
                placeholder: "위에 입력한 비밀번호를 다시 입력해주세요",
                titleText: "비밀번호 확인",
                isSecurity: true
            )
            .padding(.horizontal, 24)
            .padding(.top, 44)

            Spacer()

            PiCKButton(
                buttonText: "다음",
                isEnabled: !passwordText.isEmpty && !passwordConfirmText.isEmpty,
                action: {
                    viewModel.password = passwordText
                    viewModel.passwordConfirm = passwordConfirmText
                    viewModel.validatePassword()
                    if viewModel.isPasswordValid {
                        router.navigate(to: .infoSetting(
                            secretKey: secretKey,
                            accountId: accountId,
                            code: code,
                            password: passwordText
                        ))
                    }
                }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .hideKeyboardOnTap()
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .overlay(alignment: .top) {
            if viewModel.errorMessage != nil {
                errorToast
            }
        }
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
