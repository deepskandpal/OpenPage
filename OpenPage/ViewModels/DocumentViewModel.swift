import Foundation
import SwiftData
import Combine

class DocumentViewModel: ObservableObject {
    private var document: Document
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties for UI binding
    @Published var title: String
    @Published var content: String
    @Published var isFavorite: Bool
    @Published var tags: [String]
    @Published var wordCount: Int
    @Published var characterCount: Int
    
    // Editor state
    @Published var isEditing: Bool = false
    @Published var isDirty: Bool = false
    @Published var autoSaveTimer: Timer?
    @Published var lastSavedDate: Date?
    
    init(document: Document) {
        self.document = document
        self.title = document.title
        self.content = document.content
        self.isFavorite = document.isFavorite
        self.tags = document.tags
        self.wordCount = document.wordCount
        self.characterCount = document.characterCount
        
        // Set up bindings
        setupBindings()
    }
    
    private func setupBindings() {
        // Update word count and character count when content changes
        $content
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] newContent in
                guard let self = self else { return }
                self.updateCounts(for: newContent)
                self.isDirty = true
            }
            .store(in: &cancellables)
        
        // Update document title when title changes
        $title
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] newTitle in
                guard let self = self else { return }
                self.document.title = newTitle
                self.isDirty = true
            }
            .store(in: &cancellables)
    }
    
    func updateCounts(for content: String) {
        self.wordCount = content.split(separator: " ").count
        self.characterCount = content.count
    }
    
    func saveDocument() {
        document.title = title
        document.content = content
        document.isFavorite = isFavorite
        document.tags = tags
        document.wordCount = wordCount
        document.characterCount = characterCount
        document.updatedAt = Date()
        
        // Reset dirty flag and update last saved date
        isDirty = false
        lastSavedDate = Date()
    }
    
    func createSnapshot() {
        _ = document.createSnapshot()
    }
    
    func startAutoSave(interval: TimeInterval) {
        stopAutoSave()
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self, self.isDirty else { return }
            self.saveDocument()
        }
    }
    
    func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
} 