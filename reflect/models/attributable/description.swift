import Foundation
import Observation

@Observable
final class Description: Attributable {
    static let label: AttributeLabel = .description
    static let icon: String = "square.and.pencil"
    static func undefined() -> Description { .init(text: .empty) }
    static func parse(from string: String) -> Description {
        .init(text: string)
    }
    var text: String
    func formatted() -> String { text.split(separator: " ").filter { !$0.isEmpty }.joined(separator: " ") }
    required init(text: String) { self.text = text }
}
