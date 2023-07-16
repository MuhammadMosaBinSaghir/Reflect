import Foundation

struct Problem: Hashable {
    let file: String
    let type: String?
    let issue: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }
    
    init(file: String, issue: String) {
        self.file = file
        self.type = nil
        self.issue = issue
    }
    
    init(file: String, type: String?, issue: String) {
        self.file = file
        self.type = type
        self.issue = issue
    }
}

struct Statement: Identifiable, Hashable {
    let id = UUID()
    let date: Date = .now
    var attributes: [Attribute]
    
    var name: String
    let type: String
    let data: String
    
    struct Attribute: Hashable {
        var constraint: Constraint
        var constrained: Bool = false
        
        enum Constraint: CaseIterable {
            case date
            case account
            case description
            case merchant
            case category
            case amount
            
            var name: String {
                switch self {
                    case .date: return "date"
                    case .account: return "account"
                    case .description: return "description"
                    case .merchant: return "merchant"
                    case .category: return "category"
                    case .amount: return "amount"
                }
            }
            
            var icon: String {
                switch self {
                    case .date: return "calendar"
                    case .account: return "creditcard"
                    case .description: return "square.and.pencil"
                    case .merchant: return "cart"
                    case .category: return "tag"
                    case .amount: return "dollarsign"
                }
            }
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.data == rhs.data && lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(data)
    }
    
    init(name: String, type: String, data: String) {
        var attributes = [Attribute]()
        for contraint in Attribute.Constraint.allCases {
            attributes.append(Attribute(constraint: contraint))
        }
        self.attributes = attributes
        self.name = name
        self.type = type
        self.data = data
    }
}

/*
func fetch(_ url: URL) -> String {
    guard let dropped = try? Data(contentsOf: url) else { return "" }
    guard let fetched = String(data: dropped, encoding: .utf8) else { return "" }
    return fetched
 
    let rows = imported.components(separatedBy: "\n")
    return rows.map { $0.components(separatedBy: ",") }
}
*/

/*
extension Collection where Self.Iterator.Element: RandomAccessCollection {
    // error caused whenever self isn't rectangular, i.e. all rows aren't of equal size.
    func transposed() -> [[Self.Iterator.Element.Iterator.Element]] {
        guard let firstRow = self.first else { return [] }
        return firstRow.indices.map { index in
            self.map{ $0[index] }
        }
    }
}

enum Account: String {
    case credit
    case debit
}

/*
 case A0 = "unset transaction"
 case AD = "adjustment"
 case BC = "cancelled payment"
 case CB = "cheque posted by branch"
 case CC = "certified cheque"
 case CD = "customer deposit"
 case CK = "cheque"
 case CM = "credit memo"
 case CW = "online banking"
 case DC = "other charge"
 case DD = "direct deposit/pre-authorized debit"
 case DM = "debit memo"
 case DN = "none chargeable service"
 case DR = "overdraft"
 case DS = "chargeable service"
 case EC = "error correction"
 case FX = "foreign exchange"
 case GS = "provincial tax"
 case IB = "instabank®"
 case IN = "interest"
 case LI = "loan interest"
 case LN = "loan payment"
 case LP = "loan advance"
 case LT = "large volume account list total"
 case MB = "multi-branch banking®"
 case NR = "non-resident tax"
 case NS = "non sufficient funds"
 case NT = "Nesbitt burns entry"
 case OL = "online debit purchase"
 case OM = "other automated banking"
 case OP = "Telephone, Mail, Online or Recurring Payment Purchase"
 case OV = "online debit refund"
 case PR = "purchase at merchant"
 case RC = "non sufficient funds charge"
 case RN = "merchandise return"
 case RT = "returned item"
 case RV = "merchant reversal"
 case SC = "service charge"
 case SO = "standing order"
 case ST = "merchant deposit"
 case TF = "transfer of funds"
 case TX = "federal tax"
 case WD = "withdrawal"
 */

enum Code: String {
    case A0
    case AD
    case BC
    case CB
    case CC
    case CD
    case CK
    case CM
    case CW
    case DC
    case DD
    case DM
    case DN
    case DR
    case DS
    case EC
    case FX
    case GS
    case IB
    case IN
    case LI
    case LN
    case LP
    case LT
    case MB
    case NR
    case NS
    case NT
    case OL
    case OM
    case OP
    case OV
    case PR
    case RC
    case RN
    case RT
    case RV
    case SC
    case SO
    case ST
    case TF
    case TX
    case WD
}

struct Transaction: Identifiable, Hashable {
    let id = UUID()
    var date: Date
    var account: Account
    var code: Code
    var merchant: String
    var category: String
    var amount: Double
    
    init(date: Date, code: String, account: String, amount: Double) {
        self.date = date
        self.account = Account(rawValue: account) ?? .debit
        self.code = Code(rawValue: code) ?? .A0
        self.merchant = ""
        self.category = ""
        self.amount = amount
    }
}

struct Transactions {
    var dropped: [[String]]
    //height and length for DROPPED, not filtered
    var height: Int { dropped.count }
    var length: Int { dropped.max(by: { $0.count < $1.count })?.count ?? 0 }
    var sanitized: [Transaction] { sanitize(dropped) }
    
    private func shape(_ dropped: [[String]]) -> [[String]] {
        var shaped = [[String]](repeating: [String](repeating: "", count: length), count: height)
        for i in 0..<height {
            for j in 0..<dropped[i].count {
                shaped[i][j] = dropped[i][j]
            }
        }
        return shaped
    }
    
    private func filter(_ shaped: [[String]]) -> [[String]] {
        var filtered = shaped
        filtered.removeAll { $0.allSatisfy { $0.isEmpty } }
        filtered.removeFirst(2)
        filtered = filtered.transposed()
        filtered.removeFirst()
        filtered = filtered.transposed()
        return filtered
    }
    
    private func convert(_ filtered: [[String]]) -> [Transaction] {
        var converted = [Transaction]()

        let strategy = Date.ParseStrategy(
            format: "\(year: .extended(minimumLength: 4))\(month: .twoDigits)\(day: .twoDigits)",
            locale: .current,
            timeZone: .current
        )
        
        for row in 0..<filtered.count {
            let date = try? Date(filtered[row][1], strategy: strategy)
            let start = filtered[row][3].index(filtered[row][3].startIndex, offsetBy: 1)
            let end = filtered[row][3].index(filtered[row][3].startIndex, offsetBy: 2)
            converted.append(Transaction.init(
                date: date ?? Date.now,
                code: String(filtered[row][3][start...end]),
                account: filtered[row][0],
                amount: Double(filtered[row][2]) ?? .zero
            ))
        }
        
        return converted
    }

    private func sanitize(_ dropped: [[String]]) -> [Transaction] {
        guard !dropped.isEmpty else { return [] }
        return convert(filter(shape(dropped)))
    }

}

 */
