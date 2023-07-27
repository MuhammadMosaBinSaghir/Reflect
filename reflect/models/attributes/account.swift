import Foundation
import Observation

@Observable
class Account: Attribute {
    static let label: String = "account"
    static let icon: String = "creditcard"
    
    let type: AccountType
    enum AccountType: String, CaseIterable { case unknown, debit, credit }
    
    init(type: AccountType) { self.type = type }
}
