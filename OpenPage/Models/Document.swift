import Foundation
import SwiftData

@Model
final class DocumentVersion {
    var content: String
    var timestamp: Date
    var wordCount: Int
    var notes: String?
    var document: Document?
    
    init(content: String, timestamp: Date, wordCount: Int, notes: String? = nil) {
        self.content = content
        self.timestamp = timestamp
        self.wordCount = wordCount
        self.notes = notes
    }
}

@Model
final class Document {
    // Core properties
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var tags: [String] = []
    
    // Metadata
    var isFavorite: Bool
    var wordCount: Int
    var characterCount: Int
    var lastCursorPosition: Int
    var author: String?
    var synopsis: String?
    var category: String?
    var status: String?  // "draft", "in progress", "complete", "archived"
    
    // Writing goals
    var targetWordCount: Int?
    var deadline: Date?
    var dailyWordCountGoal: Int?
    var lastWritingSession: Date?
    var timeSpentWriting: Int?  // In minutes
    
    // Relationship with project - proper inverse relationship
    var project: Project?
    
    // Version tracking - proper one-to-many relationship
    @Relationship(deleteRule: .cascade, inverse: \DocumentVersion.document)
    var versions: [DocumentVersion] = []
    
    // Formatting
    var fontName: String?
    var fontSize: Double?
    var themePreference: String?
    var templateType: String?
    
    // Hierarchical document structure - single root section owns all children
    @Relationship(deleteRule: .cascade)
    var rootSection: DocumentSection?
    
    // Structure type
    var isHierarchical: Bool = false
    
    // For document status tracking
    var isDirty: Bool = false
    var lastSavedDate: Date?

    // Auto-save state (not the timer itself)
    var autoSaveEnabled: Bool = true
    var autoSaveInterval: TimeInterval = 30.0
    
    init(
        title: String = "Untitled",
        content: String = "",
        createdAt: Date = Date(),
        tags: [String] = [],
        isFavorite: Bool = false,
        author: String? = nil,
        category: String? = nil,
        templateType: String? = nil
    ) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.tags = tags
        self.isFavorite = isFavorite
        self.wordCount = content.split(separator: " ").count
        self.characterCount = content.count
        self.lastCursorPosition = 0
        self.versions = []
        self.author = author
        self.category = category
        self.status = "draft"
        self.templateType = templateType
        self.isHierarchical = false
    }
    
    func updateCounts() {
        if isHierarchical, let rootSection = rootSection {
            rootSection.updateCounts()
            self.wordCount = rootSection.wordCount
            self.characterCount = rootSection.characterCount
        } else {
            self.wordCount = content.split(separator: " ").count
            self.characterCount = content.count
        }
        self.updatedAt = Date()
    }
    
    func createSnapshot() -> DocumentVersion {
        let snapshotContent = isHierarchical ? (rootSection?.combinedContent ?? content) : content
        let snapshot = DocumentVersion(content: snapshotContent, timestamp: Date(), wordCount: self.wordCount)
        snapshot.document = self
        self.versions.append(snapshot)
        return snapshot
    }
    
    func setWritingGoal(targetWords: Int, deadline: Date? = nil, dailyGoal: Int? = nil) {
        self.targetWordCount = targetWords
        self.deadline = deadline
        self.dailyWordCountGoal = dailyGoal
    }
    
    var wordCountProgress: Double {
        guard let target = targetWordCount, target > 0 else { return 0 }
        return min(Double(wordCount) / Double(target), 1.0)
    }
    
    var daysUntilDeadline: Int? {
        guard let deadline = deadline else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return components.day
    }
    
    // MARK: - Hierarchical Structure Management
    
    /// Converts a flat document to a hierarchical structure
    func convertToHierarchical() {
        guard !isHierarchical else { return }
        
        // Create a root container section
        let root = DocumentSection(
            title: self.title,
            content: "",
            type: "root",
            isContainer: true
        )
        
        // Create a content section with the current document content
        let contentSection = DocumentSection(
            title: "Content",
            content: self.content,
            type: "text",
            isContainer: false
        )
        
        // Add content section to root
        root.addChild(contentSection)
        
        // Setup document
        self.rootSection = root
        
        self.isHierarchical = true
        
        // Update counts
        updateCounts()
    }
    
    /// Converts a hierarchical document back to a flat structure
    func convertToFlat() {
        guard isHierarchical, let root = rootSection else { return }
        
        // Collect all content from the hierarchical structure
        let flatContent = collectAllContent(from: root)
        
        // Update document content
        self.content = flatContent
        
        // Remove the hierarchical structure
        self.rootSection = nil
        self.isHierarchical = false
        
        // Update counts
        updateCounts()
    }
    
    private func collectAllContent(from section: DocumentSection) -> String {
        var result = ""
        
        // Add this section's content if it's not empty
        if !section.content.isEmpty {
            if !result.isEmpty {
                result += "\n\n"
            }
            
            // Add section title as header if it's not "root" or "Content"
            if !section.title.isEmpty && section.title != "root" && section.title != "Content" {
                let headerLevel = min(section.depth + 1, 6)
                let headerPrefix = String(repeating: "#", count: headerLevel)
                result += "\(headerPrefix) \(section.title)\n\n"
            }
            
            result += section.content
        }
        
        // Add children content recursively
        if let children = section.children?.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            for child in children {
                let childContent = collectAllContent(from: child)
                if !childContent.isEmpty {
                    if !result.isEmpty {
                        result += "\n\n"
                    }
                    result += childContent
                }
            }
        }
        
        return result
    }
    
    /// Creates a new section in the document
    func createSection(title: String, content: String = "", type: String = "text", isContainer: Bool = false, parent: DocumentSection? = nil) -> DocumentSection {
        // If document is not hierarchical yet, convert it
        if !isHierarchical {
            convertToHierarchical()
        }
        
        // Determine parent
        let actualParent = parent ?? rootSection
        
        // Create new section
        let newSection = DocumentSection(
            title: title,
            content: content,
            type: type,
            isContainer: isContainer,
            parent: actualParent
        )
        
        // Add to parent
        actualParent?.addChild(newSection)
        
        // Section is now managed through the hierarchy
        
        // Update counts
        updateCounts()
        
        return newSection
    }
    
    /// Gets the combined content from all sections
    var combinedContent: String {
        if isHierarchical, let rootSection = rootSection {
            return rootSection.combinedContent
        } else {
            return content
        }
    }
    
    // MARK: - Document Management
    
    func saveDocument() {
        self.updatedAt = Date()
        self.isDirty = false
        self.lastSavedDate = Date()
    }
    
    // Auto-save configuration - timer management moved to DocumentService
    func configureAutoSave(enabled: Bool, interval: TimeInterval = 30.0) {
        self.autoSaveEnabled = enabled
        self.autoSaveInterval = interval
    }
} 