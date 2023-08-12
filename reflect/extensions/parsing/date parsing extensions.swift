import Foundation

struct DateParseStrategy: ParseStrategy {
    func parse(_ word: String?) -> Date? {
        word?.formatted(.date)
    }
}

extension Date {
    struct DateFormatStyle: ParseableFormatStyle, CustomFormatStyle {
        var parseStrategy: DateParseStrategy {
            return DateParseStrategy()
        }
     
        func format(_ date: Date?) -> String? {
            return String.DateParseStrategy.shared.parse(date)
        }
    }
    
    func formatted<S: CustomFormatStyle>(_ style: S = DateFormatStyle()) -> S.FormatOutput? where S.FormatInput == Date? {
         return style.format(self)
     }
}
