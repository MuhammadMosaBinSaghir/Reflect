import SwiftUI

extension Animation {
    static let reactive: Animation = .spring(dampingFraction: 0.75)
}

extension Color {
    static let light = cyan
    static let dark = blue
}

extension View {
    func capsuled(gradient: LinearGradient) -> some View {
        self.modifier(Capsuled(gradient: gradient))
    }
}

extension LinearGradient {
    static let dark = LinearGradient(colors: [.dark, .dark], startPoint: .leading, endPoint: .trailing)
    static let light = LinearGradient(colors: [.light, .light], startPoint: .leading, endPoint: .trailing)
    static let themed = LinearGradient(colors: [.dark, .light], startPoint: .leading, endPoint: .trailing)
    static let grayed = LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
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
