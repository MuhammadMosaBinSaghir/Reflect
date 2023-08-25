import Foundation

extension Description {
    struct DescriptionParseStrategy: ParseStrategy {
        func parse(_ word: String?) -> Description? {
            word?.formatted(.description)
        }
    }
    
    struct DescriptionFormatStyle: ParseableFormatStyle, CustomFormatStyle {
        var parseStrategy: DescriptionParseStrategy {
            return DescriptionParseStrategy()
        }
     
        func format(_ description: Description?) -> String? {
            return String.DescriptionParseStrategy.shared.parse(description)
        }
    }
    
    func formatted<S: CustomFormatStyle>(_ style: S = DescriptionFormatStyle()) -> S.FormatOutput? where S.FormatInput == Description? {
         return style.format(self)
     }
}
