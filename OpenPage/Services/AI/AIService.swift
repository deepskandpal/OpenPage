import Foundation
import Combine

/// Main AI service that orchestrates multiple AI providers based on writing tasks
@MainActor
class AIService: ObservableObject {
    static let shared = AIService()
    
    // MARK: - Providers
    private let claudeProvider = ClaudeProvider()
    private let openaiProvider = OpenAIProvider()
    private let geminiProvider = GeminiProvider()
    
    // MARK: - Published Properties
    @Published var availableProviders: [AIProviderType] = []
    @Published var currentProvider: AIProviderType = .claude
    @Published var isProcessing = false
    @Published var lastError: AIError?
    
    // MARK: - Configuration
    @Published var preferredProviderForTask: [WritingTaskType: AIProviderType] = [
        .creative: .claude,
        .technical: .openai,
        .analysis: .claude,
        .brainstorming: .gemini,
        .editing: .claude,
        .research: .gemini
    ]
    
    private init() {
        updateAvailableProviders()
    }
    
    // MARK: - Provider Management
    
    private func getProvider(for type: AIProviderType) -> AIProvider {
        switch type {
        case .claude:
            return claudeProvider
        case .openai:
            return openaiProvider
        case .gemini:
            return geminiProvider
        }
    }
    
    func updateAvailableProviders() {
        availableProviders = AIProviderType.allCases.filter { type in
            getProvider(for: type).isConfigured()
        }
        
        // Update current provider if it's not available
        if !availableProviders.contains(currentProvider) {
            currentProvider = availableProviders.first ?? .claude
        }
    }
    
    // MARK: - Smart Provider Selection
    
    /// Selects the best provider for a given writing task
    func selectOptimalProvider(for taskType: WritingTaskType) -> AIProviderType {
        let preferred = preferredProviderForTask[taskType] ?? taskType.recommendedProvider
        
        // Use preferred provider if available, otherwise fall back to any available provider
        if availableProviders.contains(preferred) {
            return preferred
        } else {
            return availableProviders.first ?? .claude
        }
    }
    
    // MARK: - Messaging Interface
    
    /// Send a single message with automatic provider selection based on task type
    func sendMessage(
        _ message: String,
        taskType: WritingTaskType,
        systemPrompt: String? = nil,
        provider: AIProviderType? = nil,
        model: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) async throws -> String {
        let selectedProvider = provider ?? selectOptimalProvider(for: taskType)
        let effectiveSystemPrompt = systemPrompt ?? taskType.systemPrompt
        
        return try await sendMessage(
            message,
            provider: selectedProvider,
            systemPrompt: effectiveSystemPrompt,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens
        )
    }
    
    /// Send a message to a specific provider
    func sendMessage(
        _ message: String,
        provider: AIProviderType,
        systemPrompt: String? = nil,
        model: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) async throws -> String {
        isProcessing = true
        lastError = nil
        
        defer {
            isProcessing = false
        }
        
        do {
            let aiProvider = getProvider(for: provider)
            guard aiProvider.isConfigured() else {
                throw AIError.providerNotConfigured(provider)
            }
            
            let response = try await aiProvider.sendMessage(
                message,
                systemPrompt: systemPrompt,
                model: model,
                temperature: temperature,
                maxTokens: maxTokens
            )
            
            return response
        } catch let error as AIError {
            lastError = error
            throw error
        } catch {
            let aiError = AIError.networkError(error)
            lastError = aiError
            throw aiError
        }
    }
    
    /// Send a conversation to a specific provider
    func sendConversation(
        _ messages: [AIMessage],
        provider: AIProviderType,
        systemPrompt: String? = nil,
        model: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) async throws -> String {
        isProcessing = true
        lastError = nil
        
        defer {
            isProcessing = false
        }
        
        do {
            let aiProvider = getProvider(for: provider)
            guard aiProvider.isConfigured() else {
                throw AIError.providerNotConfigured(provider)
            }
            
            let response = try await aiProvider.sendConversation(
                messages,
                systemPrompt: systemPrompt,
                model: model,
                temperature: temperature,
                maxTokens: maxTokens
            )
            
            return response
        } catch let error as AIError {
            lastError = error
            throw error
        } catch {
            let aiError = AIError.networkError(error)
            lastError = aiError
            throw aiError
        }
    }
    
    // MARK: - Writing-Specific Methods
    
    /// Get writing suggestions based on content and task type
    func getWritingSuggestions(
        for content: String,
        taskType: WritingTaskType,
        specificRequest: String? = nil
    ) async throws -> String {
        let prompt = buildWritingSuggestionPrompt(content: content, taskType: taskType, specificRequest: specificRequest)
        
        return try await sendMessage(
            prompt,
            taskType: taskType,
            temperature: 0.7
        )
    }
    
    /// Brainstorm ideas for a writing project
    func brainstormIdeas(
        for topic: String,
        projectType: String,
        context: String? = nil
    ) async throws -> String {
        let prompt = buildBrainstormingPrompt(topic: topic, projectType: projectType, context: context)
        
        return try await sendMessage(
            prompt,
            taskType: .brainstorming,
            temperature: 0.9
        )
    }
    
    /// Edit and improve existing content
    func editContent(
        _ content: String,
        instructions: String? = nil,
        focusArea: String? = nil
    ) async throws -> String {
        let prompt = buildEditingPrompt(content: content, instructions: instructions, focusArea: focusArea)
        
        return try await sendMessage(
            prompt,
            taskType: .editing,
            temperature: 0.3
        )
    }
    
    /// Research a topic and provide structured information
    func researchTopic(
        _ topic: String,
        depth: String = "comprehensive",
        focusAreas: [String] = []
    ) async throws -> String {
        let prompt = buildResearchPrompt(topic: topic, depth: depth, focusAreas: focusAreas)
        
        return try await sendMessage(
            prompt,
            taskType: .research,
            temperature: 0.2
        )
    }
    
    // MARK: - Provider Information
    
    func getSupportedModels(for provider: AIProviderType) -> [String] {
        return getProvider(for: provider).supportedModels
    }
    
    func getDefaultModel(for provider: AIProviderType) -> String {
        return getProvider(for: provider).defaultModel
    }
    
    func getProviderName(for provider: AIProviderType) -> String {
        return getProvider(for: provider).name
    }
}

// MARK: - Prompt Building Helpers
private extension AIService {
    func buildWritingSuggestionPrompt(content: String, taskType: WritingTaskType, specificRequest: String?) -> String {
        var prompt = "Please analyze the following content and provide helpful writing suggestions:\n\n"
        prompt += "Content:\n\(content)\n\n"
        
        if let request = specificRequest {
            prompt += "Specific request: \(request)\n\n"
        }
        
        prompt += "Please provide suggestions that are:\n"
        prompt += "- Specific and actionable\n"
        prompt += "- Appropriate for \(taskType.displayName.lowercased())\n"
        prompt += "- Focused on improving clarity, engagement, and effectiveness\n"
        
        return prompt
    }
    
    func buildBrainstormingPrompt(topic: String, projectType: String, context: String?) -> String {
        var prompt = "Help me brainstorm ideas for a \(projectType) about: \(topic)\n\n"
        
        if let context = context {
            prompt += "Additional context: \(context)\n\n"
        }
        
        prompt += "Please provide:\n"
        prompt += "- Multiple creative angles or approaches\n"
        prompt += "- Key themes or concepts to explore\n"
        prompt += "- Potential structure or organization ideas\n"
        prompt += "- Unique perspectives or hooks\n"
        prompt += "- Research areas that might be helpful\n"
        
        return prompt
    }
    
    func buildEditingPrompt(content: String, instructions: String?, focusArea: String?) -> String {
        var prompt = "Please edit and improve the following content:\n\n"
        prompt += "Content:\n\(content)\n\n"
        
        if let instructions = instructions {
            prompt += "Specific instructions: \(instructions)\n\n"
        }
        
        if let focus = focusArea {
            prompt += "Focus area: \(focus)\n\n"
        }
        
        prompt += "Please improve:\n"
        prompt += "- Grammar and syntax\n"
        prompt += "- Clarity and flow\n"
        prompt += "- Word choice and style\n"
        prompt += "- Structure and organization\n"
        prompt += "- Overall readability and engagement\n"
        
        return prompt
    }
    
    func buildResearchPrompt(topic: String, depth: String, focusAreas: [String]) -> String {
        var prompt = "Please research and provide comprehensive information about: \(topic)\n\n"
        prompt += "Research depth: \(depth)\n\n"
        
        if !focusAreas.isEmpty {
            prompt += "Focus areas: \(focusAreas.joined(separator: ", "))\n\n"
        }
        
        prompt += "Please provide:\n"
        prompt += "- Key concepts and definitions\n"
        prompt += "- Important facts and statistics\n"
        prompt += "- Different perspectives or viewpoints\n"
        prompt += "- Recent developments or trends\n"
        prompt += "- Relevant examples or case studies\n"
        prompt += "- Suggested sources for further reading\n"
        
        return prompt
    }
}