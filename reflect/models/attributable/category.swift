import Foundation
import Observation

@Observable
final class Category: Attributable {
    static let label: AttributeLabel = .category
    static let icon: String = "tag"
    static func undefined() -> Category { .init(type: .undefined) }
    static func parse(from string: String) -> Category {
        .init(type: .init(rawValue: string) ?? .undefined)
    }
    
    var type: CategoryType
    func formatted() -> String { type.rawValue }

    required init(type: CategoryType) { self.type = type }
    enum CategoryType: String, CaseIterable { case undefined }
}
