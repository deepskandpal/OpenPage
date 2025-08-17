import SwiftUI
import SwiftData

/// Manages all sheets and modal presentations for the app
/// Centralizes modal state management
struct AppSheets: ViewModifier {
    @ObservedObject var appState: AppState
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $appState.isShowingSettings) {
                SettingsView(viewModel: settingsViewModel)
            }
            .sheet(isPresented: $appState.showingNewDocumentView) {
                EnhancedDocumentCreationView(
                    isPresented: $appState.showingNewDocumentView
                ) { documentTitle, projectId, template, author, synopsis, tags, category, targetWordCount, deadline in
                    createNewDocument(
                        title: documentTitle,
                        projectId: projectId,
                        template: template,
                        author: author,
                        synopsis: synopsis,
                        tags: tags,
                        category: category,
                        targetWordCount: targetWordCount,
                        deadline: deadline
                    )
                }
            }
            .sheet(isPresented: $appState.isShowingNewProjectSheet) {
                NewProjectView(isPresented: $appState.isShowingNewProjectSheet) { name, description in
                    let newProject = Project(name: name, projectDescription: description)
                    modelContext.insert(newProject)
                    appState.selectProject(newProject)
                }
            }
    }
    
    private func createNewDocument(
        title: String,
        projectId: PersistentIdentifier?,
        template: DocumentTemplate,
        author: String,
        synopsis: String,
        tags: [String],
        category: String,
        targetWordCount: Int?,
        deadline: Date?
    ) {
        // Create new document with template content and metadata
        let document = Document(
            title: title.isEmpty ? "Untitled" : title,
            content: template.initialContent,
            createdAt: Date(),
            tags: tags,
            isFavorite: false,
            author: author.isEmpty ? nil : author,
            category: category.isEmpty ? nil : category,
            templateType: template.name
        )
        
        // Apply template font settings if available
        document.fontName = template.defaultFontName.isEmpty ? nil : template.defaultFontName
        document.fontSize = template.defaultFontSize > 0 ? template.defaultFontSize : nil
        
        // Set synopsis if provided
        document.synopsis = synopsis.isEmpty ? nil : synopsis
        
        // Set writing goals if provided
        if let targetWordCount = targetWordCount {
            document.setWritingGoal(
                targetWords: targetWordCount,
                deadline: deadline,
                dailyGoal: calculateDailyGoal(target: targetWordCount, deadline: deadline)
            )
        }
        
        // Determine which project to add the document to
        let targetProject: Project
        
        // If projectId is provided, find that project
        if let projectId = projectId,
           let project = projects.first(where: { $0.id == projectId }) {
            targetProject = project
        }
        // If no project was selected but we have a selected project, use that
        else if let selectedProject = appState.selectedProject {
            targetProject = selectedProject
        }
        // If no project was selected but projects exist, create in the first project
        else if let firstProject = projects.first {
            targetProject = firstProject
        }
        // If no projects exist, create a default project first
        else {
            let newProject = Project(name: "My Project")
            modelContext.insert(newProject)
            targetProject = newProject
        }
        
        // Add the document to the selected project
        targetProject.addDocument(document)
        appState.selectDocument(document)
    }
    
    private func calculateDailyGoal(target: Int, deadline: Date?) -> Int? {
        guard let deadline = deadline else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        
        guard let days = components.day, days > 0 else { return target }
        
        return Int(ceil(Double(target) / Double(days)))
    }
}

extension View {
    func appSheets(appState: AppState, settingsViewModel: SettingsViewModel) -> some View {
        modifier(AppSheets(appState: appState, settingsViewModel: settingsViewModel))
    }
}