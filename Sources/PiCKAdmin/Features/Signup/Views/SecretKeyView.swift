import SwiftUI

struct SecretKeyView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = SecretKeyViewModel()

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

                Text("PiCK Admin의 시크릿 키를 입력해주세요.")
                    .pickText(type: .body1, textColor: .Gray.gray600)
            }
            .padding(.top, 58)
            .padding(.leading, 24)

            PiCKTextField(
                text: $viewModel.secretKey,
                placeholder: "시크릿 키를 입력해주세요",
                titleText: "시크릿 키"
            )
            .padding(.horizontal, 24)
            .padding(.top, 50)

            Spacer()

            PiCKButton(
                buttonText: "다음",
                isEnabled: !viewModel.secretKey.isEmpty,
                isLoading: viewModel.isLoading,
                action: {
                    Task {
                        await viewModel.checkSecretKey()
                    }
                }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .hideKeyboardOnTap()
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: viewModel.isSecretKeyValid) { _, isValid in
            if isValid {
                router.navigate(to: .email(secretKey: viewModel.secretKey))
            }
        }
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
