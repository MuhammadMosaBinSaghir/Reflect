import SwiftUI

extension Transaction: Hashable {
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Statement: Hashable {
    static func == (lhs: Statement, rhs: Statement) -> Bool {
        (lhs.name == rhs.name) && (lhs.type == rhs.type)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
    }
}

extension Records {
    var isErrored: Bool { !errors.isEmpty }
    var isEmpty: Bool { statements.isEmpty }
    
    func addDuplicate(name: String, type: String) { errors.append(.init(name: name, type: type, error: .duplicate)) }
    func addBlank(name: String, type: String) { errors.append(.init(name: name, type: type, error: .blank)) }
    
    func addUndecodable(name: String, type: String) { errors.append(.init(name: name, type: type, error: .undecodable)) }
    func addUndroppable() { errors.append(.init(error: .undroppable)) }
    func addUnimportable() { errors.append(.init(error: .unimportable)) }
    func addUnsupported(name: String, type: String) { errors.append(.init(name: name, type: type, error: .unsupported)) }
}

extension EnvironmentValues {
    var records: Records {
        get { self[RecordKey.self] }
        set { self[RecordKey.self] = newValue }
    }
}

private struct RecordKey: EnvironmentKey {
    static var defaultValue: Records = Records()
}
