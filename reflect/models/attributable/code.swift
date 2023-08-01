import Foundation
import Observation

@Observable
final class Code: Attributable {
    static let label: String = "code"
    static let icon: String = "gearshape"
    static func undefined() -> Code { .init(type: .undefined) }
    static func parse(_ word: String) -> Code { .init(type: .init(rawValue: word) ?? .undefined)}
    
    var type: CodeType
    func formatted() -> String { type.rawValue }
    
    required init(type: CodeType) { self.type = type }
    enum CodeType: String, CaseIterable {
        case A0
        case AD
        case BC
        case CB
        case CC
        case CD
        case CK
        case CM
        case CW
        case DC
        case DD
        case DM
        case DN
        case DR
        case DS
        case EC
        case FX
        case GS
        case IB
        case IN
        case LI
        case LN
        case LP
        case LT
        case MB
        case NR
        case NS
        case NT
        case OL
        case OM
        case OP
        case OV
        case PR
        case RC
        case RN
        case RT
        case RV
        case SC
        case SO
        case ST
        case TF
        case TX
        case WD
        case undefined
    }
}
