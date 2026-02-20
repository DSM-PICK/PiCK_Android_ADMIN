import SwiftUI

struct RectCorner: OptionSet {
    let rawValue: Int
    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: RectCorner

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height
        let r = radius

        if corners.contains(.topLeft) {
            path.move(to: CGPoint(x: 0, y: r))
            path.addArc(center: CGPoint(x: r, y: r), radius: r, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        } else {
            path.move(to: CGPoint(x: 0, y: 0))
        }

        if corners.contains(.topRight) {
            path.addLine(to: CGPoint(x: w - r, y: 0))
            path.addArc(center: CGPoint(x: w - r, y: r), radius: r, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: w, y: 0))
        }

        if corners.contains(.bottomRight) {
            path.addLine(to: CGPoint(x: w, y: h - r))
            path.addArc(center: CGPoint(x: w - r, y: h - r), radius: r, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: w, y: h))
        }

        if corners.contains(.bottomLeft) {
            path.addLine(to: CGPoint(x: r, y: h))
            path.addArc(center: CGPoint(x: r, y: h - r), radius: r, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: 0, y: h))
        }

        path.closeSubpath()
        return path
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}