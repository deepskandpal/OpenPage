import Foundation
import SwiftData

/// Represents a conversation between the user and the AI assistant
@Model
final class Conversation {
    /// Unique identifier for the conversation
    @Attribute(.unique) var id: UUID
    
    /// The title of the conversation
    var title: String
    
    /// The timestamp when the conversation was created
    var createdAt: Date
    
    /// The timestamp when the conversation was last updated
    var updatedAt: Date
    
    /// The document ID this conversation is associated with (if any)
    var documentId: UUID?
    
    /// The document title this conversation is associated with (if any)
    var documentTitle: String?
    
    /// The messages in this conversation
    @Relationship(deleteRule: .cascade)
    var messages: [ChatMessage] = []
    
    /// Constructor
    init(title: String = "New Conversation", documentId: UUID? = nil, documentTitle: String? = nil) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.documentId = documentId
        self.documentTitle = documentTitle
    }
    
    /// Add a message to this conversation
    func addMessage(_ message: ChatMessage) {
        messages.append(message)
        updatedAt = Date()
        
        // Update the message's conversation details
        message.conversationId = id.uuidString
        message.conversationTitle = title
    }
    
    /// Clear all messages from this conversation
    func clearMessages() {
        messages.removeAll()
        updatedAt = Date()
    }
} 