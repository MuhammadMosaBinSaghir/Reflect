import Foundation
import Observation

@Observable class Records: ObservableObject {
    var statements: [Statement]
    var errors: [Statement]
    
    init() {
        self.statements = .empty
        self.errors = .empty
    }

    func pull(from url: URL) {
        let name = url.deletingPathExtension().lastPathComponent.capitalized
        let type = url.pathExtension == "" ? "folder" : url.pathExtension.lowercased()
        guard let dropped = try? Data(contentsOf: url) else { addUndecodable(name: name, type: type); return }
        guard let data = String(data: dropped, encoding: .utf8) else { addUndecodable(name: name, type: type); return }
        guard !data.isEmpty else { addBlank(name: name, type: type); return }
        let size = statements.count
        statements.append(.init(name: name, type: type, data: data))
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
