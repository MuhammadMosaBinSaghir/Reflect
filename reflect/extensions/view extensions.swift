import SwiftUI

extension View {
    func bound(by shape: AnyShape, fill background: AnyShapeStyle) -> some View {
        self.modifier(Bound(shape: shape, background: background))
    }
}

extension ScrollTargetBehavior where Self == CenteredScrollTargetBehavior {
    static var centered: CenteredScrollTargetBehavior { .init() }
}
