import SwiftUI

struct Form<A: Attributable>: View {
    let source: [[String]]
    @Binding var key: String
    @State private var count: Int = 0
    @State private var matches: [Match] = .empty
    
    private let alignment: Alignment =
    switch A.self {
    case is Amount.Type: .trailing
    default: .center
    }

    var body: some View {
        VStack(spacing: 4){
            header()
            if !matches.isEmpty {
                matcher()
            }
        }
        .animation(.transition, value: key.isEmpty)
    }
    
    private func reset() {
        count = 0
        matches = .empty
    }
    private func regex(from key: String) -> Regex<Substring>? {
        guard !key.isEmpty else { return nil }
        do { return try Regex("^"+key) }
        catch { return nil }
    }
    private func search(for regex: Regex<Substring>) {
        guard let index = source.firstIndex(where: { $0.contains { $0.contains(regex) } })
        else { count = 0; matches = .empty; return }
        let column = source[index].firstIndex { $0.contains(regex) }!
        let words: [String] = (index..<source.count).compactMap {
            guard source[$0].count > column else { return nil }
            return source[$0][column]
        }
        count = words.count
        let uniques = words.reduce(into: [:]) { dictionary, element in
            dictionary[element, default: 0] += 1
        }
        let attributes = uniques.reduce(into: [String: A?]()) { dictionary, element in
            dictionary[element.key] = element.key.formatted(type: A.self)
        }
        matches = uniques.map { word, count in
            guard let attribute = attributes[word] else {
                return Match(word: word, count: count, attribute: nil)
            }
            return Match(word: word, count: count, attribute: attribute)
        }
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
    
    @ViewBuilder private func counter() -> some View {
        if !key.isEmpty {
            Filling(color: .linearThemed) {
                Text("\(count)")
                    .monospacedDigit()
            }
            .frame(width: 32)
            .transition(.opacity)
        }
    }
    @ViewBuilder private func binding() -> some View {
        CustomTextField(
            placeholder: "Enter an expression for the \(A.label)s column",
            text: $key
        )
        .boxed(fill: key.isEmpty ? .linearBubble : .linearThemed)
        .onChange(of: key) { older, newer in
            withAnimation(.transition) {
                guard !key.isEmpty else { reset(); return }
                guard let regex = regex(from: newer) else { return }
                search(for: regex)
            }
        }
    }
    
    @ViewBuilder private func format() -> some View {
        if !key.isEmpty {
            HStack(spacing: 4) {
                Filling(color: .linearThemed) { Text("as") }
                    .frame(width: 32)
                Filling(color: .linearThemed) { Text(A.label) }
                    .frame(width: 88)
            }
            .transition(.opacity)
        }
    }
    @ViewBuilder private func header() -> some View {
        HStack(spacing: 4) {
            counter()
            binding()
            format()
        }
    }
    @ViewBuilder private func matcher() -> some View {
        ForEach(matches, id: \.word) { match in
            HStack(spacing: 4) {
                Filling {
                    Text(match.count.formatted())
                        .monospacedDigit()
                }
                .frame(width: 32)
                Filling(alignment: .leading) {
                    Text(match.word)
                }
                Filling(alignment: match.attribute == nil ? .center : alignment) {
                    Text(formatted(attribute: match.attribute) ?? "?")
                        .monospacedDigit()
                }
                .frame(width: 88)
            }
        }
    }
    
    struct Match: Equatable {
        var word: String
        var count: Int
        var attribute: A?
    }
}

struct Modal: View {
    @Environment(\.records) private var records
    
    @State private var target: Statement.ID?
    @State private var imported: Bool = false
    
    @State private var accountKey: String = .empty
    @State private var amountKey: String = .empty
    @State private var dateKey: String = .empty
    @State private var descriptionKey: String = .empty
    
    var body: some View {
        VStack(spacing: 8) {
            if !records.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Selector()
                    Forms()
                }
                .transition(.pop(from: .top))
            }
            Dropper()
        }
        .padding(8)
        .font(.content)
        .animation(.scroll, value: target)
        .animation(.transition, value: records.errors)
        .animation(.transition, value: records.statements)
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
        .background(Bubble())
    }
    @ViewBuilder private func Selecting(_ statement: Statement) -> some View {
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
        .background(Bubble())
    }
    @ViewBuilder private func Selector() -> some View {
        VStack {
            HStack(alignment: .center, spacing: 8) {
                Text("Statements")
                    .font(.header)
                Spacer()
                Dots()
            }
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(records.statements) { statement in
                        Selecting(statement)
                            .scrollingSlide()
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
    }
    
    @ViewBuilder private func Forms() -> some View {
        let source = records.selected?.data ?? .empty
        FittingScrollView {
            ScrollView(.vertical) {
                Form<Account>(source: source, key: $accountKey)
                Form<Amount>(source: source, key: $amountKey)
                Form<Date>(source: source, key: $dateKey)
                Form<Description>(source: source, key: $descriptionKey)
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
    }
    
    @ViewBuilder private func Dropper() -> some View {
        Filling {
            VStack(spacing: 16) {
                Image(systemName: "questionmark.folder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 32, alignment: .bottom)
                    .symbolVariant(.fill)
                    .foregroundStyle(.primary, .linearThemed)
                HStack(spacing: 0) {
                    Text("Upload")
                        .foregroundStyle(.dark)
                        .onTapGesture { imported = true }
                    Text(" or Drop Files")
                }
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
        .transition(.pop(from: .bottom))
    }
}
