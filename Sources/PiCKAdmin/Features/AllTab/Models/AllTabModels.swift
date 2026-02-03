import Foundation
import SwiftUI

struct MyNameDTO: Decodable {
    let name: String
    let grade: Int
    let classNum: Int
}

struct MenuSectionModel: Identifiable {
    let id = UUID()
    let title: String
    let items: [MenuItemModel]
}

struct MenuItemModel: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let iconColor: Color
    let action: (() -> Void)?
    
    init(
        iconName: String,
        title: String,
        iconColor: Color = .Primary.primary500,
        action: (() -> Void)? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.iconColor = iconColor
        self.action = action
    }
}
