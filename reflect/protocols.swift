import Foundation

protocol Attributable: Hashable {
    associatedtype Attribute
    
    static var label: AttributeLabel { get }
    static var icon: String { get }
    
    func formatted() -> String
    static func undefined() -> Attribute
    static func parse(from string: String) -> Self
}

