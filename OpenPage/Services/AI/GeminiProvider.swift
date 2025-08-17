import Foundation

class GeminiProvider: AIProvider {
    let name = "Gemini"
    let supportedModels = [
        "gemini-2.0-flash-exp",       // Latest Gemini 2.0 Flash
        "gemini-1.5-pro",            // Gemini 1.5 Pro
        "gemini-1.5-flash",          // Gemini 1.5 Flash
        "gemini-pro"                 // Legacy Gemini Pro
    ]
    let defaultModel = "gemini-2.0-flash-exp"
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
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
        guard let apiKey = APIKeyManager.shared.getAPIKey(for: .gemini) else {
            throw AIError.providerNotConfigured(.gemini)
        }
        
        let selectedModel = model ?? defaultModel
        guard supportedModels.contains(selectedModel) else {
            throw AIError.modelNotSupported(selectedModel, .gemini)
        }
        
        let url = "\(baseURL)/\(selectedModel):generateContent?key=\(apiKey)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert AIMessage to Gemini API format
        var geminiContents: [[String: Any]] = []
        
        // Handle system instruction separately for Gemini
        var systemInstruction: [String: Any]? = nil
        if let systemPrompt = systemPrompt {
            systemInstruction = [
                "parts": [["text": systemPrompt]]
            ]
        }
        
        // Convert conversation messages
        for message in messages {
            let role = message.role == .assistant ? "model" : "user"
            geminiContents.append([
                "role": role,
                "parts": [["text": message.content]]
            ])
        }
        
        var requestBody: [String: Any] = [
            "contents": geminiContents,
            "generationConfig": [
                "temperature": temperature ?? 0.7,
                "maxOutputTokens": maxTokens ?? 4096,
                "candidateCount": 1
            ]
        ]
        
        // Add system instruction if provided
        if let systemInstruction = systemInstruction {
            requestBody["systemInstruction"] = systemInstruction
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
                    let result = try decoder.decode(GeminiResponse.self, from: data)
                    
                    guard let candidate = result.candidates?.first,
                          let part = candidate.content?.parts?.first,
                          let text = part.text,
                          !text.isEmpty else {
                        throw AIError.emptyResponse
                    }
                    return text
                } catch {
                    throw AIError.unknown("Failed to decode response: \(error.localizedDescription)")
                }
            case 401, 403:
                throw AIError.invalidAPIKey(.gemini)
            case 429:
                throw AIError.rateLimitExceeded
            default:
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorInfo = errorJson["error"] as? [String: Any],
                   let message = errorInfo["message"] as? String {
                    throw AIError.unknown("Gemini API: \(message)")
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
        return APIKeyManager.shared.getAPIKey(for: .gemini) != nil
    }
}

// MARK: - Gemini API Response Models
private struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
    let usageMetadata: GeminiUsage?
}

private struct GeminiCandidate: Codable {
    let content: GeminiContent?
    let finishReason: String?
    let index: Int?
    let safetyRatings: [GeminiSafetyRating]?
}

private struct GeminiContent: Codable {
    let parts: [GeminiPart]?
    let role: String?
}

private struct GeminiPart: Codable {
    let text: String?
}

private struct GeminiSafetyRating: Codable {
    let category: String?
    let probability: String?
}

private struct GeminiUsage: Codable {
    let promptTokenCount: Int?
    let candidatesTokenCount: Int?
    let totalTokenCount: Int?
}