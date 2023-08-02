import Foundation
import Observation

struct Phrase {
    let row: Int
    let count: Int
    let words: String
    var attribute: Attributes?
    
    init(row: Int, words: String, attribute: Attributes? = nil) {
        self.row = row
        self.count = 1
        self.words = words
        self.attribute = attribute
    }
}


extension Phrase: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs.words == rhs.words) && (lhs.row == rhs.row)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(words)
    }
}

@Observable
final class Statement: Identifiable {
    let id = UUID()
    let date: Date
    let name: String
    let type: String
    var error: StatementError?
    var parser: Parser?
    let source: [Phrase]
    
    var attributes: [Phrase] {
        guard let parser = self.parser else { return .empty }
        let keys: [(regex: Regex<Substring>, attribute: Attributes)?] = Attributes.allCases.map {
            guard let regex = Parser.regex(from: parser.key(for: $0)) else { return nil }
            return (regex: regex, attribute: $0)
        }
        let compacted = keys.compactMap { $0 }
        guard !compacted.isEmpty else { return .empty }
        return source.map { phrase in
            for key in compacted {
                if phrase.words.contains(key.regex) {
                    return Phrase(row: phrase.row, words: phrase.words, attribute: key.attribute)
                }
            }
            return Phrase(row: phrase.row, words: phrase.words)
        }
    }
    
    init(name: String = "Unknown", type: String = "unknown", error: StatementError) {
        self.date = .now
        self.name = name
        self.type = type
        self.error = error
        self.parser = nil
        self.source = .empty
    }
    
    init(date: Date = .now, name: String, type: String, parser: Parser, data: String) {
        self.date = date
        self.name = name
        self.type = type
        self.error = nil
        self.parser = parser
        self.source = Parser.breakdown(data)
    }
    
    static let undefined: Statement = .init(error: .undefined)
}
