import Foundation
import Observation

@Observable
class Transaction: Identifiable {
    let id = UUID()
    let account: Account
    let amount: Amount
    let card: Card
    let category: Category?
    let code: Code
    let date: Date
    let description: Description
    let merchant: Merchant?
    let uncategorized: Uncategorized?
    
    init(account: Account, amount: Amount, card: Card, code: Code, date: Date, description: Description) {
        self.account = account
        self.amount = amount
        self.card = card
        self.category = nil
        self.code = code
        self.date = date
        self.description = description
        self.merchant = nil
        self.uncategorized = nil
    }
}
