import SwiftUI

public extension Color {
    struct Primary {
        public static let primary50 = Color(hex: "#F2EAFE")
        public static let primary100 = Color(hex: "#E0CBFE")
        public static let primary200 = Color(hex: "#CBA8FD")
        public static let primary300 = Color(hex: "#B685FC")
        public static let primary400 = Color(hex: "#A66AFB")
        public static let primary500 = Color(hex: "#9650FA")
        public static let primary600 = Color(hex: "#8E49F9")
        public static let primary700 = Color(hex: "#8340F9")
        public static let primary800 = Color(hex: "#7937F8")
        public static let primary900 = Color(hex: "#6827F6")
    }
}

public extension Color {
    struct Gray {
        public static let gray50 = Color(hex: "#F1F1F2")
        public static let gray100 = Color(hex: "#DDDCDD")
        public static let gray200 = Color(hex: "#C6C5C7")
        public static let gray300 = Color(hex: "#AFADB1")
        public static let gray400 = Color(hex: "#9D9CA0")
        public static let gray500 = Color(hex: "#8C8A8F")
        public static let gray600 = Color(hex: "#848287")
        public static let gray700 = Color(hex: "#79777C")
        public static let gray800 = Color(hex: "#6F6D72")
        public static let gray900 = Color(hex: "#5C5A60")
    }
}

public extension Color {
    struct Normal {
        public static let white = Color.white
        public static let black = Color.black
    }
}

public extension Color {
    struct Error {
        public static let error = Color(hex: "#FF3B32")
        public static let errorLight = Color(hex: "#FFEBEE")
    }
}

public extension Color {
    struct Background {
        public static let primary = Color.white
        public static let secondary = Color(hex: "#F5F5F5")
        public static let background = Color(hex: "#F5F5F5")
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
