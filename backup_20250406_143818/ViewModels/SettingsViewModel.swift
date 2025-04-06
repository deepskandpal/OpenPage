import Foundation
import SwiftUI
import SwiftData
import Combine

class SettingsViewModel: ObservableObject {
    private var appSettings: AppSettings
    private var cancellables = Set<AnyCancellable>()
    
    // Theme settings
    @Published var isDarkMode: Bool
    @Published var accentColor: String
    @Published var fontName: String
    @Published var fontSize: Double
    
    // Editor preferences
    @Published var showLineNumbers: Bool
    @Published var useSpellCheck: Bool
    @Published var autoSaveEnabled: Bool
    @Published var autoSaveInterval: Int
    @Published var useHierarchicalEditing: Bool
    
    // AI preferences
    @Published var aiAssistEnabled: Bool
    @Published var grammarCheckEnabled: Bool
    @Published var styleSuggestionsEnabled: Bool
    @Published var preferredAIProvider: String?
    @Published var customSystemPrompt: String?
    @Published var showAIAssistantInInspector: Bool
    @Published var useAIStreamingResponses: Bool
    @Published var maxTokensPerResponse: Int
    @Published var aiTemperature: Double
    
    // View preferences
    @Published var showWordCount: Bool
    @Published var showCharacterCount: Bool
    @Published var defaultView: String
    
    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        
        // Initialize published properties
        self.isDarkMode = appSettings.isDarkMode
        self.accentColor = appSettings.accentColor
        self.fontName = appSettings.fontName
        self.fontSize = appSettings.fontSize
        
        self.showLineNumbers = appSettings.showLineNumbers
        self.useSpellCheck = appSettings.useSpellCheck
        self.autoSaveEnabled = appSettings.autoSaveEnabled
        self.autoSaveInterval = appSettings.autoSaveInterval
        self.useHierarchicalEditing = appSettings.useHierarchicalEditing ?? true
        
        self.aiAssistEnabled = appSettings.aiAssistEnabled
        self.grammarCheckEnabled = appSettings.grammarCheckEnabled
        self.styleSuggestionsEnabled = appSettings.styleSuggestionsEnabled
        self.preferredAIProvider = appSettings.preferredAIProvider
        self.customSystemPrompt = appSettings.customSystemPrompt
        self.showAIAssistantInInspector = appSettings.showAIAssistantInInspector
        self.useAIStreamingResponses = appSettings.useAIStreamingResponses
        self.maxTokensPerResponse = appSettings.maxTokensPerResponse
        self.aiTemperature = appSettings.aiTemperature
        
        self.showWordCount = appSettings.showWordCount
        self.showCharacterCount = appSettings.showCharacterCount
        self.defaultView = appSettings.defaultView
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Set up binding for isDarkMode
        $isDarkMode
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.appSettings.isDarkMode = newValue
                self.updateAppearance()
            }
            .store(in: &cancellables)
        
        // Set up binding for accentColor
        $accentColor
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.appSettings.accentColor = newValue
            }
            .store(in: &cancellables)
            
        // We'd set up similar bindings for other properties...
    }
    
    func saveSettings() {
        // Update the app settings model with all current values
        appSettings.isDarkMode = isDarkMode
        appSettings.accentColor = accentColor
        appSettings.fontName = fontName
        appSettings.fontSize = fontSize
        
        appSettings.showLineNumbers = showLineNumbers
        appSettings.useSpellCheck = useSpellCheck
        appSettings.autoSaveEnabled = autoSaveEnabled
        appSettings.autoSaveInterval = autoSaveInterval
        appSettings.useHierarchicalEditing = useHierarchicalEditing
        
        appSettings.aiAssistEnabled = aiAssistEnabled
        appSettings.grammarCheckEnabled = grammarCheckEnabled
        appSettings.styleSuggestionsEnabled = styleSuggestionsEnabled
        appSettings.preferredAIProvider = preferredAIProvider
        appSettings.customSystemPrompt = customSystemPrompt
        appSettings.showAIAssistantInInspector = showAIAssistantInInspector
        appSettings.useAIStreamingResponses = useAIStreamingResponses
        appSettings.maxTokensPerResponse = maxTokensPerResponse
        appSettings.aiTemperature = aiTemperature
        
        appSettings.showWordCount = showWordCount
        appSettings.showCharacterCount = showCharacterCount
        appSettings.defaultView = defaultView
    }
    
    func resetToDefaults() {
        let defaults = AppSettings()
        
        // Update published properties
        isDarkMode = defaults.isDarkMode
        accentColor = defaults.accentColor
        fontName = defaults.fontName
        fontSize = defaults.fontSize
        
        showLineNumbers = defaults.showLineNumbers
        useSpellCheck = defaults.useSpellCheck
        autoSaveEnabled = defaults.autoSaveEnabled
        autoSaveInterval = defaults.autoSaveInterval
        useHierarchicalEditing = defaults.useHierarchicalEditing ?? true
        
        aiAssistEnabled = defaults.aiAssistEnabled
        grammarCheckEnabled = defaults.grammarCheckEnabled
        styleSuggestionsEnabled = defaults.styleSuggestionsEnabled
        preferredAIProvider = defaults.preferredAIProvider
        customSystemPrompt = defaults.customSystemPrompt
        showAIAssistantInInspector = defaults.showAIAssistantInInspector
        useAIStreamingResponses = defaults.useAIStreamingResponses
        maxTokensPerResponse = defaults.maxTokensPerResponse
        aiTemperature = defaults.aiTemperature
        
        showWordCount = defaults.showWordCount
        showCharacterCount = defaults.showCharacterCount
        defaultView = defaults.defaultView
        
        // Save changes
        saveSettings()
    }
    
    func updateSettings(_ newSettings: AppSettings) {
        self.appSettings = newSettings
        
        // Update published properties
        isDarkMode = newSettings.isDarkMode
        accentColor = newSettings.accentColor
        fontName = newSettings.fontName
        fontSize = newSettings.fontSize
        
        showLineNumbers = newSettings.showLineNumbers
        useSpellCheck = newSettings.useSpellCheck
        autoSaveEnabled = newSettings.autoSaveEnabled
        autoSaveInterval = newSettings.autoSaveInterval
        useHierarchicalEditing = newSettings.useHierarchicalEditing ?? true
        
        aiAssistEnabled = newSettings.aiAssistEnabled
        grammarCheckEnabled = newSettings.grammarCheckEnabled
        styleSuggestionsEnabled = newSettings.styleSuggestionsEnabled
        preferredAIProvider = newSettings.preferredAIProvider
        customSystemPrompt = newSettings.customSystemPrompt
        showAIAssistantInInspector = newSettings.showAIAssistantInInspector
        useAIStreamingResponses = newSettings.useAIStreamingResponses
        maxTokensPerResponse = newSettings.maxTokensPerResponse
        aiTemperature = newSettings.aiTemperature
        
        showWordCount = newSettings.showWordCount
        showCharacterCount = newSettings.showCharacterCount
        defaultView = newSettings.defaultView
    }
    
    private func updateAppearance() {
        // This would be used to update the app's appearance based on settings
        // For example, switching between light and dark mode
    }
    
    // Available font options
    var availableFonts: [String] {
        return ["SF Pro", "SF Mono", "New York", "Helvetica Neue", "Times New Roman"]
    }
    
    // Available accent color options
    var availableColors: [String] {
        return ["Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Teal"]
    }
    
    // Available default view options
    var viewOptions: [String] {
        return ["edit", "preview", "split"]
    }
} 