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
                .pilled(fill: .linearThemed)
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

struct Forms: View {
    @Bindable var parser: Parser
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8) {
                Editor(
                    attribute: .account,
                    count: parser.accounts.count,
                    key: $parser.keys.account
                ) {
                    Content(for: parser.accounts)
                }
                Editor(
                    attribute: .date,
                    count: parser.dates.count,
                    key: $parser.keys.date
                ) {
                    Content(for: parser.dates)
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder private func Content(for match: Parser.Match) -> some View {
        if !match.results.isEmpty {
            ForEach(match.results.sorted(by: >), id: \.key) { key, count in
                HStack(spacing: 4) {
                    Text(count.formatted())
                        .boxed(fill: .bubble)
                    HStack(spacing: 4) {
                        Text(key)
                        Text(match.converts)
                        Spacer()
                    }
                    .boxed(fill: .bubble)
                }
            }
        } else {
            HStack(spacing: 4) {
                Text("There are no matches")
                    .foregroundStyle(.placeholder)
                Spacer()
            }
            .boxed(fill: .bubble)
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
                Forms(parser: records.selected?.parser ?? .undefined)
            }
        }
        .animation(.scroll, value: target)
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
                Text(Date.label)
                    .pilled(fill: .linearThemed)
                Text(Account.label)
                    .pilled(fill: .linearThemed)
                Text(Description.label)
                    .pilled(fill: .linearThemed)
                Text(Amount.label)
                    .pilled(fill: .linearThemed)
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
