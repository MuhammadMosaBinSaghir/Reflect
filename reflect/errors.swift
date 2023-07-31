import Foundation

enum StatementError: String, Error {
    case blank = "blank"
    case duplicate = "duplicate"
    case undecodable = "undecodable"
    case undroppable = "undroppable"
    case undefined = "undefined"
    case unimportable = "unimportable"
    case unsupported = "unsupported"
}
