import Foundation

extension Array: Empty {
    static var empty: Array<Element> { Array<Element>() }
}

extension Dictionary: Empty {
    static var empty: Dictionary<Key, Value> { Dictionary<Key, Value>() }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

extension Set: Empty {
    static var empty: Set<Element> { Set<Element>() }
}

extension String: Empty {
    static let empty: String = ""
}
