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
    
    static let undefined = Parser()
    static func breakdown(_ data: String) -> [Phrase] {
        var lines = data.components(separatedBy: "\n")
        lines.removeAll { $0 == .empty }
        let phrases = lines.enumerated().map { Phrase(row: $0.offset, words: $0.element) }
        return phrases.flatMap { phrase -> [Phrase] in
            let words = phrase.words.components(separatedBy: ",")
            return words.map { word in
                var trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmed.contains(" ") else { return Phrase(row: phrase.row, words: trimmed) }
                trimmed = trimmed.replacing(/\s{2,}/, with: " ")
                return Phrase(row: phrase.row, words: trimmed)
            }
        }
    }
    
    static func regex(from input: String) -> Regex<Substring>? {
        guard !input.isEmpty else { return nil }
        do { return try Regex(input) }
        catch { return nil }
    }
    
    func key(for attribute: Attributes) -> String {
        switch attribute {
        case .account: self.account
        case .date: self.date
        case .code: self.code
        case .amount: self.amount
        case .description: self.description
        }
    }
    
    func attribute(for key: String) -> Attributes? {
        switch key {
        case self.account: .account
        case self.date: .date
        case self.code: .code
        case self.amount: .amount
        case self.description: .description
        default: nil
        }
    }
    
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
}
