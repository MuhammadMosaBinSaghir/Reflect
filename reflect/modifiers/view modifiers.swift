import SwiftUI

struct Bound: ViewModifier {
    var shape: AnyShape
    var background: AnyShapeStyle
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(shape.fill(background.shadow(.drop(radius: 4))))
    }
}
