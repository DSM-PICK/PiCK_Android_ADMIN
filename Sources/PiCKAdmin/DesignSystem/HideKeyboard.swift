import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.background(
            Color.white.opacity(0.001)
                .onTapGesture {
                    #if os(iOS)
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                    #endif
                }
        )
    }
}
