import Foundation
import Observation

@Observable
class Card: Attribute {
    static let label: String = "card"
    static let icon: String = "creditcard"
    
    //let name: String
    let number: String //Uint16
    
    init(number: String) {
        self.number = number
    }
}
