import Foundation
import Observation

@Observable
final class Records {
    var statements: [Statement]
    var errors: [Statement]
    
    var selected: Statement?
    
    enum Target { case first, previous, next, last }
    
    init() {
        self.statements = .empty
        self.errors = .empty
        self.selected = nil
    }
    
    func select(_ target: Statement.ID?) {
        guard let index = statements.firstIndex(where: { $0.id == target }) else { return }
        selected = statements[index]
    }
    
    func select(_ target: Target) -> Statement.ID? {
        switch target {
        case .first:
            selected = statements.first
        case .previous:
            guard selected != statements.first else { return statements.first?.id }
            guard let index = statements.firstIndex(where: { $0.id == selected?.id }) else { return nil }
            selected = statements[index - 1]
        case .next:
            guard selected != statements.last else { return statements.last?.id }
            guard let index = statements.firstIndex(where: { $0.id == selected?.id}) else { return nil }
            selected = statements[index + 1]
        case .last:
            selected = statements.last
            return selected?.id
        }
        return selected?.id
    }

    func pull(from url: URL) {
        let name = url.deletingPathExtension().lastPathComponent.capitalized
        let type = url.pathExtension == "" ? "folder" : url.pathExtension.lowercased()
        guard type == "csv" else { addUnsupported(name: name, type: type); return }
        guard let dropped = try? Data(contentsOf: url) else { addUndecodable(name: name, type: type); return }
        guard let data = String(data: dropped, encoding: .utf8) else { addUndecodable(name: name, type: type); return }
        guard !data.isEmpty else { addBlank(name: name, type: type); return }
        let size = statements.count
        statements.append(.init(name: name, type: type, parser: .init(), block: data))
        statements = statements.unique()
        if statements.count == size { addDuplicate(name: name, type: type) }
    }
    
    func fetch(from providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            guard let identifier = provider.registeredTypeIdentifiers.first else { addUndroppable(); return false }
            guard identifier == "public.file-url" else { addUndroppable(); return false }
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url { DispatchQueue.main.async { self.pull(from: url) } }
            }
        }
        return true
    }
}
