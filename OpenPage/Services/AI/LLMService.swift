import Foundation

enum LLMError: LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case rateLimitExceeded
    case unknown(String)
    case decodingError(Error)
    case emptyResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your Claude API key in settings."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Claude API"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .unknown(let message):
            return "Unknown error: \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .emptyResponse:
            return "Received empty response from Claude"
        }
    }
}

class LLMService {
    static let shared = LLMService()
    private let baseURL = "https://api.anthropic.com/v1/messages"
    
    private init() {}
    
    func sendMessage(_ message: String, systemPrompt: String? = nil) async throws -> String {
        guard let apiKey = APIKeyManager.shared.getAPIKey(for: .claude) else {
            throw LLMError.invalidAPIKey
        }
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("anthropic-version=2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")
        
        var messages: [[String: String]] = []
        
        if let systemPrompt = systemPrompt {
            messages.append([
                "role": "system",
                "content": systemPrompt
            ])
        }
        
        messages.append([
            "role": "user",
            "content": message
        ])
        
        let requestBody: [String: Any] = [
            "model": "claude-3-sonnet-20240229",
            "max_tokens": 4096,
            "messages": messages,
            "temperature": 0.7,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(ClaudeResponse.self, from: data)
                    guard let text = result.content.first?.text, !text.isEmpty else {
                        throw LLMError.emptyResponse
                    }
                    return text
                } catch {
                    throw LLMError.decodingError(error)
                }
            case 401:
                throw LLMError.invalidAPIKey
            case 429:
                throw LLMError.rateLimitExceeded
            default:
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["error"] as? [String: Any],
                   let message = errorMessage["message"] as? String {
                    throw LLMError.unknown(message)
                } else {
                    throw LLMError.unknown("HTTP \(httpResponse.statusCode)")
                }
            }
        } catch let error as LLMError {
            throw error
        } catch {
            throw LLMError.networkError(error)
        }
    }
}

// Response models for Claude API
struct ClaudeResponse: Codable {
    let content: [ClaudeContent]
}

struct ClaudeContent: Codable {
    let text: String
    let type: String
} 