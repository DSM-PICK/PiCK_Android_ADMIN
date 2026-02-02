import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack {
            Spacer()

            // Logo
            VStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.Primary.primary500)

                Text("PiCK Admin")
                    .pickText(type: .heading1, textColor: .Primary.primary500)
            }

            Spacer()

            PiCKButton(
                buttonText: "로그인",
                action: {
                    withAnimation(.easeOut(duration: 0.35)) {
                        router.navigate(to: .signin)
                    }
                }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }
}
