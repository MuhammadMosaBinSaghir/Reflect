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
    
    //TO MANT UI UPDATES CAUSE ATTRIBUTES
    //DONT IMEDIATLY RECALCULATE, USE SEARCH DEPT
    //remove Phrase
    //REMOVE .BMO
    //implement search depth
    //implement which row got it
    //FocusState: when something click, it goes there and opens it, then on next goes to next field/ then done
    //undefined list
    //proxy works as soon as your typing
    //found 78 occurences of "DEBIT" and they were processed as .debit
    
    init(name: String = "Unknown", type: String = "unknown", error: StatementError) {
        self.date = .now
        self.name = name
        self.type = type
        self.error = error
        self.parser = nil
    }
    
    init(date: Date = .now, name: String, type: String, data: String) {
        self.date = date
        self.name = name
        self.type = type
        self.error = nil
        self.parser = Parser(source: data)
    }
    
    static let undefined: Statement = .init(error: .undefined)
}
