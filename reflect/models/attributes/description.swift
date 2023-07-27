import Foundation
import Observation

@Observable
class Description: Attribute {
    static let label: String = "description"
    static let icon: String = "square.and.pencil"

    let text: String
    
    init(text: String) { self.text = text }
}
