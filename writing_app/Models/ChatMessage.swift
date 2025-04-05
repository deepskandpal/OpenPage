import Foundation
import SwiftData

/// The role of a message sender
enum MessageRole: String, Codable {
    case system
    case user
    case assistant
    
    var isAI: Bool {
        self == .assistant
    }
}

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
    
    /// The document title at the time the message was created, for reference
    var documentTitle: String?
    
    /// The title of the conversation this message belongs to
    var conversationTitle: String?
    
    /// If this is a response to another message, the ID of that message
    var inReplyToId: UUID?
    
    /// An identifier for grouping messages in the same conversation
    var conversationId: String?
    
    /// The AI model used for generating this message (if AI-generated)
    var aiModel: String?
    
    /// Metadata about the AI generation process
    var aiMetadata: [String: String]?
    
    /// Constructor
    init(role: MessageRole, content: String, documentTitle: String? = nil, inReplyToId: UUID? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.documentTitle = documentTitle
        self.inReplyToId = inReplyToId
        
        // Generate a conversation ID using timestamp for new conversations
        if role == .user {
            self.conversationId = UUID().uuidString
        }
    }
    
    /// Set AI-specific metadata
    func setAIMetadata(model: String, metadata: [String: String]? = nil) {
        self.aiModel = model
        self.aiMetadata = metadata
    }
} 