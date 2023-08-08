import SwiftUI

extension View {
    func pilled<S: ShapeStyle>(fill background: S) -> some View {
        self.modifier(Pilled(background: background))
    }
    func boxed<S: ShapeStyle>(fill background: S) -> some View {
        self.modifier(Boxed(background: background))
    }
}

extension ScrollTargetBehavior where Self == CenteredScrollTargetBehavior {
    static var centered: CenteredScrollTargetBehavior { .init() }
}

extension Shape where Self == Circle {
  static var circle: Self { .init() }
}

extension Shape where Self == Rectangle {
  static var rectangle: Self { .init() }
}
