import Foundation
import Observation

@Observable
final class Transaction: Identifiable {
    let id = UUID()
    let account: Account
    let amount: Amount
    let category: Category?
    let code: Code
    let date: Date
    let description: Description
    let merchant: Merchant?
    
    init(account: Account, amount: Amount, code: Code, date: Date, description: Description) {
        self.account = account
        self.amount = amount
        self.category = nil
        self.code = code
        self.date = date
        self.description = description
        self.merchant = nil
    }
}
