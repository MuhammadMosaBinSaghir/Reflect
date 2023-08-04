import Foundation
import Observation

struct Phrase {
    let row: Int
    let count: Int
    let words: String
    var attributes: Set<Attributes>
    
    init(row: Int, words: String, attributes: Set<Attributes> = .empty) {
        self.row = row
        self.count = 1
        self.words = words
        self.attributes = attributes
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
    let source: [[String]]
    
    //TO MANT UI UPDATES CAUSE ATTRIBUTES
    //DONT IMEDIATLY RECALCULATE, ONLY ON SUBMIT, CAUSE WHY CALCULATE WHEN STILL TYPING OR WHEN USER STOPPED TYPING
    //NOW U HAVE UNIQUE, SO DONT REDEFINE IT!
    //MIGHT GET TO DELETE ROW IN PHRASE
    //mmight be better to just use [[String]] than to chunch it later
    //remove SwiftAlgorithms
    //remove Phrase
    //REMOVE .BMO
    
    var attributes: [String] {
        guard let parser = self.parser else { return .empty }
        return parser.searching(in: source, for: .account)
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
