import Foundation

extension Amount {
    struct AmountParseStrategy: ParseStrategy {
        func parse(_ word: String?) -> Amount? {
            word?.formatted(.amount)
        }
    }
    
    struct AmountFormatStyle: ParseableFormatStyle, CustomFormatStyle {
        var parseStrategy: AmountParseStrategy {
            return AmountParseStrategy()
        }
     
        func format(_ amount: Amount?) -> String? {
            return String.AmountParseStrategy.shared.parse(amount)
        }
    }
    
    func formatted<S: CustomFormatStyle>(_ style: S = AmountFormatStyle()) -> S.FormatOutput? where S.FormatInput == Amount? {
         return style.format(self)
     }
}
