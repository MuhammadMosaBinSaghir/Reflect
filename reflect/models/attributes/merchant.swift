import Foundation
import Observation

@Observable
class Merchant: Attribute {
    static let label: String = "merchant"
    static let icon: String = "cart"

    let name: MerchantName
    enum MerchantName: CaseIterable { case Apple }
    
    init(name: MerchantName) { self.name = name }
}
