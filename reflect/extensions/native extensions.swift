import Foundation

extension Array {
    static var empty: [Element] { [] }
}

extension Date: Attributable {
    static let label: AttributeLabel = .date
    static let icon: String = "calendar"
    static func undefined() -> Self { Date.now }
    static func parse(from string: String) -> Date {
        let strategy = Date.ParseStrategy(
            format: "\(year: .extended(minimumLength: 4))\(month: .twoDigits)\(day: .twoDigits)",
            locale: .current,
            timeZone: .current
        )
        let date = try? Date(string, strategy: strategy)
        return date ?? .now
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

extension String {
    static let empty: String = ""
}
