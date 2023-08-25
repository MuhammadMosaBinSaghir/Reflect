import SwiftUI
    
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
