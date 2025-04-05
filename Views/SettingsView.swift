import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var appSettings: [AppSettings]
    
    // Create temp settings for binding
    @State private var isDarkMode = true
    @State private var accentColor = "Blue"
    @State private var fontName = "SF Pro"
    @State private var fontSize = 16.0
    @State private var showLineNumbers = true
    @State private var useSpellCheck = true
    @State private var autoSaveEnabled = true
    @State private var autoSaveInterval = 30
    @State private var useHierarchicalEditing = true
    @State private var aiAssistEnabled = true
    @State private var grammarCheckEnabled = true
    @State private var styleSuggestionsEnabled = true
    @State private var preferredAIProvider = "claude"
    @State private var customSystemPrompt = "You are a helpful writing assistant"
    @State private var showAIAssistantInInspector = true
    @State private var useAIStreamingResponses = true
    @State private var maxTokensPerResponse = 1024
    @State private var aiTemperature = 0.7
    @State private var showWordCount = true
    @State private var showCharacterCount = true
    @State private var defaultView = "edit"
    
    // Available options
    private let availableFonts = ["SF Pro", "SF Mono", "New York", "Helvetica Neue", "Times New Roman"]
    private let availableColors = ["Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Teal"]
    private let viewOptions = ["edit", "preview", "split"]
    
    var body: some View {
        NavigationView {
            List {
                themeSection
                editorSection
                aiSection
                viewSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSettings()
            }
        }
    }
    
    private func loadSettings() {
        guard let settings = appSettings.first else { return }
        
        isDarkMode = settings.isDarkMode
        accentColor = settings.accentColor
        fontName = settings.fontName
        fontSize = settings.fontSize
        showLineNumbers = settings.showLineNumbers
        useSpellCheck = settings.useSpellCheck
        autoSaveEnabled = settings.autoSaveEnabled
        autoSaveInterval = settings.autoSaveInterval
        useHierarchicalEditing = settings.useHierarchicalEditing ?? true
        aiAssistEnabled = settings.aiAssistEnabled
        grammarCheckEnabled = settings.grammarCheckEnabled
        styleSuggestionsEnabled = settings.styleSuggestionsEnabled
        preferredAIProvider = settings.preferredAIProvider ?? "claude"
        customSystemPrompt = settings.customSystemPrompt ?? ""
        showAIAssistantInInspector = settings.showAIAssistantInInspector
        useAIStreamingResponses = settings.useAIStreamingResponses
        maxTokensPerResponse = settings.maxTokensPerResponse
        aiTemperature = settings.aiTemperature
        showWordCount = settings.showWordCount
        showCharacterCount = settings.showCharacterCount
        defaultView = settings.defaultView
    }
    
    private func saveSettings() {
        let settings = appSettings.first ?? {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            return newSettings
        }()
        
        settings.isDarkMode = isDarkMode
        settings.accentColor = accentColor
        settings.fontName = fontName
        settings.fontSize = fontSize
        settings.showLineNumbers = showLineNumbers
        settings.useSpellCheck = useSpellCheck
        settings.autoSaveEnabled = autoSaveEnabled
        settings.autoSaveInterval = autoSaveInterval
        settings.useHierarchicalEditing = useHierarchicalEditing
        settings.aiAssistEnabled = aiAssistEnabled
        settings.grammarCheckEnabled = grammarCheckEnabled
        settings.styleSuggestionsEnabled = styleSuggestionsEnabled
        settings.preferredAIProvider = preferredAIProvider
        settings.customSystemPrompt = customSystemPrompt
        settings.showAIAssistantInInspector = showAIAssistantInInspector
        settings.useAIStreamingResponses = useAIStreamingResponses
        settings.maxTokensPerResponse = maxTokensPerResponse
        settings.aiTemperature = aiTemperature
        settings.showWordCount = showWordCount
        settings.showCharacterCount = showCharacterCount
        settings.defaultView = defaultView
        
        NotificationCenter.default.post(
            name: Notification.Name("DismissSettings"),
            object: nil
        )
    }
    
    private var themeSection: some View {
        Section {
            Toggle("Dark Mode", isOn: $isDarkMode)
            Picker("Accent Color", selection: $accentColor) {
                ForEach(availableColors, id: \.self) { color in
                    Text(color).tag(color)
                }
            }
            Picker("Font", selection: $fontName) {
                ForEach(availableFonts, id: \.self) { font in
                    Text(font).tag(font)
                }
            }
            HStack {
                Text("Font Size: \(Int(fontSize))")
                Slider(value: $fontSize, in: 10...24, step: 1)
            }
        } header: {
            Text("Theme")
        }
    }
    
    private var editorSection: some View {
        Section {
            Toggle("Show Line Numbers", isOn: $showLineNumbers)
            Toggle("Use Spell Check", isOn: $useSpellCheck)
            Toggle("Auto Save", isOn: $autoSaveEnabled)
            if autoSaveEnabled {
                HStack {
                    Text("Auto Save Interval: \(autoSaveInterval)s")
                    Slider(value: .init(
                        get: { Double(autoSaveInterval) },
                        set: { autoSaveInterval = Int($0) }
                    ), in: 10...120, step: 5)
                }
            }
            Toggle("Hierarchical Editing", isOn: $useHierarchicalEditing)
        } header: {
            Text("Editor")
        }
    }
    
    private var aiSection: some View {
        Section {
            Toggle("Enable AI Assistant", isOn: $aiAssistEnabled)
            if aiAssistEnabled {
                Toggle("Grammar Checking", isOn: $grammarCheckEnabled)
                Toggle("Style Suggestions", isOn: $styleSuggestionsEnabled)
                
                Picker("Preferred Model", selection: $preferredAIProvider) {
                    Text("Claude").tag("claude")
                }
                .pickerStyle(.menu)
                
                Toggle("Use Streaming", isOn: $useAIStreamingResponses)
                
                VStack(alignment: .leading) {
                    Text("Temperature: \(String(format: "%.1f", aiTemperature))")
                    Slider(value: $aiTemperature, in: 0...1, step: 0.1)
                }
                
                Picker("Max Tokens", selection: $maxTokensPerResponse) {
                    Text("512").tag(512)
                    Text("1024").tag(1024)
                    Text("2048").tag(2048)
                    Text("4096").tag(4096)
                }
                
                VStack(alignment: .leading) {
                    Text("System Prompt")
                    TextEditor(text: $customSystemPrompt)
                        .frame(height: 100)
                        .font(.caption)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.secondary.opacity(0.2))
                        )
                }
                
                Button("Configure API Key") {
                    NotificationCenter.default.post(
                        name: Notification.Name("ShowAISettings"),
                        object: nil
                    )
                }
            }
        } header: {
            Text("AI Assistant")
        }
    }
    
    private var viewSection: some View {
        Section {
            Toggle("Show Word Count", isOn: $showWordCount)
            Toggle("Show Character Count", isOn: $showCharacterCount)
            Picker("Default View", selection: $defaultView) {
                Text("Editor").tag("edit")
                Text("Preview").tag("preview")
                Text("Split View").tag("split")
            }
        } header: {
            Text("View")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self)
}