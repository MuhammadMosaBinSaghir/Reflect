import SwiftUI

class Records: ObservableObject {
    @Published var statements = [Statement]()
}
