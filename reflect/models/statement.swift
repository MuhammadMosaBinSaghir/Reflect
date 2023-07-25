import Foundation
import Observation

@Observable
class Statement: Identifiable {
    let id = UUID()
    let date: Date
    var attributes: [Attribute]
    
    let name: String
    let type: String
    let data: String?
    var error: StatementError?
    
    init(name: String = "Unknown", type: String = "unknown", error: StatementError) {
        self.date = .now
        self.attributes = .empty
        
        self.name = name
        self.type = type
        self.data = nil
        self.error = error
    }
    
    init(date: Date = .now, name: String, type: String, data: String) {
        self.date = date
        var attributes: [Attribute] = .empty
        for contraint in Attribute.Constraint.allCases {
            attributes.append(Attribute(type: contraint))
        }
        self.attributes = attributes
        
        self.name = name
        self.type = type
        self.data = data
        self.error = nil
    }
}
