import Foundation

extension Array {
    static var empty: [Element] { [] }
}

extension Date: Attribute {
    static let label: String = "date"
    static let icon: String = "calendar"
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
