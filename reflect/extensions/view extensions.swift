import SwiftUI

extension View {
    func capsuled(gradient: LinearGradient) -> some View {
        self.modifier(Capsuled(gradient: gradient))
    }
}

extension ScrollTargetBehavior where Self == CenteredScrollTargetBehavior {
    static var centered: CenteredScrollTargetBehavior { get { CenteredScrollTargetBehavior() } }
}
