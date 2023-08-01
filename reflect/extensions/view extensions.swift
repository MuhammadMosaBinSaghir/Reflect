import SwiftUI

extension View {
    func bound<T: Shape, S: ShapeStyle>(by shape: T, fill background: S) -> some View {
        self.modifier(Bound(shape: shape, background: background))
    }
}

extension DisclosureGroupStyle where Self == CompactDisclosureStyle {
    static var compact: CompactDisclosureStyle { .init() }
}

extension ScrollTargetBehavior where Self == CenteredScrollTargetBehavior {
    static var centered: CenteredScrollTargetBehavior { .init() }
}
