import Foundation
import Observation
import RegexBuilder

@Observable
class Theme {
    let name: String
    var account: String
    let amount: String
    let card: String
    let code: String
    let date: String
    let description: String
    
    let seperator: String
    
    func parse(from data: String) -> [Transaction] {
        let card = Reference(Card.self)
        let account = Reference(Account.self)
        let date = Reference(Date.self)
        let amount = Reference(Amount.self)
        let code = Reference(Code.self)
        let description = Reference(Description.self)
        
        let transaction =
        Regex {
            /^/
            TryCapture(as: card) {
                regex(from: self.card)
            } transform: {
                Card(number: String($0))
            }
            regex(from: self.seperator)
            TryCapture(as: account) {
                regex(from: self.account)
            } transform: {
                return Account(type: .init(rawValue: String($0).lowercased()) ?? .unknown)
            }
            regex(from: self.seperator)
            TryCapture(as: date) {
                regex(from: self.date)
            } transform: {
                let strategy = Date.ParseStrategy(
                    format: "\(year: .extended(minimumLength: 4))\(month: .twoDigits)\(day: .twoDigits)",
                    locale: .current,
                    timeZone: .current
                )
                let date = try? Date(String($0), strategy: strategy)
                return date ?? .now
            }
            regex(from: self.seperator)
            TryCapture(as: amount) {
                regex(from: self.amount)
            } transform: {
                return Amount(value: Decimal(string: String($0)) ?? 0, currency: .CAD)
            }
            regex(from: self.seperator)
            TryCapture(as: code) {
                regex(from: self.code)
            } transform: {
                return Code(type: .init(rawValue: String($0).trimmingCharacters(in: ["[", "]"])) ?? .unknown )
            }
            TryCapture(as: description) {
                regex(from: self.description)
            } transform: {
                Description(text: String($0))
            }
         }
        .anchorsMatchLineEndings()
        
        var transactions: [Transaction] = .empty
        let matches = data.matches(of: transaction)
        for match in matches {
            transactions.append(
                Transaction(
                    account: match[account],
                    amount: match[amount],
                    card: match[card],
                    code: match[code],
                    date: match[date],
                    description: match[description]
                )
            )
        }
        /*
        for (index, transaction) in transactions.enumerated() {
            print("index: " + (index + 1).description)
            print("id: " + transaction.id.description)
            print("account: " + transaction.account.type.rawValue)
            print("amount: " + transaction.amount.value.formatted())
            print("card: " + transaction.card.number)
            print("category: " + transaction.category.debugDescription)
            print("code: " + transaction.code.type.rawValue)
            print("date: " + transaction.date.formatted())
            print("description: " + transaction.description.text)
            print("merchant: " + transaction.merchant.debugDescription)
            print("---------------------------")
        }
         */
        return transactions
    }
    
    static let BMO: Theme = .init(
        name: "BMO",
        account: #"DEBIT|CREDIT"#,
        amount: #"-?\d+.\d{1,2}"#,
        card: #"'\d{16}'"#,
        code: #"\[[A-Z]{2}\]"#,
        date: #"\d{8}"#,
        description: #".*?\S.*?(?=\s*\n|$)"#,
        seperator: #","#
    )
    
    init(
        name: String,
        account: String,
        amount: String,
        card: String,
        code: String,
        date: String,
        description: String,
        seperator: String
    ) {
        self.name = name
        self.account = account
        self.amount = amount
        self.card = card
        self.code = code
        self.date = date
        self.description = description
        self.seperator = seperator
    }
    
    private func regex(from string: String) -> Regex<Substring> {
        do { return try Regex(string) }
        catch { return /a^/ }
    }
}
