import SwiftUI

// MARK: - Primary Colors
public extension Color {
    struct Primary {
        public static let primary50 = Color(hex: "#EDE7F6")
        public static let primary100 = Color(hex: "#D1C4E9")
        public static let primary200 = Color(hex: "#B39DDB")
        public static let primary300 = Color(hex: "#9575CD")
        public static let primary400 = Color(hex: "#7E57C2")
        public static let primary500 = Color(hex: "#673AB7")
        public static let primary600 = Color(hex: "#5E35B1")
        public static let primary700 = Color(hex: "#512DA8")
        public static let primary800 = Color(hex: "#4527A0")
        public static let primary900 = Color(hex: "#311B92")
    }
}

// MARK: - Gray Colors
public extension Color {
    struct Gray {
        public static let gray50 = Color(hex: "#FAFAFA")
        public static let gray100 = Color(hex: "#F5F5F5")
        public static let gray200 = Color(hex: "#EEEEEE")
        public static let gray300 = Color(hex: "#E0E0E0")
        public static let gray400 = Color(hex: "#BDBDBD")
        public static let gray500 = Color(hex: "#9E9E9E")
        public static let gray600 = Color(hex: "#757575")
        public static let gray700 = Color(hex: "#616161")
        public static let gray800 = Color(hex: "#424242")
        public static let gray900 = Color(hex: "#212121")
    }
}

// MARK: - Normal Colors
public extension Color {
    struct Normal {
        public static let white = Color.white
        public static let black = Color.black
    }
}

// MARK: - Error Colors
public extension Color {
    struct Error {
        public static let error = Color(hex: "#F44336")
        public static let errorLight = Color(hex: "#FFEBEE")
    }
}

// MARK: - Background Colors
public extension Color {
    struct Background {
        public static let primary = Color.white
        public static let secondary = Color(hex: "#F5F5F5")
    }
}

// MARK: - Color Extension for Hex
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
