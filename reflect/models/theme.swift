import Foundation
import Observation
import RegexBuilder

@Observable
class Theme {
    var name: String
    var accountType: String
    var accountNumber: String
    var amountWorth: String
    var code: String
    var date: String
    var description: String
    
    var seperator: String
    
    func parse(from data: String) -> [Transaction] {
        let accountType = Reference(Account.AccountType.self)
        let accountNumber = Reference(String.self)
        let date = Reference(Date.self)
        let amountWorth = Reference(Decimal.self)
        let code = Reference(Code.self)
        let description = Reference(Description.self)
        
        let transaction =
        Regex {
            /^/
            TryCapture(as: accountNumber) {
                regex(from: self.accountNumber)
            } transform: {
                String($0).filter { $0 != "'" }
            }
            regex(from: self.seperator)
            TryCapture(as: accountType) {
                regex(from: self.accountType)
            } transform: {
                .init(rawValue: String($0).lowercased())
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
            TryCapture(as: amountWorth) {
                regex(from: self.amountWorth)
            } transform: {
                Decimal(string: String($0))
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
                    account: Account(type: match[accountType], number: match[accountNumber]),
                    amount: Amount(worth: match[amountWorth]),
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
            print("account: " + transaction.account.formatted())
            print("amount: " + transaction.amount.formatted())
            print("code: " + transaction.code.formatted())
            print("date: " + transaction.date.formatted())
            print("description: " + transaction.description.formatted())
            print("---------------------------")
        }
         */
        return transactions
    }
    
    static let BMO: Theme = .init(
        name: "BMO",
        accountType: #"DEBIT|CREDIT"#,
        accountNumber: #"'\d{16}'"#,
        amountWorth: #"-?\d+.\d{1,2}"#,
        code: #"\[[A-Z]{2}\]"#,
        date: #"\d{8}"#,
        description: #".*?\S.*?(?=\s*\n|$)"#,
        seperator: #","#
    )
    
    init(
        name: String,
        accountType: String,
        accountNumber: String,
        amountWorth: String,
        code: String,
        date: String,
        description: String,
        seperator: String
    ) {
        self.name = name
        self.accountType = accountType
        self.accountNumber = accountNumber
        self.amountWorth = amountWorth
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
