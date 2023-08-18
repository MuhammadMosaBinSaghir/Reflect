import SwiftUI

extension AnyTransition {
    
    static func myMove(forward: Binding<Bool>) -> AnyTransition {
        
        return .asymmetric(
            
            insertion: .modifier(
                
                active: MyMoveModifier(width: 100, forward: forward),
                
                identity: MyMoveModifier(width: 0, forward: .constant(true))
                
            ),
            
            removal: .modifier(
                
                active: MyMoveModifier(width: -100, forward: forward),
                
                identity: MyMoveModifier(width: 0, forward: .constant(true))
                
            )
            
        )
        
    }
    
}

struct MyMoveModifier: ViewModifier {
    
    let width: CGFloat
    
    @Binding var forward: Bool
    
    
    
    func body(content: Content) -> some View {
        
        content
            .offset(x: (forward ? 1 : -1) * width)
    }
}
    
struct CustomTextField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()

        field.focusRingType = .none
        field.isBezeled = false
        field.isBordered = false
        field.backgroundColor = NSColor.clear
        field.cell?.lineBreakMode = .byClipping
        field.delegate = context.coordinator
        field.stringValue = text
        let font = NSFont.preferredFont(forTextStyle: .body)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.placeholderTextColor]
        let placed = NSAttributedString(string: placeholder, attributes: attributes)
        field.placeholderAttributedString = placed
        return field
    }

    func updateNSView(_ view: NSTextField, context: Context) {
        view.stringValue = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension CustomTextField {
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: CustomTextField

        init(_ parent: CustomTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let field = obj.object as? NSTextField {
                parent.text = field.stringValue
            }
        }
    }
}
