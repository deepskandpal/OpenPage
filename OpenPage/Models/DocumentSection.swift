import Foundation
import SwiftData

// Metadata for document sections
@Model
final class SectionMetadata {
    var status: String
    var label: String?
    var synopsis: String?
    var notes: String?
    var customFields: [String: String]
    var color: String?
    
    init(
        status: String = "draft",
        label: String? = nil,
        synopsis: String? = nil,
        notes: String? = nil,
        color: String? = nil
    ) {
        self.status = status
        self.label = label
        self.synopsis = synopsis
        self.notes = notes
        self.customFields = [:]
        self.color = color
    }
}

// Document section model for hierarchical document structure
@Model
final class DocumentSection {
    // Core properties
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    // Hierarchical properties
    @Relationship(deleteRule: .cascade, inverse: \DocumentSection.parent)
    var children: [DocumentSection]?
    
    var parent: DocumentSection?
    var sortOrder: Int
    
    // Types
    var type: String  // "text", "folder", "header", etc.
    var isContainer: Bool  // True for folders, false for leaf documents
    
    // Metadata
    var metadata: SectionMetadata?
    
    // Document relationship
    var document: Document?
    
    // Statistics
    var wordCount: Int
    var characterCount: Int
    
    init(
        title: String,
        content: String = "",
        type: String = "text",
        isContainer: Bool = false,
        parent: DocumentSection? = nil,
        sortOrder: Int = 0,
        document: Document? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.type = type
        self.isContainer = isContainer
        self.parent = parent
        self.sortOrder = sortOrder
        self.document = document
        self.children = isContainer ? [] : nil
        self.wordCount = content.split(separator: " ").count
        self.characterCount = content.count
        self.metadata = SectionMetadata()
    }
    
    // MARK: - Content Management
    
    func updateCounts() {
        if isContainer {
            var totalWords = 0
            var totalChars = 0
            
            // Sum up counts from children
            if let children = children {
                for child in children {
                    child.updateCounts()
                    totalWords += child.wordCount
                    totalChars += child.characterCount
                }
            }
            
            self.wordCount = totalWords
            self.characterCount = totalChars
        } else {
            self.wordCount = content.split(separator: " ").count
            self.characterCount = content.count
        }
        
        self.updatedAt = Date()
        
        // Propagate changes upward
        if let parent = parent {
            parent.updateCounts()
        }
    }
    
    // MARK: - Section Management
    
    func addChild(_ section: DocumentSection) {
        guard isContainer else { return }
        
        if children == nil {
            children = []
        }
        
        section.parent = self
        section.document = self.document
        
        // Find the highest sort order and place this one after
        if let children = children {
            let maxOrder = children.map { $0.sortOrder }.max() ?? -1
            section.sortOrder = maxOrder + 1
        }
        
        children?.append(section)
        updateCounts()
    }
    
    func removeChild(_ section: DocumentSection) {
        guard isContainer, let children = children else { return }
        
        // Create a new array without the section to remove
        let updatedChildren = children.filter { $0.id != section.id }
        
        // Replace the children array
        self.children = updatedChildren
        
        updateCounts()
    }
    
    func moveChildUp(_ section: DocumentSection) {
        guard let children = children,
              let index = children.firstIndex(where: { $0.id == section.id }),
              index > 0 else { return }
        
        // Get copies of the elements with their new sort orders
        var childrenCopy = children
        let previousOrder = childrenCopy[index - 1].sortOrder
        
        // Update the sort orders
        childrenCopy[index - 1].sortOrder = section.sortOrder
        section.sortOrder = previousOrder
    }
    
    func moveChildDown(_ section: DocumentSection) {
        guard let children = children,
              let index = children.firstIndex(where: { $0.id == section.id }),
              index < children.count - 1 else { return }
        
        // Get copies of the elements with their new sort orders
        var childrenCopy = children
        let nextOrder = childrenCopy[index + 1].sortOrder
        
        // Update the sort orders
        childrenCopy[index + 1].sortOrder = section.sortOrder
        section.sortOrder = nextOrder
    }
    
    // MARK: - Hierarchy Utilities
    
    var pathComponents: [String] {
        var components: [String] = [self.title]
        var current = self.parent
        
        while let parent = current {
            components.insert(parent.title, at: 0)
            current = parent.parent
        }
        
        return components
    }
    
    var depth: Int {
        var level = 0
        var current = self.parent
        
        while current != nil {
            level += 1
            current = current?.parent
        }
        
        return level
    }
    
    // MARK: - Content Access
    
    var combinedContent: String {
        guard isContainer, let children = children else { return content }
        
        var result = content
        
        // Sort children by sort order
        let sortedChildren = children.sorted { $0.sortOrder < $1.sortOrder }
        
        for child in sortedChildren {
            if !result.isEmpty {
                result += "\n\n"
            }
            result += child.combinedContent
        }
        
        return result
    }
} 