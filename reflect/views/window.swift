import SwiftUI

struct Dashboard<Searchbar: View, Sidebar: View, Contents: View, Modal: View>: View {
    
    @Binding var popover: Bool
    
    @ViewBuilder let searchbar: () -> Searchbar
    @ViewBuilder let sidebar: () -> Sidebar
    @ViewBuilder let contents: () -> Contents
    @ViewBuilder let modal: () -> Modal
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Background()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchbar()
                        .frame(maxWidth: geometry.size.width)
                    Divider()
                    HStack(spacing: 0) {
                        VStack {
                            sidebar()
                                .frame(
                                    minWidth: .width.sidebar,
                                    maxWidth: sidebar(if: expanded(for: geometry.size.width))
                                )
                        }
                        if expanded(for: geometry.size.width) {
                            contents()
                                .frame(width: content(for: geometry.size.width))
                            
                        }
                        if popover {
                            modal()
                                .frame(width: .width.modal)
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .animation(.reactive, value: popover)
                    .animation(.easeInOut, value: expanded(for: geometry.size.width))
                }
            }
        }
        .frame(minWidth: .width.sidebar + .width.modal, minHeight: .height.total)
    }
    
    func expanded(for width: CGFloat) -> Bool {
        let unpopovered: CGFloat = .width.sidebar + .width.content
        let popovered: CGFloat = .width.total
        return popover ? width >= popovered :  width >= unpopovered
    }
    
    func sidebar(if expanded: Bool) -> CGFloat {
        expanded ? .width.sidebar : .width.sidebar + .width.content
    }
    
    func content(for width: CGFloat) -> CGFloat {
        let unpopovered: CGFloat = .width.sidebar
        let popovered: CGFloat = .width.sidebar + .width.modal
        return popover ? width - popovered : width - unpopovered
    }
}

struct Window: View {
    @StateObject private var records = Records()
    
    @State private var popover: Bool = false
    @State private var search: String = ""
    
    var body: some View {
        Dashboard(popover: $popover, searchbar: {
            Searchbar(popover: $popover, search: $search)
                .toolbar {}
        }, sidebar: {
            Sidebar()
        }, contents: {
            Contents()
        }, modal: {
            Modal()
        })
        .environmentObject(records)
    }
}
