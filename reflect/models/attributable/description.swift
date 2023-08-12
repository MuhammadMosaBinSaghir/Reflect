import Foundation
import Observation

@Observable
final class Description: Attributable {
    static let label: String = "description"
    static let icon: String = "square.and.pencil"
    
    var text: String
    required init(text: String) { self.text = text }
}
