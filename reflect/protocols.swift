import Foundation

protocol Attributable: Hashable {
    static var label: String { get }
    static var icon: String { get }

    func formatted() -> String
    static func undefined() -> Self
    static func parse(_ word: String) -> Self
}

protocol Empty {
    static var empty: Self { get }
}
