import Foundation
import Observation

@Observable
final class Amount: Attributable {
    static let label: String = "amount"
    static let icon: String = "dollarsign"
    static func undefined() -> Amount { .init(worth: .zero) }
    static func parse(_ word: String) -> Amount { .init(worth: Decimal(string: word) ?? .zero) }
    
    var worth: Decimal
    func formatted() -> String { worth.formatted(.currency(code: "CAD")) }
    
    required init(worth: Decimal) { self.worth = worth }
}
