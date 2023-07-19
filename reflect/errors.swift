import Foundation

enum StatementError: String, Error {
    case undroppable = "undroppable"
    case unimportable = "unimportable"
    case undecodable = "undecodable"
    case duplicate = "duplicate"
    case blank = "blank"
    case unexplained = "unexplained"
}
