import Foundation
import Observation

@Observable
final class Statement: Identifiable {
    let id = UUID()
    let date: Date
    let name: String
    let type: String
    var error: StatementError?
    var data: [[String]]
    
    init(name: String = "Unknown", type: String = "unknown", error: StatementError) {
        self.date = .now
        self.name = name
        self.type = type
        self.error = error
        self.data = .empty
    }
    
    init(date: Date = .now, name: String, type: String, phrases: String) {
        self.date = date
        self.name = name
        self.type = type
        self.error = nil
        self.data = Statement.breakdown(phrases)
    }
    
    static let undefined: Statement = .init(error: .undefined)
    static private func breakdown(_ phrases: String) -> [[String]] {
        var lines = phrases.components(separatedBy: "\n")
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
