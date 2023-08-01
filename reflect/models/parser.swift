import Foundation
import Observation
import RegexBuilder

@Observable
final class Parser {
    var definition: String
    var account: String
    var date: String
    var code: String
    var amount: String
    var description: String
    
    func breakdown(_ data: String) -> [String] {
        var lines = data.components(separatedBy: "\n")
        lines.removeAll { $0 == .empty }
        let joined = lines.joined(separator: ",")
        let compacted = joined.components(separatedBy: ",").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return compacted.map { phrase in
            if phrase.contains(" ") {
                return phrase.replacing(/\s{2,}/, with: " ")
            } else {
                return phrase
            }
        }
    }
    /*
    func parse<A: Attributable>(from string: String, to type: A.Type) -> [A] {
        let type = Reference(A.self)
        let code: String = switch A.label {
        case .account: self.account
        case .date: self.date
        case .code: self.code
        case .amount: self.amount
        case .description: self.description
        default: .empty
        }
        let attribute = Regex {
            TryCapture(as: type) {
                regex(from: code)
            } transform: {
                A.parse(from: String($0))
            }
        }
        var attributes: [A] = .empty
        let matches = string.matches(of: attribute)
        for match in matches {
            attributes.append(match[type])
        }
        return attributes
    }
    

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
                return Code(type: .init(rawValue: String($0)) ?? .undefined)
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
    */
    
    init(
        definition: String = .empty,
        account: String = .empty,
        date: String = .empty,
        code: String = .empty,
        amount: String = .empty,
        description: String = .empty
    ) {
        self.definition = definition
        self.account = account
        self.date = date
        self.code = code
        self.amount = amount
        self.description = description
    }
    
    func regex(from string: String) -> Regex<Substring> {
        do { return try Regex(string) }
        catch { return /a^/ }
    }
}
