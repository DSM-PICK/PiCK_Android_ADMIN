import SwiftUI

struct EmailVerifyView: View {
    let secretKey: String
    @State private var viewModel = EmailVerifyViewModel()
    @Environment(\.appRouter) var router: AppRouter

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            PiCKTextField(
                text: $viewModel.email,
                placeholder: "학교 이메일을 입력해주세요",
                titleText: "이메일",
                showVerification: true,
                verificationButtonTapped: {
                    Task {
                        await viewModel.sendEmail()
                    }
                }
            )
            .padding(.horizontal, 24)
            .padding(.top, 50)

            PiCKTextField(
                text: $viewModel.code,
                placeholder: "인증 코드를 입력해주세요",
                titleText: "인증 코드"
            )
            .padding(.horizontal, 24)
            .padding(.top, 44)

            Spacer()

            PiCKButton(
                buttonText: "다음",
                isEnabled: !viewModel.email.isEmpty && !viewModel.code.isEmpty,
                isLoading: viewModel.isLoading,
                action: {
                    Task {
                        await viewModel.verifyCode()
                    }
                }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .hideKeyboardOnTap()
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: viewModel.isCodeVerified) { _, isVerified in
            if isVerified {
                router.navigate(to: .password(
                    secretKey: secretKey,
                    accountId: viewModel.email + "@dsm.hs.kr",
                    code: viewModel.code
                ))
            }
        }
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
                Text("에 회원가입하기")
            }
            .pickText(type: .heading2)

            Text("DSM 이메일로 인증해주세요.")
                .pickText(type: .body1, textColor: .Gray.gray600)
        }
        .padding(.top, 80)
        .padding(.leading, 24)
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
