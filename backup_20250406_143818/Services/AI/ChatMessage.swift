import Foundation
import SwiftData

/// Represents a message in a chat conversation with the AI assistant
@Model
final class ChatMessage {
    /// Unique identifier for the message
    @Attribute(.unique) var id: UUID
    
    /// The role of the message sender
    var role: MessageRole
    
    /// The content of the message
    var content: String
    
    /// The timestamp when the message was created
    var timestamp: Date
    
    /// The associated document, if any
    var documentId: UUID?
    
    /// The document title at the time the message was created, for reference
    var documentTitle: String?
    
    /// If this is a response to another message, the ID of that message
    var inReplyToId: UUID?
    
    /// Constructor
    init(role: MessageRole, content: String, documentId: UUID? = nil, documentTitle: String? = nil, inReplyToId: UUID? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.documentId = documentId
        self.documentTitle = documentTitle
        self.inReplyToId = inReplyToId
    }
}

/// The role of a message sender
enum MessageRole: String, Codable {
    case system
    case user
    case assistant
    
    var isAI: Bool {
        self == .assistant
    }
}

/// Represents a chat conversation consisting of multiple messages
@Model
final class Conversation {
    /// Unique identifier for the conversation
    @Attribute(.unique) var id: UUID
    
    /// The title of the conversation, either user-provided or generated
    var title: String
    
    /// The timestamp when the conversation was created
    var createdAt: Date
    
    /// The timestamp when the conversation was last modified
    var updatedAt: Date
    
    /// The messages in the conversation
    @Relationship(deleteRule: .cascade) var messages: [ChatMessage] = []
    
    /// The document ID this conversation is associated with, if any
    var documentId: UUID?
    
    /// Constructor
    init(title: String, documentId: UUID? = nil) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.documentId = documentId
    }
    
    /// Adds a message to the conversation
    /// - Parameter message: The message to add
    func addMessage(_ message: ChatMessage) {
        messages.append(message)
        updatedAt = Date()
    }
    
    /// Adds a system message to the conversation
    /// - Parameter content: The content of the system message
    func addSystemMessage(_ content: String) {
        let message = ChatMessage(role: .system, content: content)
        addMessage(message)
    }
    
    /// Adds a user message to the conversation
    /// - Parameters:
    ///   - content: The content of the user message
    ///   - documentId: The ID of the associated document, if any
    ///   - documentTitle: The title of the associated document, if any
    func addUserMessage(_ content: String, documentId: UUID? = nil, documentTitle: String? = nil) {
        let message = ChatMessage(
            role: .user,
            content: content,
            documentId: documentId,
            documentTitle: documentTitle
        )
        addMessage(message)
    }
    
    /// Adds an assistant message to the conversation
    /// - Parameter content: The content of the assistant message
    /// - Parameter inReplyToId: The ID of the message this is a reply to, if any
    func addAssistantMessage(_ content: String, inReplyToId: UUID? = nil) {
        let message = ChatMessage(
            role: .assistant,
            content: content,
            inReplyToId: inReplyToId
        )
        addMessage(message)
    }
} 