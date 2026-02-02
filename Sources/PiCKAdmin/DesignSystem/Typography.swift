import SwiftUI

// MARK: - Text Type
public enum PiCKTextType {
    case heading1
    case heading2
    case heading3
    case body1
    case body2
    case caption1
    case caption2
    case label1
    case button1
    case button2

    var font: Font {
        switch self {
        case .heading1:
            return .system(size: 28, weight: .bold)
        case .heading2:
            return .system(size: 24, weight: .bold)
        case .heading3:
            return .system(size: 20, weight: .semibold)
        case .body1:
            return .system(size: 16, weight: .regular)
        case .body2:
            return .system(size: 14, weight: .regular)
        case .caption1:
            return .system(size: 12, weight: .regular)
        case .caption2:
            return .system(size: 14, weight: .regular)
        case .label1:
            return .system(size: 14, weight: .medium)
        case .button1:
            return .system(size: 16, weight: .semibold)
        case .button2:
            return .system(size: 14, weight: .medium)
        }
    }
}

// MARK: - Text Style Modifier
struct PiCKTextModifier: ViewModifier {
    let type: PiCKTextType
    let textColor: Color

    func body(content: Content) -> some View {
        content
            .font(type.font)
            .foregroundColor(textColor)
    }
}

public extension View {
    func pickText(type: PiCKTextType, textColor: Color = .Normal.black) -> some View {
        modifier(PiCKTextModifier(type: type, textColor: textColor))
    }
}
