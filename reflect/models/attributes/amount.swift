import Foundation
import Observation

@Observable
class Amount: Attribute {
    static let label: String = "amount"
    static let icon: String = "dollarsign"
    
    var worth: Decimal
    func formatted() -> String { worth.formatted(.currency(code: "CAD")) }
    
    init(worth: Decimal) { self.worth = worth }
}
