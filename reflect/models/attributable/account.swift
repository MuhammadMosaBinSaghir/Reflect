import Foundation
import Observation

@Observable
final class Account: Attributable {    
    static let label: String = "account"
    static let icon: String = "creditcard"
    static func undefined() -> Account { .init(type: .undefined) }
    static func parse(_ word: String) -> Account { .init(type: .init(rawValue: word) ?? .undefined) }
    
    var type: AccountType
    func formatted() -> String { type.rawValue }
    
    required init(type: AccountType) { self.type = type }
    enum AccountType: String, CaseIterable { case undefined, debit, credit }
}
