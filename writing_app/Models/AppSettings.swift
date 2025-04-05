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
    var selectedAIProvider: String? // "claude" or "openai"
    
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
        self.selectedAIProvider = nil
        
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
        selectedAIProvider: String? = nil,
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
        self.selectedAIProvider = selectedAIProvider
        
        self.showWordCount = showWordCount
        self.showCharacterCount = showCharacterCount
        self.defaultView = defaultView
    }
} 