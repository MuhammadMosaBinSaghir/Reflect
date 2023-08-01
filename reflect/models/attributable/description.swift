import Foundation
import Observation

@Observable
final class Description: Attributable {
    static let label: String = "description"
    static let icon: String = "square.and.pencil"
    static func undefined() -> Description { .init(text: .empty) }
    static func parse(_ word: String) -> Description { .init(text: word) }
    
    var text: String
    func formatted() -> String { text.split(separator: " ").filter { !$0.isEmpty }.joined(separator: " ") }
    required init(text: String) { self.text = text }
}
