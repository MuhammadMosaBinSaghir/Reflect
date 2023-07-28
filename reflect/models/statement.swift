import Foundation
import Observation

@Observable
class Statement: Identifiable {
    let id = UUID()
    let date: Date
    let name: String
    let type: String
    let data: String?
    
    let theme: Theme?
    let transactions: [Transaction]
    
    var error: StatementError?
    
    init(name: String = "Unknown", type: String = "unknown", error: StatementError) {
        self.date = .now
        self.name = name
        self.type = type
        self.data = nil
        
        self.theme = nil
        self.transactions = .empty
        
        self.error = error
    }
    
    init(date: Date = .now, name: String, type: String, theme: Theme, data: String) {
        self.date = date
        self.name = name
        self.type = type
        self.data = data
        
        self.theme = theme
        self.transactions = theme.parse(from: data)
        self.error = nil
    }
}
