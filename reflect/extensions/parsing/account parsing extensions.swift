import Foundation

extension Account {
    struct AccountParseStrategy: ParseStrategy {
        func parse(_ word: String?) -> Account? {
            word?.formatted(.account)
        }
    }
    
    struct AccountFormatStyle: ParseableFormatStyle, CustomFormatStyle {
        var parseStrategy: AccountParseStrategy {
            return AccountParseStrategy()
        }
     
        func format(_ account: Account?) -> String? {
            return String.AccountParseStrategy.shared.parse(account)

        }
    }
    
    func formatted<S: CustomFormatStyle>(_ style: S = AccountFormatStyle()) -> S.FormatOutput? where S.FormatInput == Account? {
         return style.format(self)
     }
}

