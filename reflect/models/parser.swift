import Foundation
import Algorithms
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
    
    static let BMO = Parser(
            account: #"^DEBIT|CREDIT"#,
            date: #"^\d{8}"#,
            code: #"^\[[A-Z]{2}\]"#,
            amount: #"^-?\d+.\d{1,2}"#
        )
    
    static let undefined = Parser()
    
    func key(for attribute: Attributes) -> String {
        switch attribute {
        case .account: self.account
        case .date: self.date
        case .code: self.code
        case .amount: self.amount
        case .description: self.description
        }
    }
    
    func searching(in phrases: [[String]], for attribute: Attributes) -> [String] {
        guard let regex = Self.regex(from: self.key(for: attribute)) else { return .empty }
        
        var matchedAtIndex: Int = -1
        var startingPhraseIndex: Int = -1
        
        for (i, phrase) in phrases.enumerated() {
            guard matchedAtIndex == -1 else { break }
            for (j, word) in phrase.enumerated() {
                    if word.contains(regex) {
                        matchedAtIndex = j
                        startingPhraseIndex = i
                        break
                    }
            }
        }
        
        if matchedAtIndex == -1 { return .empty }
        var found = [String]()
        for index in startingPhraseIndex...(phrases.count - 1) {
            guard phrases[index].count > matchedAtIndex else { continue }
            found.append(phrases[index][matchedAtIndex])
        }
        return found
    }
    
    static func regex(from input: String) -> Regex<Substring>? {
        guard !input.isEmpty else { return nil }
        do { return try Regex(input) }
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
