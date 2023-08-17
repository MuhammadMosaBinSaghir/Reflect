import SwiftUI

extension Color: Colorful {}
extension AngularGradient: Colorful {}
extension EllipticalGradient: Colorful {}
extension RadialGradient: Colorful {}
extension LinearGradient: Colorful {}

extension View {
    func pilled<S: ShapeStyle>(fill background: S) -> some View {
        self.modifier(Pilled(background: background))
    }
    func boxed<S: ShapeStyle>(fill background: S) -> some View {
        self.modifier(Boxed(background: background))
    }
    func scrollingSlide() -> some View {
        self.scrollTransition(.interactive, axis: .horizontal) { content, phase in
            let anchor: UnitPoint = switch(phase.value) {
            case -1: .leading
            case 1: .trailing
            default: .center
            }
            return content
                .blur(radius: phase.isIdentity ? 0 : 5)
                .scaleEffect(
                    phase.isIdentity ? 1 : 0.5,
                    anchor: anchor
                )
        }
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
