import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = ChangePasswordViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            
            emailTextField
            
            codeTextField

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
        .onChange(of: viewModel.navigateToNewPassword) { _, navigate in
            if navigate {
                router.navigate(to: .newPassword(accountId: viewModel.email, code: viewModel.code))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("비밀번호 변경")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    router.pop()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.Normal.black)
                }
            }
        }
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

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text("PiCK")
                    .foregroundColor(Color.Primary.primary500)
                Text("에 인증하기")
            }
            .pickText(type: .heading2)

            Text("DSM 이메일로 인증 해주세요.")
                .pickText(type: .body1, textColor: .Gray.gray600)
        }
        .padding(.top, 58)
        .padding(.leading, 24)
    }

    private var emailTextField: some View {
        PiCKTextField(
            text: $viewModel.email,
            placeholder: "학교 이메일을 입력해주세요",
            titleText: "이메일",
            showVerification: true,
            verificationButtonTapped: {
                Task {
                    await viewModel.sendVerificationCode()
                }
            }
        )
        .padding(.horizontal, 24)
        .padding(.top, 50)
    }

    private var codeTextField: some View {
        PiCKTextField(
            text: $viewModel.code,
            placeholder: "인증 코드를 입력해주세요",
            titleText: "인증 코드"
        )
        .padding(.horizontal, 24)
        .padding(.top, 44)
    }

    private var nextButton: some View {
        PiCKButton(
            buttonText: "다음",
            isEnabled: !viewModel.email.isEmpty && !viewModel.code.isEmpty,
            action: { 
                Task {
                    await viewModel.verifyCode() 
                }
            }
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}
