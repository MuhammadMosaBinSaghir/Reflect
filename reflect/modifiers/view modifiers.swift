import SwiftUI

struct Capsuled: ViewModifier {
    var gradient: LinearGradient
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(gradient)
            .clipShape(Capsule(style: .continuous))
            .shadow(radius: 2, x: 2, y: 2)
    }
}
