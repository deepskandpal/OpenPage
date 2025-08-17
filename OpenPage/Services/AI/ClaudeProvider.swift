import Foundation

class ClaudeProvider: AIProvider {
    let name = "Claude"
    let supportedModels = [
        "claude-3-5-sonnet-20241022",  // Latest Sonnet 3.5
        "claude-3-5-haiku-20241022",   // Latest Haiku 3.5
        "claude-3-opus-20240229",      // Opus for complex tasks
        "claude-3-sonnet-20240229",    // Legacy Sonnet
        "claude-3-haiku-20240307"      // Legacy Haiku
    ]
    let defaultModel = "claude-3-5-sonnet-20241022"
    
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let apiVersion = "2023-06-01"
    
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
        guard let apiKey = APIKeyManager.shared.getAPIKey(for: .claude) else {
            throw AIError.providerNotConfigured(.claude)
        }
        
        let selectedModel = model ?? defaultModel
        guard supportedModels.contains(selectedModel) else {
            throw AIError.modelNotSupported(selectedModel, .claude)
        }
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        // Convert AIMessage to Claude API format
        let claudeMessages = messages.compactMap { message in
            switch message.role {
            case .user, .assistant:
                return [
                    "role": message.role.rawValue,
                    "content": message.content
                ]
            case .system:
                return nil // System messages are handled separately
            }
        }
        
        var requestBody: [String: Any] = [
            "model": selectedModel,
            "max_tokens": maxTokens ?? 4096,
            "messages": claudeMessages,
            "temperature": temperature ?? 0.7,
            "stream": false
        ]
        
        // Add system prompt if provided
        if let systemPrompt = systemPrompt {
            requestBody["system"] = systemPrompt
        }
        
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
                    let result = try decoder.decode(ClaudeResponse.self, from: data)
                    guard let text = result.content.first?.text, !text.isEmpty else {
                        throw AIError.emptyResponse
                    }
                    return text
                } catch {
                    throw AIError.unknown("Failed to decode response: \(error.localizedDescription)")
                }
            case 401:
                throw AIError.invalidAPIKey(.claude)
            case 429:
                throw AIError.rateLimitExceeded
            default:
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorInfo = errorJson["error"] as? [String: Any],
                   let message = errorInfo["message"] as? String {
                    throw AIError.unknown("Claude API: \(message)")
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
        return APIKeyManager.shared.getAPIKey(for: .claude) != nil
    }
}

// MARK: - Claude API Response Models
private struct ClaudeResponse: Codable {
    let content: [ClaudeContent]
    let id: String?
    let model: String?
    let role: String?
    let type: String?
    let usage: ClaudeUsage?
}

private struct ClaudeContent: Codable {
    let text: String
    let type: String
}

private struct ClaudeUsage: Codable {
    let inputTokens: Int?
    let outputTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}