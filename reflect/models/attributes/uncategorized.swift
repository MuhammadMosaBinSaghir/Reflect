import Foundation
import Observation

@Observable
class Uncategorized: Attribute {
    static let label: String = "uncategorized"
    static let icon: String = "questionmark"
    
    let data: String
    
    init(data: String) { self.data = data }
}
