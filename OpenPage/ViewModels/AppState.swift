import Foundation
import SwiftUI
import SwiftData
import Combine

enum WritingFocusMode: String, CaseIterable {
    case normal = "normal"
    case typewriter = "typewriter"
    case zen = "zen"
    case distraction_free = "distraction_free"
    
    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .typewriter: return "Typewriter"
        case .zen: return "Zen Mode"
        case .distraction_free: return "Distraction Free"
        }
    }
    
    var description: String {
        switch self {
        case .normal: return "Standard editing experience"
        case .typewriter: return "Keep current line centered"
        case .zen: return "Minimal, focused writing environment"
        case .distraction_free: return "Hide all panels and distractions"
        }
    }
}

/// Central state management for the application
/// Replaces scattered @State variables and NotificationCenter usage
@MainActor
class AppState: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    // MARK: - Document and Project State
    @Published var selectedDocument: Document?
    @Published var selectedProject: Project?
    
    // MARK: - UI State
    @Published var showInspector: Bool = true
    @Published var showBinder: Bool = true
    
    // MARK: - Sheet and Modal State
    @Published var isShowingSettings: Bool = false
    @Published var showingNewDocumentView: Bool = false
    @Published var isShowingNewProjectSheet: Bool = false
    @Published var isShowingProjectCreation: Bool = false
    @Published var isShowingChatAssistant: Bool = false
    @Published var isShowingAISettings: Bool = false
    @Published var isShowingExportView: Bool = false
    
    // MARK: - AI Assistant State
    @Published var showAIPanel: Bool = true
    @Published var aiConversation: [AIMessage] = []
    @Published var currentWritingTask: WritingTaskType = .creative
    @Published var selectedAIProvider: AIProviderType = .claude
    
    // MARK: - Writing Focus State
    @Published var focusMode: WritingFocusMode = .normal
    @Published var wordCountGoal: Int?
    @Published var dailyWritingStreak: Int = 0
    
    // MARK: - Services
    let documentService: DocumentService
    let aiService = AIService.shared
    let exportService = ExportService.shared
    
    init(modelContext: ModelContext) {
        self.documentService = DocumentService(modelContext: modelContext)
        setupAppStateManagerListeners()
    }
    
    private func setupAppStateManagerListeners() {
        let manager = AppStateManager.shared
        
        manager.$createDocumentRequested
            .filter { $0 }
            .sink { [weak self] _ in
                self?.createNewDocument()
                manager.resetCreateDocument()
            }
            .store(in: &cancellables)
        
        manager.$createProjectRequested
            .filter { $0 }
            .sink { [weak self] _ in
                self?.createNewProject()
                manager.resetCreateProject()
            }
            .store(in: &cancellables)
        
        manager.$createChatRequested
            .filter { $0 }
            .sink { [weak self] _ in
                self?.createNewChat()
                manager.resetCreateChat()
            }
            .store(in: &cancellables)
        
        manager.$toggleChatRequested
            .filter { $0 }
            .sink { [weak self] _ in
                self?.toggleChatAssistant()
                manager.resetToggleChat()
            }
            .store(in: &cancellables)
        
        manager.$showAISettingsRequested
            .filter { $0 }
            .sink { [weak self] _ in
                self?.showAISettings()
                manager.resetShowAISettings()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    func toggleBinder() {
        showBinder.toggle()
    }
    
    func toggleInspector() {
        showInspector.toggle()
    }
    
    func createNewDocument() {
        showingNewDocumentView = true
    }
    
    func createNewProject() {
        isShowingNewProjectSheet = true
    }
    
    func createNewChat() {
        isShowingChatAssistant = true
    }
    
    func toggleChatAssistant() {
        isShowingChatAssistant.toggle()
    }
    
    func showAISettings() {
        isShowingAISettings = true
    }
    
    func showSettings() {
        isShowingSettings = true
    }
    
    func selectDocument(_ document: Document?) {
        selectedDocument = document
    }
    
    func selectProject(_ project: Project?) {
        selectedProject = project
    }
    
    // MARK: - New Enhanced Actions
    
    func showProjectCreation() {
        isShowingProjectCreation = true
    }
    
    func showExportView() {
        isShowingExportView = true
    }
    
    func toggleAIPanel() {
        showAIPanel.toggle()
    }
    
    func setWritingFocus(_ mode: WritingFocusMode) {
        focusMode = mode
        
        // Apply focus mode settings
        switch mode {
        case .normal:
            showBinder = true
            showInspector = true
            showAIPanel = true
        case .typewriter:
            // Keep panels but focus on editor
            break
        case .zen:
            showBinder = false
            showInspector = false
            showAIPanel = false
        case .distraction_free:
            showBinder = false
            showInspector = false
            showAIPanel = false
        }
    }
    
    func setWritingGoal(_ wordCount: Int?) {
        wordCountGoal = wordCount
    }
    
    func sendAIMessage(_ message: String, taskType: WritingTaskType? = nil) async {
        let task = taskType ?? currentWritingTask
        
        // Add user message to conversation
        let userMessage = AIMessage(role: .user, content: message)
        aiConversation.append(userMessage)
        
        do {
            let response = try await aiService.sendMessage(
                message,
                taskType: task,
                provider: selectedAIProvider
            )
            
            // Add AI response to conversation
            let aiMessage = AIMessage(role: .assistant, content: response)
            aiConversation.append(aiMessage)
            
        } catch {
            // Handle error - could add error message to conversation
            let errorMessage = AIMessage(role: .assistant, content: "Sorry, I encountered an error: \(error.localizedDescription)")
            aiConversation.append(errorMessage)
        }
    }
    
    func clearAIConversation() {
        aiConversation.removeAll()
    }
    
    func getWritingSuggestions(for content: String) async {
        guard selectedDocument != nil else { return }
        
        do {
            let suggestions = try await aiService.getWritingSuggestions(
                for: content,
                taskType: currentWritingTask
            )
            
            let suggestionMessage = AIMessage(
                role: .assistant,
                content: "Here are some suggestions for your writing:\n\n\(suggestions)"
            )
            aiConversation.append(suggestionMessage)
            
        } catch {
            let errorMessage = AIMessage(
                role: .assistant,
                content: "I couldn't generate suggestions right now: \(error.localizedDescription)"
            )
            aiConversation.append(errorMessage)
        }
    }
    
    // MARK: - Preview Support
    static var preview: AppState {
        let container = try! ModelContainer(
            for: Document.self, Project.self, AppSettings.self, DocumentSection.self, ChatMessage.self, Conversation.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return AppState(modelContext: container.mainContext)
    }
}