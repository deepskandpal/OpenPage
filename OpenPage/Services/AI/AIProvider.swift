import Foundation

// MARK: - AI Provider Protocol
protocol AIProvider {
    var name: String { get }
    var supportedModels: [String] { get }
    var defaultModel: String { get }
    
    func sendMessage(
        _ message: String,
        systemPrompt: String?,
        model: String?,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> String
    
    func sendConversation(
        _ messages: [AIMessage],
        systemPrompt: String?,
        model: String?,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> String
    
    func isConfigured() -> Bool
}

// MARK: - AI Message Model
struct AIMessage: Codable, Identifiable {
    let id: UUID
    let role: AIRole
    let content: String
    let timestamp: Date
    
    init(role: AIRole, content: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

enum AIRole: String, Codable, CaseIterable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .user: return "You"
        case .assistant: return "AI"
        }
    }
}

// MARK: - AI Provider Types
enum AIProviderType: String, CaseIterable, Codable {
    case claude = "claude"
    case openai = "openai"
    case gemini = "gemini"
    
    var displayName: String {
        switch self {
        case .claude: return "Claude (Anthropic)"
        case .openai: return "GPT (OpenAI)"
        case .gemini: return "Gemini (Google)"
        }
    }
    
    var description: String {
        switch self {
        case .claude: return "Best for creative writing, analysis, and thoughtful responses"
        case .openai: return "Versatile for coding, writing, and general tasks"
        case .gemini: return "Excellent for research, multimodal tasks, and reasoning"
        }
    }
}

// MARK: - Writing Task Types
enum WritingTaskType: String, CaseIterable, Codable {
    case creative = "creative"
    case technical = "technical"
    case analysis = "analysis"
    case brainstorming = "brainstorming"
    case editing = "editing"
    case research = "research"
    
    var displayName: String {
        switch self {
        case .creative: return "Creative Writing"
        case .technical: return "Technical Writing"
        case .analysis: return "Analysis & Review"
        case .brainstorming: return "Brainstorming & Ideas"
        case .editing: return "Editing & Proofreading"
        case .research: return "Research & Information"
        }
    }
    
    var recommendedProvider: AIProviderType {
        switch self {
        case .creative, .analysis, .editing:
            return .claude
        case .technical:
            return .openai
        case .brainstorming, .research:
            return .gemini
        }
    }
    
    var systemPrompt: String {
        switch self {
        case .creative:
            return "You are a creative writing assistant. Help with storytelling, character development, plot creation, and creative expression. Be imaginative, supportive, and offer creative suggestions."
        case .technical:
            return "You are a technical writing assistant. Help with clear, precise, and accurate technical documentation, code explanations, and instructional content. Focus on clarity and accuracy."
        case .analysis:
            return "You are an analytical writing assistant. Help with critical analysis, reviews, critiques, and detailed examination of texts, ideas, or concepts. Be thorough and insightful."
        case .brainstorming:
            return "You are a brainstorming assistant. Help generate ideas, explore possibilities, and think creatively about problems and opportunities. Be enthusiastic and suggest diverse approaches."
        case .editing:
            return "You are an editing and proofreading assistant. Help improve grammar, style, clarity, and flow. Suggest improvements while maintaining the author's voice and intent."
        case .research:
            return "You are a research assistant. Help gather information, verify facts, suggest sources, and organize research findings. Be thorough and cite reliable sources when possible."
        }
    }
}

// MARK: - AI Errors
enum AIError: LocalizedError {
    case providerNotConfigured(AIProviderType)
    case invalidAPIKey(AIProviderType)
    case networkError(Error)
    case invalidResponse
    case rateLimitExceeded
    case modelNotSupported(String, AIProviderType)
    case unknown(String)
    case emptyResponse
    
    var errorDescription: String? {
        switch self {
        case .providerNotConfigured(let provider):
            return "\(provider.displayName) is not configured. Please add your API key in settings."
        case .invalidAPIKey(let provider):
            return "Invalid API key for \(provider.displayName). Please check your settings."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from AI provider"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .modelNotSupported(let model, let provider):
            return "Model '\(model)' is not supported by \(provider.displayName)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        case .emptyResponse:
            return "Received empty response from AI provider"
        }
    }
}