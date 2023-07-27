import Foundation
import Observation

@Observable
class Category: Attribute {
    static let label: String = "category"
    static let icon: String = "tag"
    
    let type: CategoryType
    enum CategoryType: CaseIterable { case mortgage }
    
    init(type: CategoryType) { self.type = type }
}
