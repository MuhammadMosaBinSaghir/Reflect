import SwiftUI

struct CenteredScrollTargetBehavior: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        enum Direction { case left, right }
        enum Placement { case beginning, middle, end }
        
        let direction: Direction = if (context.velocity.dx < 0) { .left } else { .right }
        
        let placement: Placement = switch(context.records.selected) {
        case context.records.statements.first: .beginning
        case context.records.statements.last: .end
        default: .middle
        }
        
        let location = target.rect.minX
        let viewWidth = 344.0
        let offset = 36.0
        target.rect.origin.x =
        switch(placement) {
        case .beginning:
            switch(direction) {
            case .left: .zero
            case .right: ceil(location/viewWidth)*viewWidth - offset
            }
        case .middle:
            switch(direction) {
            case .left: floor(location/viewWidth)*viewWidth - offset
            case .right: ceil(location/viewWidth)*viewWidth - offset
            }
        case .end:
            switch(direction) {
            case .left: floor(location/viewWidth)*viewWidth - offset
            case .right: context.contentSize.width;
            }
        }
    }
}
