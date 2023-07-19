import SwiftUI

struct Searchbar: View {
    @Binding var popover: Bool
    @Binding var search: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $search)
                .textFieldStyle(.plain)
                .font(.title)
                .foregroundColor(.primary)
                .padding(16)
            Button {
                popover.toggle()
            } label: {
                Image(systemName: popover ? "tray" : "tray.full")
                    .font(.headline)
                    .imageScale(.large)
                    .symbolVariant(.fill)
                    .symbolRenderingMode(.hierarchical)
                    .animation(.transition, value: popover)
            }
            .buttonStyle(.plain)
            .padding(8)
        }
    }
}
