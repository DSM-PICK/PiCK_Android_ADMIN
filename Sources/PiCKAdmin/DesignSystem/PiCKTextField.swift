import SwiftUI

public struct PiCKTextField: View {
    @Binding public var text: String
    public var placeholder: String
    public var titleText: String?
    public var isSecurity: Bool
    public var showEmail: Bool
    public var showVerification: Bool
    public var errorMessage: String?
    public var verificationButtonTapped: (() -> Void)?

    @State var isSecure: Bool = false
    @State var isVerificationSent: Bool = false
    @State var remainingSeconds = 0
    @State var timerTask: Task<Void, Never>?
    @FocusState var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String = "",
        titleText: String? = nil,
        isSecurity: Bool = false,
        showEmail: Bool = false,
        showVerification: Bool = false,
        errorMessage: String? = nil,
        verificationButtonTapped: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.titleText = titleText
        self.isSecurity = isSecurity
        self.showEmail = showEmail
        self.showVerification = showVerification
        self.errorMessage = errorMessage
        self.verificationButtonTapped = verificationButtonTapped
        self._isSecure = State(initialValue: isSecurity)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let titleText = titleText {
                Text(titleText)
                    .pickText(type: .label1, textColor: .Normal.black)
            }

            HStack(spacing: 2) {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                        .pickText(type: .caption2, textColor: .Normal.black)
                        .textFieldStyle(.plain)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled(true)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .pickText(type: .caption2, textColor: .Normal.black)
                        .textFieldStyle(.plain)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled(true)
                }

                if isSecurity {
                    Button(action: {
                        isSecure.toggle()
                    }) {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                            .foregroundColor(.Gray.gray500)
                    }
                } else if showVerification {
                    Text("@dsm.hs.kr")
                        .pickText(type: .caption1, textColor: .Gray.gray500)

                    Button(action: {
                        verificationButtonTapped?()
                        startTimer()
                    }) {
                        Text(buttonText)
                            .pickText(type: .button2, textColor: .Primary.primary900)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.Primary.primary50)
                            .cornerRadius(5)
                    }
                    .disabled(text.isEmpty || remainingSeconds > 0)
                } else if showEmail {
                    Text("@dsm.hs.kr")
                        .pickText(type: .caption1, textColor: .Gray.gray500)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 51)
            .background(Color.Gray.gray50)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor, lineWidth: 1)
            )

            if let errorMessage = errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .pickText(type: .body1, textColor: .Error.error)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var borderColor: Color {
        if errorMessage != nil && !errorMessage!.isEmpty {
            return .Error.error
        } else if isFocused {
            return .Primary.primary500
        } else {
            return .clear
        }
    }

    private var buttonText: String {
        if remainingSeconds > 0 {
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        } else if isVerificationSent {
            return "재발송"
        } else {
            return "인증 코드"
        }
    }

    private func startTimer() {
        isVerificationSent = true
        remainingSeconds = 60

        timerTask = Task {
            while remainingSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled {
                    remainingSeconds -= 1
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
