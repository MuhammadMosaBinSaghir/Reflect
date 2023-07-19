import SwiftUI

@main
struct Reflect: App {
    @State private var records = Records()
    
    var body: some Scene {
        WindowGroup {
            Window()
                .environment(\.records, records)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
