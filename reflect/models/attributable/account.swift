import Foundation
import Observation

@Observable
final class Account: Attributable {
    static let label: String = "account"
    static let icon: String = "creditcard"
    
    var type: AccountType
    
    required init(type: AccountType) { self.type = type }
    enum AccountType: String, CaseIterable { case debit, credit }
}
