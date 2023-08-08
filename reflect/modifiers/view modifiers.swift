import SwiftUI

struct Boxed<S: ShapeStyle>: ViewModifier {
    var background: S
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 16)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(background.shadow(.drop(radius: 4)))
            )
    }
}

struct Pilled<S: ShapeStyle>: ViewModifier {
    var background: S
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 16)
            .padding(4)
            .background(
                Capsule(style: .continuous)
                    .fill(background.shadow(.drop(radius: 4)))
            )
    }
}
