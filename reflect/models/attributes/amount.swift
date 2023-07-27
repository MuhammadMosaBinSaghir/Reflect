import Foundation
import Observation

@Observable
class Amount: Attribute {
    static let label: String = "amount"
    static let icon: String = "dollarsign"
    
    let value: Decimal
    let currency: Currency
    enum Currency: CaseIterable { case CAD, USD }
    
    init(value: Decimal, currency: Currency) {
        self.value = value
        self.currency = currency
    }
}
