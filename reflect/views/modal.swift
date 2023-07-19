import SwiftUI

struct Dropbox: View {
    @Environment(\.records) private var records
    
    @Binding var expand: Bool
    
    @Namespace private var namespace
    @State private var imported: Bool = false

    var body: some View {
        VStack {
            Container()
                .overlay {
                    VStack(spacing: 16) {
                        Folder()
                        HStack(spacing: 0) {
                            Text("Upload")
                                .shadow(color: .primary.opacity(0.1), radius: 1, x: 1, y: 1)
                                .foregroundStyle(Color.dark)
                                .onTapGesture { imported = true }
                            Text(" or Drop Files")
                        }.font(.system(size: 12))
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
                .font(.title3.bold())
            Spacer()
            if (records.errors.count > 1 && expand) {
                HStack(alignment: .center, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Collapse")
                        Image(systemName: "chevron.down")
                    }
                    .padding(4)
                    .foregroundColor(.dark)
                    .background(Container())
                    .shadow(color: .primary.opacity(0.1), radius: 1, x: 1, y: 1)
                    .onTapGesture { expand = false }
                    Trash()
                }
                .matchedGeometryEffect(id: "bar buttons", in: namespace, properties: .position, anchor: .trailing)
            } else {
                Trash()
                    .matchedGeometryEffect(id: "bar buttons", in: namespace, properties: .position, anchor: .trailing)
            }
        }
        .font(.system(size: 12))
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
            .shadow(color: .primary.opacity(0.1), radius: 1, x: 1, y: 1)
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
                    .foregroundStyle(Color.dark)
                Text(statement.type)
            }
            .frame(width: 80, height: 32, alignment: .leading)
            .padding(.trailing, 8)
            Text(statement.error?.rawValue ?? "invalid error")
                .capsuled(gradient: LinearGradient.dark)
            Spacer()
            Puller()
        }
        .font(.system(size: 12))
        .padding(.trailing, 4)
        .padding([.top, .bottom, .leading], 16)
        .background(Container())
    }
    
    @ViewBuilder private func Folder() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 36, height: 20)
                .offset(y: -8)
                .foregroundStyle(.primary)
            Image(systemName: "questionmark.folder")
                .font(.system(size: 36))
                .symbolVariant(.fill)
                .foregroundStyle(.primary, LinearGradient.themed)
        }
    }
}

struct Documents: View {
    @Environment(\.records) private var records
    @State var target: Statement.ID?
    
    var selected: Statement? {
        guard let id = target else { print("selected, no target"); return nil }
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
                            .font(.title3.bold())
                        Spacer()
                    }
                    Paddle(edge: .trailing) { next() }
                }
                Cards(frame: proxy.size)
                Container()
            }
        }
    }
    
    @ViewBuilder private func Cards(frame size: CGSize) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(records.statements) { statement in
                    Card(statement)
                        .frame(width: 344)
                }
            }
            .frame(height: 66)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.centered)
        .scrollPosition(id: $target)
        .scrollIndicators(.never)
        .onAppear { target = records.statements.first?.id; print("on appear \(selected?.name ?? "nil"), id: \(target?.uuidString ?? "nil")")}
        .onChange(of: records.statements.count) {
                switch (($1 - $0).signum()) {
                case 1: withAnimation(.scroll) { target = records.statements.last?.id }
                case -1: withAnimation(.scroll) { target = records.statements.last?.id }
                default: return
                }
            
        }
    }

    @ViewBuilder private func Card(_ statement: Statement) -> some View {
        HStack(spacing: 8) {
            Puller()
            VStack(alignment: .leading, spacing: 0) {
                Text("\(statement.name.capitalized)")
                    .foregroundStyle(statement.id == target ? Color.dark : .primary)
                Text("\(statement.date.formatted(date: .abbreviated, time: .omitted))")
            }
            .frame(width: 80, height: 32, alignment: .leading)
            TagStack(spacing: 4) {
                ForEach(statement.attributes, id: \.self) { attribute in
                    Text(attribute.name)
                        .font(.system(size: 12))
                        .capsuled(gradient: attribute.constrained ? .dark : .grayed)
                }
            }
            .frame(width: 192)
            Puller()
        }
        .padding(8)
        .font(.system(size: 12))
        .background(Container())
    }
    
    private func find(statement: Target, from id: Statement.ID) -> Statement? {
        guard let index = records.statements.firstIndex(where: { $0.id == id }) else {  print("could not find, returned"); return nil }
        switch statement {
        case .previous:
            guard target != records.statements.first?.id else { print("find .previous, returned"); return nil }
            return records.statements[index - 1]
        case .current: return records.statements[index]
        case .next:
            guard target != records.statements.last?.id else {  print("find .next, returned"); return nil }
            return records.statements[index + 1]
        }
    }
    
    private func previous() {
        guard let current = target else { print("previous() no target"); return }
        guard let previous = find(statement: .previous, from: current) else { return }
        withAnimation(.scroll) { target = previous.id  }
    }
    
    private func next() {
        guard let current = target else { print("next() no target"); return }
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
