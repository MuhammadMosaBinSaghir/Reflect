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
    
    struct Match<A: Attributable> {
        var results: [Result<A>]
        var count: Int
        
        static func empty() -> Self { Match(results: [Result<A>](), count: 0) }
    }
    
    struct Result<A: Attributable> {
        var word: String
        var count: Int
        var attribute: A?
    }
    
    var definition: String
    var keys: Keys
    var source: [[String]]
    
    var accounts: Match<Account> { searching(source) }
    var dates: Match<Date> { searching(source) }
    var amounts: Match<Amount> { searching(source) }
    var descriptions: Match<Description> { searching(source) }
    
    static let undefined = Parser(source: .empty)
    
    init(definition: String = .empty, keys: Keys = .empty(), source data: String) {
        self.definition = definition
        self.keys = keys
        self.source = Self.breakdown(data)
    }
    
    func key<A: Attributable>(for type: A.Type) -> String? {
        guard let attribute = Attributes(rawValue: type) else { return nil }
        switch attribute {
        case .account: return self.keys.account
        case .amount: return self.keys.amount
        case .date: return self.keys.date
        case .description: return self.keys.description
        }
    }
    
    func searching<A: Attributable>(_ phrases: [[String]]) -> Match<A> {
        guard let key = self.key(for: A.self) else { return .empty() }
        guard let regex = Self.regex(from: key) else { return .empty() }
        guard let index = phrases.firstIndex(where: { $0.contains { $0.contains(regex) } } ) else { return .empty() }
        let column = phrases[index].firstIndex { $0.contains(regex) }!
        let matches: [String] = (index..<phrases.count).compactMap {
            guard phrases[$0].count > column else { return nil }
            return phrases[$0][column]
        }
        let words = matches.reduce(into: [:]) { dictionary, element in
            dictionary[element, default: 0] += 1
        }
        let attributes = words.reduce(into: [String: A?]()) { dictionary, element in
            dictionary[element.key] = element.key.formatted(type: A.self)
        }
        let results: [Result<A>] = words.map { word, count in
            guard let attribute = attributes[word] else {
                return Result(word: word, count: count, attribute: nil)
            }
            return Result(word: word, count: count, attribute: attribute)
        }
        return Match(results: results, count: matches.count)
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

}
