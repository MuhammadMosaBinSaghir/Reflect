import SwiftUI

struct Bubble: View {
    var body: some View {
        RoundedRectangle.primary.fill(.bubble)
    }
}

struct Filling<C: Colorful, S: Shape, V: View>: View {
    let alignment: Alignment
    let color: C
    let shape: S
    let content: V
    
    var body: some View {
        ZStack(alignment: alignment) {
            color
            content
                .padding(6)
        }
        .clipShape(shape)
    }
    
    init(
        alignment: Alignment = .center,
        color: C = Color.bubble,
        shape: S = RoundedRectangle.secondary,
        @ViewBuilder content: () -> V
    ) {
        self.alignment = alignment
        self.color = color
        self.shape = shape
        self.content = content()
    }
}

struct Puller: View {
    var body: some View {
        HStack(spacing: -8) {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
        }
        .foregroundStyle(.primary.opacity(0.5))
        .frame(width: 16, height: 32)
    }
}

struct Paddle: View {
    let edge: HorizontalEdge
    let action: () -> Void
    
    var label: String {
        switch edge {
        case .leading: "Forwards"
        case .trailing: "Backwards"
        }
    }
    
    var icon: String {
        switch edge {
        case .leading: "chevron.left"
        case .trailing: "chevron.right"
        }
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Label(label, systemImage: icon)
        }
        .imageScale(.large)
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .foregroundStyle(.linearDark)
        .buttonRepeatBehavior(.enabled)
    }
}
