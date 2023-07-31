import Foundation
import Observation

@Observable
final class Account: Attributable {
    static let label: AttributeLabel = .account
    static let icon: String = "creditcard"
    static func undefined() -> Account { .init(type: .undefined, number: .empty) }
    static func parse(from string: String) -> Account {
        .init(type: .init(rawValue: string) ?? .undefined, number: string)
    }
    
    var type: AccountType
    var number: String
    func formatted() -> String { type.rawValue + number }
    
    required init(type: AccountType, number: String) { self.type = type; self.number = number }
    enum AccountType: String, CaseIterable { case undefined, debit, credit }
}
