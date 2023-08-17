import SwiftUI

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
        .animation(.transition, value: accountKey)
        .animation(.transition, value: amountKey)
        .animation(.transition, value: dateKey)
        .animation(.transition, value: descriptionKey)
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
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8) {
                Form(attribute: Account.self, source: source, key: $accountKey)
                Form(attribute: Amount.self, source: source, key: $amountKey)
                Form(attribute: Date.self, source: source, key: $dateKey)
                Form(attribute: Description.self, source: source, key: $descriptionKey)
            }
        }
        .frame(minHeight: 136, maxHeight: height())
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
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
    
    private func height() -> CGFloat {
        guard accountKey.isEmpty else { return .infinity }
        guard amountKey.isEmpty else { return .infinity }
        guard dateKey.isEmpty else { return .infinity }
        guard descriptionKey.isEmpty else { return .infinity }
        return 136
    }
}
