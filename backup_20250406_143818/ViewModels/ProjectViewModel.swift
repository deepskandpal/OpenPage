import Foundation
import SwiftData
import Combine

class ProjectViewModel: ObservableObject {
    private var project: Project
    private var cancellables = Set<AnyCancellable>()
    
    @Published var name: String
    @Published var summary: String
    @Published var color: String?
    @Published var icon: String?
    @Published var isArchived: Bool
    @Published var tags: [String]
    
    @Published var documents: [Document]
    @Published var isDirty: Bool = false
    
    init(project: Project) {
        self.project = project
        self.name = project.name
        self.summary = project.summary
        self.color = project.color
        self.icon = project.icon
        self.isArchived = project.isArchived
        self.documents = project.documents
        self.tags = project.tags
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Monitor name changes
        $name
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.project.name = newValue
                self.project.updatedAt = Date()
                self.isDirty = true
            }
            .store(in: &cancellables)
        
        // Monitor summary changes
        $summary
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.project.summary = newValue
                self.project.updatedAt = Date()
                self.isDirty = true
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Project Operations
    
    func saveProject() {
        project.name = name
        project.summary = summary
        project.color = color
        project.icon = icon
        project.isArchived = isArchived
        project.tags = tags
        project.updatedAt = Date()
        
        isDirty = false
    }
    
    func addDocument(_ document: Document) {
        project.addDocument(document)
        documents = project.documents
    }
    
    func createNewDocument(title: String = "Untitled") -> Document {
        let document = Document(title: title)
        addDocument(document)
        return document
    }
    
    func removeDocument(_ document: Document) {
        if let index = project.documents.firstIndex(where: { $0.id == document.id }) {
            project.documents.remove(at: index)
            documents = project.documents
            project.updatedAt = Date()
        }
    }
    
    // MARK: - Tag Operations
    
    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
            project.tags = tags
            project.updatedAt = Date()
            isDirty = true
        }
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        project.tags = tags
        project.updatedAt = Date()
        isDirty = true
    }
    
    // MARK: - Statistics
    
    var documentCount: Int {
        return documents.count
    }
    
    var totalWordCount: Int {
        return documents.reduce(0) { $0 + $1.wordCount }
    }
} 