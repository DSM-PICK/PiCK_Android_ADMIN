import SwiftUI

public struct PiCKButton: View {
    public var buttonText: String
    public var isEnabled: Bool
    public var isLoading: Bool
    public var height: CGFloat
    public var action: () -> Void

    public init(
        buttonText: String = "",
        isEnabled: Bool = true,
        isLoading: Bool = false,
        height: CGFloat = 47,
        action: @escaping () -> Void = {}
    ) {
        self.buttonText = buttonText
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.height = height
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Text(buttonText)
                    .pickText(type: .button1, textColor: .Normal.white)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .disabled(!isEnabled || isLoading)
    }

    private var backgroundColor: Color {
        (isEnabled && !isLoading) ? .Primary.primary500 : .Primary.primary100
    }
}

public struct UnderLineButton: View {
    public var prefixText: String
    public var buttonText: String
    public var action: () -> Void

    public init(
        prefixText: String = "",
        buttonText: String = "",
        action: @escaping () -> Void = {}
    ) {
        self.prefixText = prefixText
        self.buttonText = buttonText
        self.action = action
    }

    public var body: some View {
        HStack(spacing: 0) {
            Text(prefixText)
                .pickText(type: .body2, textColor: .Gray.gray600)

            Button(action: action) {
                Text(buttonText)
                    .pickText(type: .body2, textColor: .Primary.primary500)
                    .underline()
            }
        }
    }
}
