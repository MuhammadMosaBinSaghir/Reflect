import SwiftUI

struct Background: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .underWindowBackground
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct Container: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(.primary.opacity(0.05))
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

struct Header: View {
    let label: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(label.capitalized)
            Spacer()
            Image(systemName: icon)
                .foregroundStyle(.primary)
                .symbolRenderingMode(.monochrome)
        }
        .bound(
            by: RoundedRectangle(cornerRadius: 8, style: .continuous),
            fill: .linearGrayed
        )
    }
}

struct Paragraph<Header: View, Content: View>: View {
    @ViewBuilder let header: () -> Header
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            header()
            .zIndex(1)
            .padding(2)
            content()
        }
        .font(.content)
        .background(Container())
    }
}

struct ExpandingParagraph<Header: View, Content: View>: View {
    @Binding var isExpanded: Bool
    @ViewBuilder var header: () -> Header
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                header()
                Spacer()
                Image(systemName: "chevron.down")
                    .imageScale(.large)
                    .rotationEffect(isExpanded ? .zero : .degrees(-90))
                    .onTapGesture {
                        withAnimation(.transition) {
                            isExpanded.toggle()
                        }
                    }
            }
            .padding(8)
            .foregroundStyle(.linearDark)
            .background(Container())
            if(isExpanded) {
                VStack(spacing: 4) {
                    content()
                }
                .padding(8)
                .background(Container())
            }
        }
        .font(.content)
    }
}

struct TagStack: Layout {
    var spacing: CGFloat? = nil
    
    init() {}
    
    init(spacing: CGFloat) { self.spacing = spacing }
    
    struct Block {
        var subview: CGSize
        var space: CGSize
        var endmost: Bool
    }
    
    struct Cache {
        var blocks: [Block]
        var bounds: CGSize
        var fittings: Int
    }

    func makeCache(subviews: Subviews) -> Cache {
        var spaces = [CGSize]()
        if let spacing {
            spaces = Array(repeating: CGSize(width: spacing, height: spacing), count: subviews.count)
            spaces[subviews.count - 1] = .zero
        }
        else { spaces = spacing(between: subviews) }
        var blocks: [Block] = subviews.indices.map {
            let dimensions = subviews[$0].sizeThatFits(.unspecified)
            let subview = CGSize(width: dimensions.width, height: dimensions.height)
            return Block(subview: subview, space: spaces[$0], endmost: false)
        }
        blocks[blocks.count - 1].endmost = true
        return Cache(blocks: blocks, bounds: .zero, fittings: 1)
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        guard !subviews.isEmpty else { return cache.bounds }
        guard cache.fittings < 2 else { return cache.bounds }
        let bounds = proposal.replacingUnspecifiedDimensions().width
        guard (bounds != .infinity && bounds != .zero) else { return .zero }
        var splits = [Int]()
        var index: Int = 0
        for _ in cache.blocks.indices {
            guard index < cache.blocks.count else { break }
            var length: CGFloat = cache.blocks[index].subview.width
            guard let split = fit(block: &index, within: cache.blocks, in: bounds, length: &length) else { break }
            splits.append(split)
            index += 1
        }
        let blocks: [Block] = cache.blocks.indices.map {
            guard splits.contains($0) else { return cache.blocks[$0] }
            return Block(
                subview: cache.blocks[$0].subview,
                space: CGSize(width: .zero, height: cache.blocks[$0].space.height),
                endmost: true
            )
        }
        cache.blocks = blocks
        let height = blocks.indices.reduce(CGFloat.zero) { height, index in
            guard !blocks[index].endmost else {
                return height + blocks[index].subview.height + blocks[index].space.height
            }
            return height
        }
        var length: CGFloat = .zero
        let lengths = blocks.reduce(into: [CGFloat]()) { lengths, block in
            length += block.subview.width + block.space.width
            if block.endmost { lengths.append(length); length = .zero }
        }
        guard let width = lengths.max() else { return .zero }
        cache.fittings += 1
        cache.bounds = CGSize(width: width, height: height)
        return cache.bounds
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let blocks = cache.blocks
        guard !subviews.isEmpty else { return }
        var point = CGPoint(x: bounds.minX, y: bounds.minY)
        for (index, block) in blocks.enumerated() {
            subviews[index].place(
                at: point, anchor: .zero, proposal: ProposedViewSize(block.subview)
            )
            if block.endmost { point.x = bounds.minX; point.y += block.subview.height + block.space.height}
            else { point.x += block.subview.width + block.space.width }
        }
    }
    
    private func spacing(between subviews: Subviews, from index: Int, along axis: Axis) -> CGFloat {
        return subviews[index].spacing.distance(
            to: subviews[index + 1].spacing,
            along: axis
        )
    }
    
    private func spacing(between subviews: Subviews) -> [CGSize] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return .zero }
            return CGSize(
                width: spacing(between: subviews, from: index, along: .horizontal),
                height: spacing(between: subviews, from: index, along: .vertical)
            )
        }
    }
    
    private func fit(block index: inout Int, within blocks: [Block], in bounds: CGFloat, length: inout CGFloat) -> Int? {
        guard index < blocks.count - 1 else { return nil }
        let subject = blocks[index]
        guard subject.endmost == false else { return nil }
        let neighbor = blocks[index + 1]
        length += subject.space.width + neighbor.subview.width
        let condition = length < bounds ? true : false
        guard condition else { length = 0; return index }
        index += 1
        return fit(block: &index, within: blocks, in: bounds, length: &length)
    }
}

struct CenteredScrollTargetBehavior: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        enum Direction { case left, right }
        enum Placement { case beginning, middle, end }
        
        let direction: Direction = if (context.velocity.dx < 0) { .left } else { .right }
        
        let placement: Placement = switch(context.records.selected) {
        case context.records.statements.first: .beginning
        case context.records.statements.last: .end
        default: .middle
        }
        
        let location = target.rect.minX
        let viewWidth = 344.0
        let offset = 36.0
        target.rect.origin.x =
        switch(placement) {
        case .beginning:
            switch(direction) {
            case .left: .zero
            case .right: ceil(location/viewWidth)*viewWidth - offset
            }
        case .middle:
            switch(direction) {
            case .left: floor(location/viewWidth)*viewWidth - offset
            case .right: ceil(location/viewWidth)*viewWidth - offset
            }
        case .end:
            switch(direction) {
            case .left: floor(location/viewWidth)*viewWidth - offset
            case .right: context.contentSize.width;
            }
        }
    }
}
