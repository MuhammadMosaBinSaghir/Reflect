import SwiftUI

struct Capsuled: ViewModifier {
    var background: AnyShapeStyle
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(Capsule(style: .continuous).fill(background.shadow(.drop(radius: 4))))
    }
}
