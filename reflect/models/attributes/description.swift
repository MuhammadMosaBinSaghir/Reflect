import Foundation
import Observation

@Observable
class Description: Attribute {
    static let label: String = "description"
    static let icon: String = "square.and.pencil"

    var text: String
    func formatted() -> String { text.split(separator: " ").filter { !$0.isEmpty }.joined(separator: " ") }
    init(text: String) { self.text = text }
}
