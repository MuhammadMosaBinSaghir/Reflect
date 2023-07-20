import SwiftUI

struct Capsuled: ViewModifier {
    var background: AnyShapeStyle
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(background)
            .clipShape(Capsule(style: .continuous))
            .shadow(radius: 2, x: 2, y: 2)
    }
}
