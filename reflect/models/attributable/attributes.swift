import Foundation

enum Attributes: CaseIterable { case account, date, code, amount, description }

extension Attributes: RawRepresentable {
    typealias RawValue = any Attributable.Type
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case is Account.Type: self = .account
        case is Date.Type: self = .date
        case is Code.Type: self = .code
        case is Amount.Type: self = .amount
        case is Description.Type: self = .description
        default: return nil
        }
    }
    
    var rawValue: RawValue {
        switch self {
        case .account: Account.self
        case .date: Date.self
        case .code: Code.self
        case .amount: Amount.self
        case .description: Description.self
        }
    }
}