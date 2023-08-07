import Foundation
import Observation

@Observable
final class Statement: Identifiable {
    let id = UUID()
    let date: Date
    let name: String
    let type: String
    var error: StatementError?
    var parser: Parser?
    
    //found 78 occurences of "DEBIT" and they were processed as .debit
    //remove unused articles when using template
    //undefined list
    //buffer doesn't work since no update path
    //DONT IMEDIATLY RECALCULATE, USE SEARCH DEPT
    //implement which row got it
    //FocusState: when something click, it goes there and opens it, then on next goes to next field/ then done
    //proxy works as soon as your typing
    //use columns to identify
    //should only save the captured parts, needs to save!
    
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
