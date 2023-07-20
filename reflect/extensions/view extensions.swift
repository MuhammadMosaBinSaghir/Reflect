import SwiftUI

extension View {
    func capsuled(background: AnyShapeStyle) -> some View {
        self.modifier(Capsuled(background: background))
    }
}

extension ScrollTargetBehavior where Self == CenteredScrollTargetBehavior {
    static var centered: CenteredScrollTargetBehavior { get { CenteredScrollTargetBehavior() } }
}
