import Foundation

class OpenAIProvider: AIProvider {
    let name = "OpenAI"
    let supportedModels = [
        "gpt-4o",                    // Latest GPT-4 Omni
        "gpt-4o-mini",              // GPT-4 Mini
        "gpt-4-turbo",              // GPT-4 Turbo
        "gpt-4",                    // Standard GPT-4
        "gpt-3.5-turbo"             // GPT-3.5 Turbo
    ]
    let defaultModel = "gpt-4o"
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func sendMessage(
        _ message: String,
        systemPrompt: String? = nil,
        model: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) async throws -> String {
        let messages = [AIMessage(role: .user, content: message)]
        return try await sendConversation(
            messages,
            systemPrompt: systemPrompt,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens
        )
    }
    
    func sendConversation(
        _ messages: [AIMessage],
        systemPrompt: String? = nil,
        model: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) async throws -> String {
        guard let apiKey = APIKeyManager.shared.getAPIKey(for: .openai) else {
            throw AIError.providerNotConfigured(.openai)
        }
        
        let selectedModel = model ?? defaultModel
        guard supportedModels.contains(selectedModel) else {
            throw AIError.modelNotSupported(selectedModel, .openai)
        }
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Convert AIMessage to OpenAI API format
        var openAIMessages: [[String: String]] = []
        
        // Add system prompt as system message if provided
        if let systemPrompt = systemPrompt {
            openAIMessages.append([
                "role": "system",
                "content": systemPrompt
            ])
        }
        
        // Add conversation messages
        for message in messages {
            openAIMessages.append([
                "role": message.role.rawValue,
                "content": message.content
            ])
        }
        
        let requestBody: [String: Any] = [
            "model": selectedModel,
            "messages": openAIMessages,
            "temperature": temperature ?? 0.7,
            "max_tokens": maxTokens ?? 4096,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(OpenAIResponse.self, from: data)
                    guard let message = result.choices.first?.message.content,
                          !message.isEmpty else {
                        throw AIError.emptyResponse
                    }
                    return message
                } catch {
                    throw AIError.unknown("Failed to decode response: \(error.localizedDescription)")
                }
            case 401:
                throw AIError.invalidAPIKey(.openai)
            case 429:
                throw AIError.rateLimitExceeded
            default:
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorInfo = errorJson["error"] as? [String: Any],
                   let message = errorInfo["message"] as? String {
                    throw AIError.unknown("OpenAI API: \(message)")
                } else {
                    throw AIError.unknown("HTTP \(httpResponse.statusCode)")
                }
            }
        } catch let error as AIError {
            throw error
        } catch {
            throw AIError.networkError(error)
        }
    }
    
    func isConfigured() -> Bool {
        return APIKeyManager.shared.getAPIKey(for: .openai) != nil
    }
}

// MARK: - OpenAI API Response Models
private struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
    let id: String?
    let model: String?
    let usage: OpenAIUsage?
}

private struct OpenAIChoice: Codable {
    let message: OpenAIMessage
    let index: Int?
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message, index
        case finishReason = "finish_reason"
    }
}

private struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

private struct OpenAIUsage: Codable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}