import Foundation
import Observation
import RegexBuilder

@Observable
class Theme {
    let name: String
    let account: Regex<Substring>
    let amount: Regex<Substring>
    let card: Regex<Substring>
    let code: Regex<Substring>
    let date: Regex<Substring>
    let description: Regex<Substring>
    
    let seperator: Regex<Substring>
    
    func extract(from data: String) -> [Transaction] {
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
                self.card
            } transform: {
                Card(number: String($0))
            }
            self.seperator
            TryCapture(as: account) {
                self.account
            } transform: {
                Account(type: .init(rawValue: String($0)) ?? .unknown )
            }
            self.seperator
            TryCapture(as: date) {
                self.date
            } transform: {
                let strategy = Date.ParseStrategy(
                    format: "\(year: .extended(minimumLength: 4))\(month: .twoDigits)\(day: .twoDigits)",
                    locale: .current,
                    timeZone: .current
                )
                let date = try? Date(String($0), strategy: strategy)
                return date ?? .now
            }
            self.seperator
            TryCapture(as: amount) {
                self.amount
            } transform: {
                Amount(value: Decimal(string: String($0)) ?? 0, currency: .CAD)
            }
            self.seperator
            TryCapture(as: code) {
                self.code
            } transform: {
                Code(type: .init(rawValue: String($0)) ?? .unknown )
            }
            TryCapture(as: description) {
                self.description
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
        print(transactions.count)
        return transactions
    }
    
    static let BMO: Theme = .init(
        name: "BMO",
        account: /DEBIT|CREDIT/,
        amount: /\d+.\d{1,2}/,
        card: /'\d{16}'/,
        code: /\[[A-Z]{2}\]/,
        date: /\d{8}/,
        description: /.*?\S.*?(?=\s*\n|$)/,
        seperator: /,/
    )
    
    init(
        name: String,
        account: Regex<Substring>,
        amount: Regex<Substring>,
        card: Regex<Substring>,
        code: Regex<Substring>,
        date: Regex<Substring>,
        description: Regex<Substring>,
        seperator: Regex<Substring>
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
}
