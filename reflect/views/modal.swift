import SwiftUI

struct Dropbox: View {
    @Environment(\.records) private var records
    
    @Binding var expand: Bool
    @State private var imported: Bool = false
    
    @Namespace private var namespace

    var body: some View {
        VStack {
            Container()
                .overlay {
                    VStack(spacing: 16) {
                        Folder()
                        HStack(spacing: 0) {
                            Text("Upload")
                                .foregroundStyle(.dark)
                                .onTapGesture { imported = true }
                            Text(" or Drop Files")
                        }.font(.content)
                    }
                }
                .frame(minHeight: 136)
                .onDrop(of: ["public.file-url"], isTargeted: nil) { records.fetch(from: $0) }
                .fileImporter(isPresented: $imported, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
                    switch result {
                    case .success(let urls):
                        for url in urls { records.pull(from: url) }
                    case .failure: records.addUnimportable()
                    }
                }
                .transition(.asymmetric(
                    insertion: .push(from: .bottom),
                    removal: .push(from: .top)
                ))
            if records.isErrored {
                VStack(alignment: .leading, spacing: 0) {
                    Bar()
                    Cards()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    @ViewBuilder private func Bar() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text("Errors")
                .font(.header)
            Spacer()
            if (records.errors.count > 1 && expand) {
                HStack(alignment: .center, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Collapse")
                        Image(systemName: "chevron.down")
                    }
                    .padding(4)
                    .foregroundStyle(.dark)
                    .background(Container())
                    .onTapGesture { expand = false }
                    Trash()
                }
                .matchedGeometryEffect(id: "bar buttons", in: namespace, properties: .position, anchor: .trailing)
            } else {
                Trash()
                    .matchedGeometryEffect(id: "bar buttons", in: namespace, properties: .position, anchor: .trailing)
            }
        }
        .font(.content)
        .padding([.bottom, .leading], 8)
    }
    
    
    @ViewBuilder private func Trash() -> some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(spacing: 4) {
                Text("Clear")
                Image(systemName: "trash")
                    .symbolVariant(.fill)
            }
            .padding(4)
            .foregroundColor(.dark)
            .background(Container())
            .onTapGesture { expand = false; records.errors.removeAll(); }
        }
    }
    
    @ViewBuilder private func Cards() -> some View {
        if (!expand) {
            ZStack {
                Card(records.errors.first ?? Statement(error: .unexplained))
            }
            .onTapGesture { if records.errors.count > 1 { expand = true } }
            .matchedGeometryEffect(id: "errors", in: namespace, properties: .position, anchor: .top)
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(records.errors) { error in
                        Card(error)
                    }
                }
                .scrollTargetLayout()
            }
            .frame(height: 136)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .matchedGeometryEffect(id: "errors", in: namespace, properties: .position, anchor: .top)
        }
    }
    
    @ViewBuilder private func Card(_ statement: Statement) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(statement.name)
                    .foregroundStyle(.dark)
                Text(statement.type)
            }
            .frame(width: 80, height: 32, alignment: .leading)
            .padding(.trailing, 8)
            Text(statement.error?.rawValue ?? "invalid error")
                .bound(by: .init(Capsule(style: .continuous)), fill: .init(.linearDark))
            Spacer()
            Puller()
        }
        .font(.content)
        .padding(.trailing, 4)
        .padding([.top, .bottom, .leading], 16)
        .background(Container())
    }
    
    @ViewBuilder private func Folder() -> some View {
        Image(systemName: "questionmark.folder")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 32, alignment: .bottom)
            .symbolVariant(.fill)
            .foregroundStyle(.primary, .linearThemed)
    }
}

struct Documents: View {
    @Environment(\.records) private var records
    @State private var target: Statement.ID?
    
    @Namespace private var namespace
    
    private var selected: Statement? {
        guard let id = target else { return nil }
        guard let selected = find(statement: .current, from: id) else { return nil }
        return selected
    }
    
    enum Target: Error { case previous, current, next }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Paddle(edge: .leading) { previous() }
                    HStack(alignment: .center, spacing: 4) {
                        Text("Statements")
                            .font(.header)
                        Spacer()
                    }
                    Paddle(edge: .trailing) { next() }
                }
                Cards(frame: proxy.size)
                Container()
            }
        }
        .animation(.scroll, value: target)
    }
    
    @ViewBuilder private func Cards(frame size: CGSize) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(records.statements) { statement in
                    Card(statement)
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .rotation3D(
                                    phase.isIdentity ? .zero : phase.value < 0 ? .degrees(-45) : .degrees(45),
                                    axis: (x: 0, y: 1, z: 0),
                                    anchorZ: statement.id == target ? 0 : 1
                                )
                                .blur(radius: phase.isIdentity ? 0 : 1)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.centered)
        .scrollPosition(id: $target)
        .scrollIndicators(.never)
        .onAppear { target = records.statements.first?.id }
    }

    @ViewBuilder private func Card(_ statement: Statement) -> some View {
        HStack(spacing: 8) {
            TagStack(spacing: 4) {
                ForEach(statement.attributes, id: \.self) { attribute in
                    if statement.id == target {
                        Text(attribute.name)
                            .font(.content)
                            .bound(by: .init(Capsule(style: .continuous)), fill: .init(.linearDark))
                            .matchedGeometryEffect(
                                id: statement.name + attribute.name,
                                in: namespace, properties: .position, anchor: .center
                            )
                    } else {
                        Image(systemName: attribute.icon)
                            .symbolVariant(.circle.fill)
                            .symbolRenderingMode(.hierarchical)
                            .matchedGeometryEffect(
                                id: statement.name + attribute.name,
                                in: namespace, properties: .position, anchor: .center
                            )
                    }
                }
            }
            .font(statement.id == target ? .content : .icons)
            .frame(width: statement.id == target ? 208 : 120)
            .padding(8)
            .background(Container())
        }
    }
    
    private func find(statement: Target, from id: Statement.ID) -> Statement? {
        guard let index = records.statements.firstIndex(where: { $0.id == id }) else { return nil }
        switch statement {
        case .previous:
            guard target != records.statements.first?.id else { return nil }
            return records.statements[index - 1]
        case .current: return records.statements[index]
        case .next:
            guard target != records.statements.last?.id else { return nil }
            return records.statements[index + 1]
        }
    }
    
    private func previous() {
        guard let current = target else { return }
        guard let previous = find(statement: .previous, from: current) else { return }
        withAnimation(.scroll) { target = previous.id  }
    }
    
    private func next() {
        guard let current = target else { return }
        guard let next = find(statement: .next, from: current) else { return }
        withAnimation(.scroll) { target = next.id }
    }

}

struct Modal: View {
    @Environment(\.records) private var records
    
    @State var expand: Bool = false
    
    var body: some View {
        VStack {
            if !records.isEmpty { Documents().transition(.move(edge: .top).combined(with: .opacity)) }
            Dropbox(expand: $expand)
        }
        .padding(8)
        .animation(.transition, value: expand)
        .animation(.transition, value: records.errors)
        .animation(.transition, value: records.statements)
    }
}
