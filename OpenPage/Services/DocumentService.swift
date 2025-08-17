import Foundation
import SwiftData
import Combine

/// Service responsible for document operations and auto-save functionality
/// Removes business logic from SwiftData models
@MainActor
class DocumentService: ObservableObject {
    private var autoSaveTimers: [PersistentIdentifier: Timer] = [:]
    private let modelContext: ModelContext
    
    var container: ModelContainer {
        modelContext.container
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Auto-Save Management
    
    func startAutoSave(for document: Document) {
        guard document.autoSaveEnabled else { return }
        
        stopAutoSave(for: document)
        
        let documentId = document.id
        let timer = Timer.scheduledTimer(withTimeInterval: document.autoSaveInterval, repeats: true) { @Sendable [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                // Find the document by ID to avoid capturing the document directly
                let descriptor = FetchDescriptor<Document>(predicate: #Predicate<Document> { doc in
                    doc.id == documentId
                })
                guard let currentDocument = try? self.modelContext.fetch(descriptor).first,
                      currentDocument.isDirty else { return }
                self.saveDocument(currentDocument)
            }
        }
        
        autoSaveTimers[document.id] = timer
    }
    
    nonisolated func stopAutoSave(for document: Document) {
        Task { @MainActor in
            autoSaveTimers[document.id]?.invalidate()
            autoSaveTimers.removeValue(forKey: document.id)
        }
    }
    
    nonisolated func stopAllAutoSave() {
        Task { @MainActor in
            autoSaveTimers.values.forEach { $0.invalidate() }
            autoSaveTimers.removeAll()
        }
    }
    
    // MARK: - Document Operations
    
    func saveDocument(_ document: Document) {
        document.saveDocument()
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save document: \(error)")
        }
    }
    
    func createDocument(
        title: String = "Untitled",
        content: String = "",
        project: Project? = nil
    ) -> Document {
        let document = Document(
            title: title,
            content: content
        )
        
        if let project = project {
            project.addDocument(document)
        }
        
        modelContext.insert(document)
        startAutoSave(for: document)
        
        return document
    }
    
    func deleteDocument(_ document: Document) {
        stopAutoSave(for: document)
        modelContext.delete(document)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete document: \(error)")
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopAllAutoSave()
    }
}