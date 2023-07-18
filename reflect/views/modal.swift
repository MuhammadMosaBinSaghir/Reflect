import SwiftUI

struct Dropbox: View {
    @EnvironmentObject var records: Records
    
    @Binding var expand: Bool
    @Binding var errored: Bool
    @Binding var problems: [Problem]
    
    @Namespace private var namespace
    @State private var imported: Bool = false
    
    enum Issue: Error { case undroppable, unimportable, undecodable, duplicate, empty, unexplained }
    
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
                .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                    do { return try fetch(providers) }
                    catch Issue.undroppable { errored = true; append(to: &problems, issue: .undroppable) }
                    catch { errored = true; append(to: &problems, issue: .undroppable) }
                    return false
                }
                .fileImporter(isPresented: $imported, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
                    switch result {
                    case .success(let urls):
                        for url in urls { transfer(from: url, to: &records.statements) }
                    case .failure:
                        errored = true; append(to: &problems, issue: .unimportable)
                    }
                }
                .transition(.asymmetric(
                    insertion: .push(from: .bottom),
                    removal: .push(from: .top)
                ))
            if errored {
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
            Text("**Issues**")
                .font(.title3.bold())
            Spacer()
            if (problems.count > 1 && expand) {
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
            .onTapGesture { errored = false; expand = false; problems.removeAll(); }
        }
    }
    
    @ViewBuilder private func Cards() -> some View {
        if (!expand) {
            ZStack {
                Card(problems.first ?? Problem(file: "file", type: "type", issue: "issue"))
            }
            .onTapGesture { if problems.count > 1 { expand = true } }
            .matchedGeometryEffect(id: "issues", in: namespace, properties: .position, anchor: .top)
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(problems, id: \.file) { problem in
                        Card(problem)
                    }
                }
                .scrollTargetLayout()
            }
            .frame(height: 136)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .matchedGeometryEffect(id: "issues", in: namespace, properties: .position, anchor: .top)
        }
    }
    
    @ViewBuilder private func Card(_ problem: Problem) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(problem.file.capitalized)
                    .foregroundStyle(Color.dark)
                Text(problem.type ?? "unprocessed")
            }
            .frame(width: 80, height: 32, alignment: .leading)
            .padding(.trailing, 8)
            Text(problem.issue)
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

    private func file(from url: URL) -> (name: String, type: String) {
        let name = url.deletingPathExtension().lastPathComponent
        let type = url.pathExtension == "" ? "folder" : url.pathExtension.lowercased()
        return (name, type)
    }
    
    private func decode(_ url: URL) throws -> (name: String, type: String, data: String) {
        guard let dropped = try? Data(contentsOf: url) else { throw Issue.undecodable }
        guard let data = String(data: dropped, encoding: .utf8) else { throw Issue.undecodable }
        let file = file(from: url)
        return (file.name, file.type, data)
    }
    
    private func append(form url: URL, to statements: inout [Statement]) throws {
        guard let decoded = try? decode(url) else { throw Issue.undecodable }
        let size = statements.count
        if !(decoded.data.isEmpty) {
            statements.append(
                Statement(
                    name: decoded.name,
                    type: decoded.type,
                    data: decoded.data
                )
            )
            statements = statements.unique()
            if statements.count == size { throw Issue.duplicate }
        } else { throw Issue.empty }
    }
    
    private func append(_ file: (name: String, type: String?) = ("Unknown", nil), to warnings: inout [Problem], issue: Issue) {
        switch(issue) {
        case .undroppable:
            warnings.append(Problem(file: file.name, type: file.type, issue: "undroppable"))
        case .unimportable:
            warnings.append(Problem(file: file.name, type: file.type, issue: "unimportable"))
        case .undecodable:
            warnings.append(Problem(file: file.name, type: file.type, issue: "undecodable"))
        case .duplicate:
            warnings.append(Problem(file: file.name, type: file.type, issue: "duplicate"))
        case .empty:
            warnings.append(Problem(file: file.name, type: file.type, issue: "empty"))
        case .unexplained:
            warnings.append(Problem(file: file.name, type: file.type, issue: "unexplained"))
        }
        warnings = warnings.unique()
    }
    
    private func transfer(from url: URL, to statements: inout [Statement]) {
        let file = file(from: url)
        do { try append(form: url, to: &statements) }
        catch Issue.undecodable { errored = true; append(file, to: &problems, issue: .undecodable) }
        catch Issue.duplicate { errored = true; append(file, to: &problems, issue: .duplicate) }
        catch Issue.empty { errored = true; append(file, to: &problems, issue: .empty) }
        catch { errored = true; append(file, to: &problems, issue: .unexplained) }
    }
    
    private func fetch(_ providers: [NSItemProvider]) throws -> Bool {
        for provider in providers {
            guard let identifier = provider.registeredTypeIdentifiers.first else { throw Issue.undroppable }
            guard identifier == "public.file-url" else { throw Issue.undroppable }
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url { DispatchQueue.main.async { transfer(from: url, to: &records.statements) } }
            }
        }
        return true
    }
}

struct Documents: View {
    @EnvironmentObject var records: Records
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
        //.animation(.reactive, value: selected)
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
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $target)
        .scrollIndicators(.never)
        .onAppear { target = records.statements.first?.id; print("on appear \(selected?.name ?? "nil"), id: \(target?.uuidString ?? "nil")")}
        .onChange(of: records.statements.count) { target = records.statements.last?.id }
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
                    Text(attribute.constraint.name)
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
        target = previous.id  //withAnimation(.smooth) { target = previous.id  }
    }
    
    private func next() {
        guard let current = target else { print("next() no target"); return }
        guard let next = find(statement: .next, from: current) else { return }
        target = next.id  //withAnimation(.smooth) { target = next.id }
    }

}

struct Modal: View {
    @EnvironmentObject var records: Records
    
    @State var expand: Bool = false
    @State var errored: Bool = false
    
    @State var problems = [Problem]()
    
    var body: some View {
        VStack {
            if !records.statements.isEmpty { Documents().transition(.move(edge: .top).combined(with: .opacity)) }
            Dropbox(expand: $expand, errored: $errored, problems: $problems)
        }
        .padding(8)
        .animation(.reactive, value: expand)
        .animation(.reactive, value: errored)
        .animation(.reactive, value: problems)
        .animation(.reactive, value: records.statements)

    }
}
