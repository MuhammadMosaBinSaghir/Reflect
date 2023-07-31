import Foundation
import Observation

@Observable
final class Merchant: Attributable {
    static let label: AttributeLabel = .merchant
    static let icon: String = "cart"
    static func undefined() -> Merchant { .init(name: .undefined) }
    static func parse(from string: String) -> Merchant {
        .init(name: .init(rawValue: string) ?? .undefined)
    }
    
    var name: MerchantName
    func formatted() -> String { name.rawValue }
    
    required init(name: MerchantName) { self.name = name }
    enum MerchantName: String, CaseIterable { case undefined }
}
