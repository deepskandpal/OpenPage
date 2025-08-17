import SwiftUI
import SwiftData

/// Main application view - now focused and clean
/// Uses AppState for centralized state management and focused components
struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var appState: AppState
    @StateObject private var settingsViewModel: SettingsViewModel
    
    init(modelContext: ModelContext) {
        // Initialize AppState with model context
        _appState = StateObject(wrappedValue: AppState(modelContext: modelContext))
        
        // Try to fetch existing AppSettings or create new one
        var descriptor = FetchDescriptor<AppSettings>()
        descriptor.fetchLimit = 1
        
        let settings: AppSettings
        if let existingSettings = try? modelContext.fetch(descriptor).first {
            settings = existingSettings
        } else {
            settings = AppSettings()
            modelContext.insert(settings)
        }
        
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(appSettings: settings))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? .black : .white)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                AppToolbar(appState: appState)
                
                HSplitView {
                    if appState.showBinder {
                        BinderPanel(appState: appState)
                    }
                    
                    EditorPanel(appState: appState)
                    
                    if appState.showInspector {
                        InspectorPanel(appState: appState)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .environmentObject(settingsViewModel)
        .appSheets(appState: appState, settingsViewModel: settingsViewModel)
        .onDisappear {
            settingsViewModel.saveSettings()
        }
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an in-memory container for preview
        let container = try! ModelContainer(
            for: Document.self, Project.self, AppSettings.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        // Add some sample data
        let project = Project(name: "Sample Project", projectDescription: "A sample project")
        let document = Document(title: "Welcome", content: "# Welcome to Vibe Writing\n\nThis is your first document.")
        project.addDocument(document)
        container.mainContext.insert(project)
        
        return MainView(modelContext: container.mainContext)
            .modelContainer(container)
    }
}