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
                Card(records.errors.first ?? Statement(error: .undefined))
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
                .bound(by: Capsule(style: .continuous), fill: .linearDark)
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

struct Definer: View {
    @Bindable var definition: Definition
    
    @State private var clicked = Array(repeating: true, count: 5)
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 8) {
                    ExpandingParagraph(
                        label: Account.label.rawValue,
                        icon: Account.icon,
                        expand: $clicked[0]
                    ) {
                        TextField("Type a Regular Expresssion", text: $definition.account, axis: .vertical)
                            .padding(8)
                            .textFieldStyle(.plain)
                            .lineLimit(2, reservesSpace: true)
                    }
                    ExpandingParagraph(
                        label: Date.label.rawValue,
                        icon: Date.icon,
                        expand: $clicked[1]
                    ) {
                        TextField("Type a Regular Expresssion", text: $definition.date, axis: .vertical)
                            .padding(8)
                            .textFieldStyle(.plain)
                            .lineLimit(2, reservesSpace: true)
                    }
                    ExpandingParagraph(
                        label: Code.label.rawValue,
                        icon: Code.icon,
                        expand: $clicked[2]
                    ) {
                        TextField("Type a Regular Expresssion", text: $definition.code, axis: .vertical)
                            .padding(8)
                            .textFieldStyle(.plain)
                            .lineLimit(2, reservesSpace: true)
                    }
                    ExpandingParagraph(
                        label: Amount.label.rawValue,
                        icon: Amount.icon,
                        expand: $clicked[3]
                    ) {
                        TextField("Type a Regular Expresssion", text: $definition.amount, axis: .vertical)
                            .padding(8)
                            .textFieldStyle(.plain)
                            .lineLimit(2, reservesSpace: true)
                    }
                    ExpandingParagraph(
                        label: Description.label.rawValue,
                        icon: Description.icon,
                        expand: $clicked[4]
                    ) {
                        TextField("Type a Regular Expresssion", text: $definition.description, axis: .vertical)
                            .padding(8)
                            .textFieldStyle(.plain)
                            .lineLimit(2, reservesSpace: true)
                    }
                }
            }
            .font(.content)
            .animation(.snappy, value: clicked)
            .scrollIndicators(.never)
        }
    }
}

struct Documents: View {
    @Environment(\.records) private var records
    @State private var target: Statement.ID?
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    Text("Statements")
                        .font(.header)
                    Spacer()
                    Dots()
                }
                Badges()
                HStack(spacing: 8) {
                    Definer(definition: records.selected?.definition ?? .bank)
                    Data(of: records.selected ?? .undefined)
                        .frame(width: 0.7*proxy.size.width)
                }
            }
        }
        .animation(.scroll, value: target)
    }
    
    @ViewBuilder private func Data(of statement: Statement) -> some View {
        Paragraph {
            Header(label: "Statement", icon: "text.bubble")
        } content: {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(statement.data, id: \.self) {
                        Text($0)
                            .padding(8)
                            .multilineTextAlignment(.leading)
                            .background(Container())
                            .foregroundStyle(statement.accounts.contains($0) ? .dark : .red)
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func Badges() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(records.statements) { statement in
                    Badge(statement)
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .blur(radius: phase.isIdentity ? 0 : 5)
                                .scaleEffect(
                                    phase.isIdentity ? 1 : 0.5,
                                    anchor: anchor(for: phase)
                                )
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.centered)
        .scrollPosition(id: $target)
        .scrollIndicators(.never)
        .onAppear { target = records.select(.first) }
        .onChange(of: target) { records.select($1) }
    }
    
    @ViewBuilder private func Badge(_ statement: Statement) -> some View {
        HStack(spacing: 8) {
            Paddle(edge: .leading) { target = records.select(.previous) }
            VStack(alignment: .leading, spacing: 0) {
                Text("\(statement.name)")
                    .foregroundStyle(statement.id == target ? .dark : .primary)
                Text("\(statement.date.formatted(date: .abbreviated, time: .omitted))")
            }
            .frame(width: 80, height: 32, alignment: .leading)
            TagStack(spacing: 4) {
                Text(Date.label.rawValue)
                    .bound(by: Capsule(style: .continuous), fill: .linearDark)
                Text(Account.label.rawValue)
                    .bound(by: Capsule(style: .continuous), fill: .linearDark)
                Text(Description.label.rawValue)
                    .bound(by: Capsule(style: .continuous), fill: .linearDark)
                Text(Merchant.label.rawValue)
                    .bound(by: Capsule(style: .continuous), fill: .linearDark)
                Text(Category.label.rawValue)
                    .bound(by: Capsule(style: .continuous), fill: .linearDark)
                Text(Amount.label.rawValue)
                    .bound(by: Capsule(style: .continuous), fill: .linearDark)
            }
            .frame(width: 192)
            Paddle(edge: .trailing) { target = records.select(.next) }
        }
        .padding(8)
        .font(.content)
        .background(Container())
    }
    
    @ViewBuilder private func Dots() -> some View {
        HStack {
            ForEach(records.statements) { statement in
                Capsule(style: .continuous)
                    .frame(width: statement.id == target ? 16 : 4, height: 4)
                    .foregroundStyle(statement.id == target ? .linearThemed : .linearGrayed)
            }
        }
        .padding(8)
        .background(Container())
    }
    
    private func anchor(for phase: ScrollTransitionPhase) -> UnitPoint {
        switch(phase.value) {
        case -1: .leading
        case 1: .trailing
        default: .center
        }
    }
}

struct Modal: View {
    @Environment(\.records) private var records
    
    @State var expand: Bool = false
    
    var body: some View {
        VStack {
            if !records.isEmpty {
                Documents()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Dropbox(expand: $expand)
        }
        .padding(8)
        .animation(.transition, value: expand)
        .animation(.transition, value: records.errors)
        .animation(.transition, value: records.statements)
    }
}
