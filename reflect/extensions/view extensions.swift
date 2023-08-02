import SwiftUI

extension View {
    func bound<T: Shape, S: ShapeStyle>(by shape: T, fill background: S) -> some View {
        self.modifier(Bound(shape: shape, background: background))
    }
}

extension ScrollTargetBehavior where Self == CenteredScrollTargetBehavior {
    static var centered: CenteredScrollTargetBehavior { .init() }
}
