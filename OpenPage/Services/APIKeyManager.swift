import Foundation
import Security

/// Manages the secure storage and retrieval of API keys for AI providers
class APIKeyManager {
    /// Shared instance for singleton access
    static let shared = APIKeyManager()
    
    /// Custom error type for API validation
    enum APIValidationError: Error, LocalizedError {
        case invalidFormat
        case validationFailed(message: String)
        case networkError(message: String)
        
        var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "Invalid API key format"
            case .validationFailed(let message):
                return "Validation failed: \(message)"
            case .networkError(let message):
                return "Network error: \(message)"
            }
        }
    }
    
    /// Supported API providers
    enum APIProvider: String, CaseIterable, Identifiable {
        case claude = "claude"
        case openai = "openai"
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .claude:
                return "Claude"
            case .openai:
                return "OpenAI"
            }
        }
        
        var keyPlaceholder: String {
            switch self {
            case .claude:
                return "sk-ant-"
            case .openai:
                return "sk-"
            }
        }
        
        var keyFormatDescription: String {
            switch self {
            case .claude:
                return "Claude API keys start with 'sk-ant-'"
            case .openai:
                return "OpenAI API keys start with 'sk-'"
            }
        }
    }
    
    // Private initializer for singleton pattern
    private init() {}
    
    // MARK: - Keychain Operations
    
    /// Saves an API key for the specified provider
    /// - Parameters:
    ///   - key: The API key to save
    ///   - provider: The API provider
    /// - Throws: Error if saving fails
    func saveAPIKey(_ key: String, for provider: APIProvider) throws {
        guard isValidKeyFormat(key, for: provider) else {
            throw KeychainError.invalidKeyFormat
        }
        
        // First try to delete any existing key
        try? removeAPIKey(for: provider)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: provider.rawValue,
            kSecValueData as String: key.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecAttrService as String: "com.vibe.writing.apikeys"
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // If item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: provider.rawValue,
                kSecAttrService as String: "com.vibe.writing.apikeys"
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: key.data(using: .utf8)!
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.saveFailed(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
    }
    
    /// Retrieves the API key for the specified provider
    /// - Parameter provider: The API provider
    /// - Returns: The API key if found, nil otherwise
    func getAPIKey(for provider: APIProvider) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: provider.rawValue,
            kSecAttrService as String: "com.vibe.writing.apikeys",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8),
              !key.isEmpty else {
            return nil
        }
        
        return key
    }
    
    /// Removes the API key for the specified provider
    /// - Parameter provider: The API provider
    /// - Throws: Error if removal fails
    func removeAPIKey(for provider: APIProvider) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: provider.rawValue,
            kSecAttrService as String: "com.vibe.writing.apikeys"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    /// Checks if an API key exists for the specified provider
    /// - Parameter provider: The API provider
    /// - Returns: True if an API key exists, false otherwise
    func hasAPIKey(for provider: APIProvider) -> Bool {
        return getAPIKey(for: provider) != nil
    }
    
    /// Validates an API key format for the specified provider
    /// - Parameters:
    ///   - key: The API key to validate
    ///   - provider: The API provider
    /// - Returns: True if the key format is valid, false otherwise
    func isValidKeyFormat(_ key: String, for provider: APIProvider) -> Bool {
        guard !key.isEmpty else { return false }
        
        switch provider {
        case .claude:
            return key.hasPrefix("sk-ant-")
        case .openai:
            return key.hasPrefix("sk-")
        }
    }
    
    /// Attempts to validate the API key with the provider
    /// - Parameters:
    ///   - key: The API key to validate
    ///   - provider: The API provider
    /// - Returns: A result indicating success or failure
    func validateAPIKey(_ key: String, for provider: APIProvider) async -> Result<Bool, APIValidationError> {
        // In a real implementation, we would make an API call to validate the key
        // For now, we'll just do a basic format check
        
        guard isValidKeyFormat(key, for: provider) else {
            return .failure(.invalidFormat)
        }
        
        // TODO: Add real API validation in a production app
        return .success(true)
    }
}

/// Custom error type for Keychain operations
enum KeychainError: LocalizedError {
    case invalidKeyFormat
    case saveFailed(OSStatus)
    case deleteFailed(OSStatus)
    case verificationFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidKeyFormat:
            return "Invalid API key format"
        case .saveFailed(let status):
            return "Failed to save API key: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete API key: \(status)"
        case .verificationFailed:
            return "API key verification failed after save"
        }
    }
} 