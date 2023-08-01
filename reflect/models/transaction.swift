import Foundation
import Observation

@Observable
final class Transaction: Identifiable {
    let id = UUID()
    let account: Account
    let amount: Amount
    let code: Code
    let date: Date
    let description: Description
    
    init(account: Account, amount: Amount, code: Code, date: Date, description: Description) {
        self.account = account
        self.amount = amount
        self.code = code
        self.date = date
        self.description = description
    }
}
