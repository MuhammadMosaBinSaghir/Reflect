import Foundation
import Observation

@Observable
class Merchant: Attribute {
    static let label: String = "merchant"
    static let icon: String = "cart"

    var name: MerchantName
    func formatted() -> String { name.rawValue }
    
    init(name: MerchantName) { self.name = name }
    enum MerchantName: String, CaseIterable { case unknown }
}
