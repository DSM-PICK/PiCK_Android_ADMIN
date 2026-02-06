import SwiftUI

struct OnboardingView: View {
    @Environment(\.appRouter) var router: AppRouter

    var body: some View {
        VStack {
            Spacer()

            Image("adminLogo", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

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
