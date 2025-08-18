import Foundation
import SwiftData

@Model
final class Project {
    var name: String
    var summary: String
    var createdAt: Date
    var updatedAt: Date
    var color: String?
    var icon: String?
    var isArchived: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \Document.project)
    var documents: [Document] = []
    
    var tags: [String] = []
    
    init(
        name: String,
        projectDescription: String = "",
        createdAt: Date = Date(),
        color: String? = nil,
        icon: String? = nil,
        isArchived: Bool = false,
        documents: [Document] = [],
        tags: [String] = []
    ) {
        self.name = name
        self.summary = projectDescription
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.color = color
        self.icon = icon
        self.isArchived = isArchived
        // Documents initialized as empty array
        self.tags = tags
    }
    
    var documentCount: Int {
        return documents.count
    }
    
    var totalWordCount: Int {
        return documents.reduce(0) { $0 + $1.wordCount }
    }
    
    func addDocument(_ document: Document) {
        documents.append(document)
        document.project = self
        updatedAt = Date()
    }
} 