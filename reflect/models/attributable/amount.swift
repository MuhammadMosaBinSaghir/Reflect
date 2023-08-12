import Foundation
import Observation

@Observable
final class Amount: Attributable {
    static let label: String = "amount"
    static let icon: String = "dollarsign"
    
    var worth: Decimal
    
    required init(worth: Decimal) { self.worth = worth }
}
