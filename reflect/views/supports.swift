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

struct Form<A: Attributable>: View {
    struct Match {
        var word: String
        var count: Int
        var attribute: A?
    }
    
    let attribute: A.Type
    let source: [[String]]
    @Binding var key: String
    
    private let columns = [
        GridItem(.fixed(32), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.fixed(88), spacing: 4)
    ]
    private var regex: Regex<Substring>? {
        guard !key.isEmpty else { return nil }
        do { return try Regex("^"+key) }
        catch { return nil }
    }
    private var count: Int {
        matches.reduce(0) { count, match in
            count + match.count
        }
    }
    private var matches: [Match] {
        guard let regex else { return .empty }
        guard let index = source.firstIndex(where: { $0.contains { $0.contains(regex) } } ) else { return .empty }
        let column = source[index].firstIndex { $0.contains(regex) }!
        let words: [String] = (index..<source.count).compactMap {
            guard source[$0].count > column else { return nil }
            return source[$0][column]
        }
        let uniques = words.reduce(into: [:]) { dictionary, element in
            dictionary[element, default: 0] += 1
        }
        let attributes = uniques.reduce(into: [String: A?]()) { dictionary, element in
            dictionary[element.key] = element.key.formatted(type: A.self)
        }
        return uniques.map { word, count in
            guard let attribute = attributes[word] else {
                return Match(word: word, count: count, attribute: nil)
            }
            return Match(word: word, count: count, attribute: attribute)
        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4, pinnedViews: [.sectionHeaders]) {
            Section {
                ForEach(matches, id: \.word) { match in
                    Filling {
                        Text(match.count.formatted())
                            .monospacedDigit()
                    }
                    Filling(alignment: .leading) { Text(match.word) }
                    Filling(alignment: .trailing) {
                        Text(formatted(attribute: match.attribute) ?? "?")
                            .monospacedDigit()
                    }
                }
            } header: {
                header()
            }
        }
        .font(.content)
        .animation(.transition, value: count)
    }

    private func formatted(attribute: A?) -> String? {
        guard let attribute else { return nil }
        guard let type = Attributes(rawValue: A.self) else { return nil }
        switch type {
        case .account:
            guard let account = attribute as? Account else { return nil }
            guard let formatted = account.formatted() else { return nil }
            return formatted
        case .amount:
            guard let amount = attribute as? Amount else { return nil }
            guard let formatted = amount.formatted() else { return nil }
            return formatted
        case .date:
            guard let date = attribute as? Date else { return nil }
            guard let formatted = date.formatted() else { return nil }
            return formatted
        case .description:
            guard let description = attribute as? Description else { return nil }
            guard let formatted = description.formatted() else { return nil }
            return formatted
        }
    }
    
    @ViewBuilder private func header() -> some View {
        Grid(horizontalSpacing: 4) {
            GridRow {
                if !key.isEmpty {
                    Filling(color: .linearThemed) {
                        Text(count.formatted())
                            .monospacedDigit()
                    }
                    .frame(width: 32)
                    .transition(.move(edge: .leading))
                }
                ZStack(alignment: .leading) {
                    TextEditor(text: $key)
                        .frame(maxHeight: 16)
                        .scrollIndicators(.hidden)
                        .boxed(fill: key.isEmpty ? .linearBubble : .linearThemed)
                    if key.isEmpty {
                        Text("Enter an expression for the \(A.label)s column")
                            .foregroundStyle(.placeholder)
                            .padding(.leading, 10)
                    }
                }
                if !key.isEmpty {
                    HStack(spacing: 4) {
                        Filling(color: .linearThemed) { Text("as") }
                            .frame(width: 32)
                        Filling(color: .linearThemed) { Text(A.label) }
                            .frame(width: 88)
                    }
                    .transition(.move(edge: .trailing))
                }
            }
        }
    }
}


struct Forms: View {
    let source: [[String]]
    
    @State private var accountKey: String = .empty
    @State private var amountKey: String = .empty
    @State private var dateKey: String = .empty
    @State private var descriptionKey: String = .empty
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8) {
                Form(attribute: Account.self, source: source, key: $accountKey)
                Form(attribute: Amount.self, source: source, key: $amountKey)
                Form(attribute: Date.self, source: source, key: $dateKey)
                Form(attribute: Description.self, source: source, key: $descriptionKey)
            }
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .animation(.transition, value: accountKey)
        .animation(.transition, value: amountKey)
        .animation(.transition, value: dateKey)
        .animation(.transition, value: descriptionKey)
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
