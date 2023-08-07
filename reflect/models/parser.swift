import Foundation
import Observation
import RegexBuilder

@Observable
final class Parser {
    struct Keys {
        var account: String
        var date: String
        var amount: String
        var description: String
        
        static func empty() -> Self { .init(account: .empty, date: .empty, amount: .empty, description: .empty) }
    }
    var definition: String
    var keys: Keys
    let source: [[String]]
    
    var accounts: [String] { searching(in: source, for: .account) }
    var dates: [String] { searching(in: source, for: .date) }
    var amounts: [String] { searching(in: source, for: .amount) }
    var descriptions: [String] { searching(in: source, for: .description) }
    
    static let undefined = Parser(source: .empty)
    
    func buffer(for attribute: Attributes) -> [String] {
        switch attribute {
        case .account: self.accounts
        case .date: self.dates
        case .amount: self.amounts
        case .description: self.descriptions
        }
    }
    
    func key(for attribute: Attributes) -> String {
        switch attribute {
        case .account: self.keys.account
        case .date: self.keys.date
        case .amount: self.keys.amount
        case .description: self.keys.description
        }
    }
    
    func searching(in phrases: [[String]], for attribute: Attributes) -> [String] {
        guard let regex = Self.regex(from: self.key(for: attribute)) else { return .empty }
        guard let index = phrases.firstIndex(where: { $0.contains { $0.contains(regex) } } ) else { return .empty }
        let match = phrases[index].firstIndex { $0.contains(regex) }!
        
        return (index..<phrases.count).compactMap {
            guard phrases[$0].count > match else { return nil }
            return phrases[$0][match]
        }
    }
    
    static func regex(from key: String) -> Regex<Substring>? {
        guard !key.isEmpty else { return nil }
        do { return try Regex(key) }
        catch { return nil }
    }
    
    static func breakdown(_ data: String) -> [[String]] {
        var lines = data.components(separatedBy: "\n")
        lines.removeAll { $0 == .empty }
        let count = Attributes.allCases.count

        return lines.compactMap { line in
            let untrimmed = line.components(separatedBy: ",")
            guard untrimmed.count >= count else { return nil }
            return untrimmed.compactMap { word in
                guard word.count >= count else { return nil }
                var trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmed.contains(" ") else { return trimmed }
                trimmed = trimmed.replacing(/\s{2,}/, with: " ")
                return trimmed
            }
        }
    }
    
    init(definition: String = .empty, keys: Keys = .empty(), source data: String) {
        self.definition = definition
        self.keys = keys
        self.source = Self.breakdown(data)
    }
}
