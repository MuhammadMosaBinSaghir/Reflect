import Foundation
import Observation

@Observable
class Category: Attribute {
    static let label: String = "category"
    static let icon: String = "tag"
    
    var type: CategoryType
    func formatted() -> String { type.rawValue }

    init(type: CategoryType) { self.type = type }
    enum CategoryType: String, CaseIterable { case unknown }
}
