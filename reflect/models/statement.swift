import Foundation
import Observation

@Observable
final class Statement: Identifiable {
    let id = UUID()
    let date: Date
    let name: String
    let type: String
    let data: [String]
    var definition: Definition?
    var error: StatementError?
    
    var accounts: [String] {
        guard let definition = self.definition else { return .empty }
        return self.data.filter { data in
            data.contains(definition.regex(from: definition.account))
        }
    }
    
    init(name: String = "Unknown", type: String = "unknown", error: StatementError) {
        self.date = .now
        self.name = name
        self.type = type
        self.data = .empty
        self.definition = nil
        self.error = error
    }
    
    init(date: Date = .now, name: String, type: String, definition: Definition, data: String) {
        self.date = date
        self.name = name
        self.type = type
        let lines = data.components(separatedBy: "\n")
        let compacted = lines.joined(separator: ",")
        self.data = compacted.components(separatedBy: ",").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        self.definition = definition
        self.error = nil
    }
    
    static let undefined: Statement = .init(error: .undefined)
}
