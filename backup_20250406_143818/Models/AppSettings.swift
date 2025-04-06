import Foundation
import SwiftData

@Model
final class AppSettings {
    // Theme settings
    var isDarkMode: Bool
    var accentColor: String
    var fontName: String
    var fontSize: Double
    
    // Editor preferences
    var showLineNumbers: Bool
    var useSpellCheck: Bool
    var autoSaveEnabled: Bool
    var autoSaveInterval: Int  // seconds
    var useHierarchicalEditing: Bool?
    
    // AI preferences
    var aiAssistEnabled: Bool
    var grammarCheckEnabled: Bool
    var styleSuggestionsEnabled: Bool
    var preferredAIProvider: String? // "openai" or "claude"
    var customSystemPrompt: String?
    var showAIAssistantInInspector: Bool
    var useAIStreamingResponses: Bool
    var maxTokensPerResponse: Int
    var aiTemperature: Double = 0.7
    
    // View preferences
    var showWordCount: Bool
    var showCharacterCount: Bool
    var defaultView: String  // "edit", "preview", "split"
    
    // Default init with sensible defaults
    init() {
        self.isDarkMode = true
        self.accentColor = "Blue"
        self.fontName = "SF Pro"
        self.fontSize = 16.0
        
        self.showLineNumbers = true
        self.useSpellCheck = true
        self.autoSaveEnabled = true
        self.autoSaveInterval = 30
        self.useHierarchicalEditing = true
        
        self.aiAssistEnabled = true
        self.grammarCheckEnabled = true
        self.styleSuggestionsEnabled = true
        self.preferredAIProvider = "openai"
        self.customSystemPrompt = "You are a helpful writing assistant. Provide concise, clear feedback and suggestions."
        self.showAIAssistantInInspector = true
        self.useAIStreamingResponses = true
        self.maxTokensPerResponse = 1024
        
        self.showWordCount = true
        self.showCharacterCount = true
        self.defaultView = "edit"
    }
    
    // Custom init
    init(
        isDarkMode: Bool = true,
        accentColor: String = "Blue",
        fontName: String = "SF Pro",
        fontSize: Double = 16.0,
        showLineNumbers: Bool = true,
        useSpellCheck: Bool = true,
        autoSaveEnabled: Bool = true,
        autoSaveInterval: Int = 30,
        useHierarchicalEditing: Bool? = true,
        aiAssistEnabled: Bool = true,
        grammarCheckEnabled: Bool = true,
        styleSuggestionsEnabled: Bool = true,
        preferredAIProvider: String? = "openai",
        customSystemPrompt: String? = "You are a helpful writing assistant. Provide concise, clear feedback and suggestions.",
        showAIAssistantInInspector: Bool = true,
        useAIStreamingResponses: Bool = true,
        maxTokensPerResponse: Int = 1024,
        showWordCount: Bool = true,
        showCharacterCount: Bool = true,
        defaultView: String = "edit"
    ) {
        self.isDarkMode = isDarkMode
        self.accentColor = accentColor
        self.fontName = fontName
        self.fontSize = fontSize
        
        self.showLineNumbers = showLineNumbers
        self.useSpellCheck = useSpellCheck
        self.autoSaveEnabled = autoSaveEnabled
        self.autoSaveInterval = autoSaveInterval
        self.useHierarchicalEditing = useHierarchicalEditing
        
        self.aiAssistEnabled = aiAssistEnabled
        self.grammarCheckEnabled = grammarCheckEnabled
        self.styleSuggestionsEnabled = styleSuggestionsEnabled
        self.preferredAIProvider = preferredAIProvider
        self.customSystemPrompt = customSystemPrompt
        self.showAIAssistantInInspector = showAIAssistantInInspector
        self.useAIStreamingResponses = useAIStreamingResponses
        self.maxTokensPerResponse = maxTokensPerResponse
        
        self.showWordCount = showWordCount
        self.showCharacterCount = showCharacterCount
        self.defaultView = defaultView
    }
} 