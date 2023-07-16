import SwiftUI

struct Capsuled: ViewModifier {
    var gradient: LinearGradient
    
    func body(content: Content) -> some View {
        content
            .padding(6)
            .background(gradient)
            .clipShape(Capsule(style: .continuous))
    }
}
