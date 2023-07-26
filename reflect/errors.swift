import Foundation

enum StatementError: String, Error {
    case blank = "blank"
    case duplicate = "duplicate"
    case undecodable = "undecodable"
    case undroppable = "undroppable"
    case unexplained = "unexplained"
    case unimportable = "unimportable"
    case unsupported = "unsupported"
}
