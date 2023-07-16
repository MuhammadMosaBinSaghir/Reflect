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
