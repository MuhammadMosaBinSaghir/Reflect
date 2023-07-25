import SwiftUI

struct Bound<T: Shape, S: ShapeStyle>: ViewModifier {
    var shape: T
    var background: S
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(shape.fill(background.shadow(.drop(radius: 4))))
    }
}
