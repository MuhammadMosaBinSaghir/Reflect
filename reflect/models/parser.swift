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
    
    struct Match {
        var results: [String: Int]
        var count: Int
        
        static func empty() -> Self { .init(results: .empty, count: 0) }
    }
    
    var definition: String
    var keys: Keys
    var source: [[String]]
    
    var accounts: Match { searching(in: source, for: .account) }
    var dates: Match { searching(in: source, for: .date) }
    var amounts: Match { searching(in: source, for: .amount) }
    var descriptions: Match { searching(in: source, for: .description) }
    
    static let undefined = Parser(source: .empty)
    
    func buffer(for attribute: Attributes) -> Match {
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
    
    func searching(in phrases: [[String]], for attribute: Attributes) -> Match {
        guard let regex = Self.regex(from: self.key(for: attribute)) else { return .empty() }
        guard let index = phrases.firstIndex(where: { $0.contains { $0.contains(regex) } } ) else { return .empty() }
        let column = phrases[index].firstIndex { $0.contains(regex) }!
        let matches: [String] = (index..<phrases.count).compactMap {
            guard phrases[$0].count > column else { return nil }
            return phrases[$0][column]
        }
        let uniques = matches.reduce(into: [:]) { dictionary, element in
            dictionary[element, default: 0] += 1
        }
        let converts = uniques.keys.map {
            attribute.rawValue.parse($0)
        }
        return .init(results: uniques, count: matches.count)
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
