import Foundation

extension String {
    struct AccountParseStrategy: ParseStrategy {
        func parse(_ account: Account?) -> String? {
            account?.type.rawValue
        }
    }
    
    struct AccountFormatStyle: ParseableFormatStyle {
        var parseStrategy: AccountParseStrategy {
            return AccountParseStrategy()
        }
     
        func format(_ word: String?) -> Account? {
            guard let word else { return nil }
            guard let type = Account.AccountType(rawValue: word) else { return nil }
            return Account(type: type)
        }
    }
    
    func formatted(_ formatStyle: AccountFormatStyle) -> Account? {
        formatStyle.format(self)
    }
}

extension String {
    struct AmountParseStrategy: ParseStrategy {
        func parse(_ amount: Amount?) -> String? {
            amount?.worth.formatted(.currency(code: "CAD"))
        }
    }
    
    struct AmountFormatStyle: ParseableFormatStyle {
        var parseStrategy: AmountParseStrategy {
            return AmountParseStrategy()
        }
     
        func format(_ word: String?) -> Amount? {
            guard let word else { return nil }
            guard let worth = Decimal(string: word) else { return nil }
            return Amount(worth: worth)
        }
    }
    
    func formatted(_ formatStyle: AmountFormatStyle) -> Amount? {
        formatStyle.format(self)
    }
}

extension String {
    struct DescriptionParseStrategy: ParseStrategy {
        func parse(_ description: Description?) -> String? {
            guard let text = description?.text else { return nil }
            return text.split(separator: " ").filter { !$0.isEmpty }.joined(separator: " ")
        }
    }
    
    struct DescriptionFormatStyle: ParseableFormatStyle {
        var parseStrategy: DescriptionParseStrategy {
            return DescriptionParseStrategy()
        }
     
        func format(_ word: String?) -> Description? {
            guard let word else { return nil }
            return Description(text: word)
        }
    }
    
    func formatted(_ formatStyle: DescriptionFormatStyle) -> Description? {
        formatStyle.format(self)
    }
}

extension String {
    struct DateParseStrategy: ParseStrategy {
        func parse(_ date: Date?) -> String? {
            guard let date else { return nil }
            return date.formatted(date: .long, time: .omitted)
        }
    }
    
    struct DateFormatStyle: ParseableFormatStyle {
        var parseStrategy: DateParseStrategy {
            return DateParseStrategy()
        }
     
        func format(_ word: String?) -> Date? {
            guard let word else { return nil }
            let format = Date.FormatString(stringLiteral: word)
            let strategy = Date.ParseStrategy(
                format: format,
                locale: .current,
                timeZone: .current
            )
            return try? Date(word, strategy: strategy)
        }
    }
    
    func formatted(_ formatStyle: DateFormatStyle) -> Date? {
        formatStyle.format(self)
    }
}

extension FormatStyle where Self == String.AccountFormatStyle {
    static var account: String.AccountFormatStyle {
        String.AccountFormatStyle()
    }
}

extension FormatStyle where Self == String.AmountFormatStyle {
    static var amount: String.AmountFormatStyle {
        String.AmountFormatStyle()
    }
}

extension FormatStyle where Self == String.DateFormatStyle {
    static var date: String.DateFormatStyle {
        String.DateFormatStyle()
    }
}

extension FormatStyle where Self == String.DescriptionFormatStyle {
    static var description: String.DescriptionFormatStyle {
        String.DescriptionFormatStyle()
    }
}

extension String {
    func formatted(attribute: Attributes) -> (any Attributable)? {
        switch(attribute) {
        case .account: formatted(.account)
        case .amount: formatted(.amount)
        case .date: formatted(.date)
        case .description: formatted(.description)
        }
    }
}