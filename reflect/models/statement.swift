import Foundation
import RegexBuilder
import Observation

@Observable
final class Statement: Identifiable {
    let id = UUID()
    let date: Date
    let name: String
    let type: String
    var parser: Parser?
    let data: [String]
    var error: StatementError?
    
    init(name: String = "Unknown", type: String = "unknown", error: StatementError) {
        self.date = .now
        self.name = name
        self.type = type
        self.parser = nil
        self.data = .empty
        self.error = error
    }
    
    init(date: Date = .now, name: String, type: String, parser: Parser, block: String) {
        self.date = date
        self.name = name
        self.type = type
        self.parser = parser
        self.data = parser.breakdown(block)
        self.error = nil
    }
    
    static let undefined: Statement = .init(error: .undefined)
}
