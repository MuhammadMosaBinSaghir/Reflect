import SwiftUI

extension Animation {
    static let resizing: Animation = .smooth
    static let scroll: Animation = .smooth
    static let transition: Animation = .smooth
}

extension CGFloat {
    struct Height {
        let searchbar: CGFloat = 64.0
        let content: CGFloat = 464.0
        var total: CGFloat { searchbar + content }
    }
    
    struct Width {
        let sidebar: CGFloat = 192.0
        let content: CGFloat = 256.0
        let modal: CGFloat = 424.0
        var total: CGFloat { sidebar + content + modal }
    }
    
    static let width = Width()
    static let height = Height()
}

extension Shape where Self == RoundedRectangle {
    static var primary: RoundedRectangle { RoundedRectangle(cornerRadius: 8, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/) }
    static var secondary: RoundedRectangle { RoundedRectangle(cornerRadius: 6, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/) }
}

extension ShapeStyle where Self == Color {
    static var light: Color { .blue }
    static var dark: Color { .indigo }
    static var bubble: Color { .primary.opacity(0.05) }
}

extension ShapeStyle where Self == LinearGradient {
    static var linearBubble: LinearGradient {
        .init(colors: [.bubble, .bubble], startPoint: .leading, endPoint: .trailing)
    }
    static var linearDark: LinearGradient {
        .init(colors: [.dark, .dark], startPoint: .leading, endPoint: .trailing)
    }
    static var linearLight: LinearGradient {
        .init(colors: [.light, .light], startPoint: .leading, endPoint: .trailing)
    }
    static var linearThemed: LinearGradient {
        .init(colors: [.dark, .light], startPoint: .leading, endPoint: .trailing)
    }
    static var linearGrayed: LinearGradient {
        .init(colors: [.gray.opacity(0.5), .gray.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
    }
}

extension Font {
    static let content: Font = .body
    static let header: Font = .title3.bold()
    static let search: Font = .title
}
