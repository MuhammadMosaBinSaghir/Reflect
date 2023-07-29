import Foundation
import Observation

@Observable
class Account: Attribute {
    static let label: String = "account"
    static let icon: String = "creditcard"
    
    var type: AccountType
    var number: String
    func formatted() -> String { type.rawValue + number }
    
    init(type: AccountType, number: String) { self.type = type; self.number = number }
    enum AccountType: String, CaseIterable { case unknown, debit, credit }
}
