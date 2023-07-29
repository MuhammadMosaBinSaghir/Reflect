import Foundation

extension Account: Hashable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

extension Amount: Hashable {
    static func == (lhs: Amount, rhs: Amount) -> Bool {
        lhs.worth == rhs.worth
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(worth)
    }
}

extension Category: Hashable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

extension Code: Hashable {
    static func == (lhs: Code, rhs: Code) -> Bool {
        lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

extension Description: Hashable {
    static func == (lhs: Description, rhs: Description) -> Bool {
        lhs.text == rhs.text
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}

extension Merchant: Hashable {
    static func == (lhs: Merchant, rhs: Merchant) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
