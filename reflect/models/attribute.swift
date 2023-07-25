import Foundation
import Observation

@Observable
class Attribute {
    let name: String
    let icon: String
    let type: Constraint
    var constrained: Bool
    
    enum Constraint: CaseIterable { case date, account, description, merchant, category, amount }

    init(type: Constraint, constrained: Bool = false) {
        self.type = type
        self.constrained = constrained
        switch(type) {
        case .date: self.name = "date"; self.icon = "calendar"
        case .account: self.name = "account"; self.icon = "creditcard"
        case .description: self.name = "description"; self.icon = "square.and.pencil"
        case .merchant: self.name = "merchant"; self.icon = "cart"
        case .category: self.name = "category"; self.icon = "tag"
        case .amount: self.name = "amount"; self.icon = "dollarsign"
        }
    }
}
