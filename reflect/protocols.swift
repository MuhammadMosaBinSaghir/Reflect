import Foundation

protocol Attribute: Hashable {
    static var label: String { get }
    static var icon: String { get }
    
    func formatted() -> String
}
