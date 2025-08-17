import Foundation

/// Global app state manager for menu command coordination
/// Provides a simple way for menu commands to trigger app actions
@MainActor
class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    private init() {}
    
    // MARK: - Action Publishers
    
    @Published var createDocumentRequested = false
    @Published var createProjectRequested = false
    @Published var createChatRequested = false
    @Published var toggleChatRequested = false
    @Published var showAISettingsRequested = false
    
    // MARK: - Actions
    
    func requestCreateDocument() {
        createDocumentRequested = true
    }
    
    func requestCreateProject() {
        createProjectRequested = true
    }
    
    func requestCreateChat() {
        createChatRequested = true
    }
    
    func requestToggleChat() {
        toggleChatRequested = true
    }
    
    func requestShowAISettings() {
        showAISettingsRequested = true
    }
    
    // MARK: - Reset Methods (called by AppState when handled)
    
    func resetCreateDocument() {
        createDocumentRequested = false
    }
    
    func resetCreateProject() {
        createProjectRequested = false
    }
    
    func resetCreateChat() {
        createChatRequested = false
    }
    
    func resetToggleChat() {
        toggleChatRequested = false
    }
    
    func resetShowAISettings() {
        showAISettingsRequested = false
    }
}