import SwiftUI

struct Dropbox: View {
    @EnvironmentObject var records: Records
    
    @Binding var expand: Bool
    @Binding var errored: Bool
    @Binding var problems: [Problem]
    
    @Namespace private var namespace
    @State private var imported: Bool = false
    
    enum Issue: Error { case undroppable, unimportable, undecodable, duplicate, empty, unexplained }
    
    @ViewBuilder func Bar() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text("**Issues**")
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
    
    @ViewBuilder func Cards() -> some View {
        if (!expand) {
            ZStack {
                Card(problems.first ?? Problem(file: "file", type: "type", issue: "issue"))
            }
            .onTapGesture { if problems.count > 1 { expand = true } }
            .matchedGeometryEffect(id: "issues", in: namespace, properties: .position, anchor: .top)
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(problems, id: \.file) { problem in
                        Card(problem)
                    }
                }
            }
            .frame(height: 136)
            .matchedGeometryEffect(id: "issues", in: namespace, properties: .position, anchor: .top)
        }
    }
    
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
    
    @ViewBuilder func Trash() -> some View {
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
    
    @ViewBuilder func Folder() -> some View {
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
    
    @ViewBuilder func Card(_ problem: Problem) -> some View {
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

// LINELIMT FOR TEXT
struct Documents: View {
    @EnvironmentObject var records: Records
    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(records.statements, id: \.id) { statement in
                        Card(statement)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func Card(_ statement: Statement) -> some View {
        //random order
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(statement.name.capitalized)")
                    .foregroundColor(.dark)
                Text("\(statement.date.formatted(date: .abbreviated, time: .omitted))")
            }
            .frame(width: 80, height: 32, alignment: .leading)
            .padding(.vertical, 5)
            .padding(.trailing, 8)
            Spacer()
                .overlay {
                    TagStack(spacing: 4) {
                        ForEach(statement.attributes, id: \.self) { attribute in
                            Text(attribute.constraint.name)
                                .font(.system(size: 12))
                                .capsuled(gradient: attribute.constrained ? .dark : .grayed)
                        }
                    }
                }
            Puller()
                .padding(.leading, 8)
        }
        .font(.system(size: 12))
        .padding(.trailing, 4)
        .padding([.top, .bottom, .leading], 16)
        .background(Container())
    }

}

/*
struct Documents: View {
    @EnvironmentObject var records: Records
    
    @State private var hovered: Statement?
    @State private var selected: Statement?
    
    func highlight(_ statement: Statement) -> Bool { (selected == statement)||(hovered == statement) }
    
    func delete() {
        if let selected, let index = records.statements.firstIndex(of: selected) {
                records.statements.remove(at: index)
        }
    }
    
    var body: some View {
        List(selection: $selected) {
            ForEach(records.statements, id: \.self) { statement in
                HStack{
                    Image(systemName: "doc.plaintext")
                        .font(.title)
                        .imageScale(.large)
                        .symbolVariant(.fill)
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(highlight(statement) ? .primary : .gray)
                        .rotation3DEffect(highlight(statement) ? Angle(degrees: 10) : .zero, axis: (x: 1, y: 0, z: 0))
                        .padding(2)
                    VStack(alignment: .leading){
                        Text("\(statement.name).\(statement.type)")
                        Text("added \(statement.date.formatted(date: .long, time: .omitted))")
                    }
                    .foregroundColor(highlight(statement) ? .primary : .gray )
                    Spacer()
                }
                .onHover {
                    if $0 { hovered = statement }
                    else { hovered = nil }
                }
                .animation(.reactive, value: highlight(statement))
            }
        }
        .background { Color.primary.opacity(0.05) }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }
}
*/

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
        .animation(.reactive, value: expand)
        .animation(.reactive, value: errored)
        .animation(.reactive, value: problems)
        .animation(.reactive, value: records.statements)
        .padding(8)
    }
}
