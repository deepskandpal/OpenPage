import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @State private var isShowingSettings = false
    @State private var showingNewDocumentView = false
    @State private var isShowingNewProjectSheet = false
    @StateObject private var settingsViewModel: SettingsViewModel
    
    // State for Scrivener-like interface
    @State private var selectedDocument: Document?
    @State private var selectedProject: Project?
    @State private var showInspector = true
    @State private var showBinder = true
    
    // There should be only one AppSettings instance in the entire app
    init(modelContext: ModelContext) {
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
        
        // Initialize the view model with settings
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(appSettings: settings))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .edgesIgnoringSafeArea(.all) // Ensure background extends to all edges
            
            VStack(spacing: 0) {
                // Header toolbar with app controls
                HStack {
                    Text("Vibe Writing")
                        .font(.headline)
                    Spacer()
                    
                    // Document controls
                    Button(action: { showingNewDocumentView = true }) {
                        Label("New Document", systemImage: "doc.badge.plus")
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                    
                    Button(action: { isShowingSettings = true }) {
                        Image(systemName: "gear")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                
                // Main content area with three panels
                HSplitView {
                    // BINDER PANEL (LEFT)
                    if showBinder {
                        VStack(spacing: 0) {
                            // Binder header
                            HStack {
                                Text("Binder")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    isShowingNewProjectSheet = true
                                }) {
                                    Image(systemName: "folder.badge.plus")
                                        .font(.system(size: 12))
                                }
                                .buttonStyle(.borderless)
                                .help("New Project")
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            
                            // Binder content
                            SidebarView(
                                selectedDocument: $selectedDocument,
                                selectedProject: $selectedProject
                            )
                            .layoutPriority(1)
                        }
                        .frame(minWidth: 220, idealWidth: 250, maxWidth: 300, maxHeight: .infinity, alignment: .top)
                        .background(Color.gray.opacity(0.05))
                    }
                    
                    // EDITOR PANEL (CENTER)
                    VStack(spacing: 0) {
                        // Editor toolbar
                        HStack {
                            // Binder toggle button
                            Button(action: { showBinder.toggle() }) {
                                Image(systemName: "sidebar.leading")
                                    .foregroundColor(showBinder ? .accentColor : .primary)
                            }
                            .buttonStyle(.borderless)
                            .help(showBinder ? "Hide Binder" : "Show Binder")
                            
                            Spacer()
                            
                            // Editor context title
                            if let document = selectedDocument {
                                Text(document.title)
                                    .font(.headline)
                            } else {
                                Text("No Document Selected")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            // Inspector toggle button
                            Button(action: { showInspector.toggle() }) {
                                Image(systemName: "sidebar.trailing")
                                    .foregroundColor(showInspector ? .accentColor : .primary)
                            }
                            .buttonStyle(.borderless)
                            .help(showInspector ? "Hide Inspector" : "Show Inspector")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        
                        // Editor content
                        ZStack {
                            Color.white
                                .edgesIgnoringSafeArea(.all)
                            
                            if let document = selectedDocument {
                                EditorView(document: document)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    )
                                    .padding()
                            } else {
                                // Welcome/empty state
                                VStack(spacing: 20) {
                                    Spacer()
                                    
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 64))
                                        .foregroundColor(.secondary)
                                    
                                    Text("Welcome to Vibe Writing")
                                        .font(.largeTitle)
                                    
                                    Text("Select a document from the binder or create a new one")
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        showingNewDocumentView = true
                                    }) {
                                        Label("Create New Document", systemImage: "doc.badge.plus")
                                            .font(.headline)
                                            .padding()
                                            .background(Color.accentColor)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .layoutPriority(1)
                    }
                    .frame(minWidth: 450, idealWidth: 600, maxHeight: .infinity)
                    
                    // INSPECTOR PANEL (RIGHT)
                    if showInspector {
                        VStack(spacing: 0) {
                            // Inspector header
                            HStack {
                                Text("Inspector")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            
                            // Inspector content
                            if let document = selectedDocument {
                                SimplestInspectorView(document: document)
                                    .layoutPriority(1)
                            } else {
                                ContentUnavailableView {
                                    Label("No Document Selected", systemImage: "doc.text.magnifyingglass")
                                } description: {
                                    Text("Select a document to see its properties")
                                }
                                .layoutPriority(1)
                            }
                        }
                        .frame(minWidth: 220, idealWidth: 250, maxWidth: 300, maxHeight: .infinity, alignment: .top)
                        .background(Color.gray.opacity(0.05))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(settingsViewModel)
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(viewModel: settingsViewModel)
        }
        .sheet(isPresented: $showingNewDocumentView) {
            EnhancedDocumentCreationView(isPresented: $showingNewDocumentView) { documentTitle, projectId, template, author, synopsis, tags, category, targetWordCount, deadline in
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
        .sheet(isPresented: $isShowingNewProjectSheet) {
            NewProjectView(isPresented: $isShowingNewProjectSheet) { name, description in
                let newProject = Project(name: name, projectDescription: description)
                modelContext.insert(newProject)
                selectedProject = newProject
            }
        }
        .onAppear {
            setupNotifications()
        }
        .onDisappear {
            removeNotifications()
            // Save settings when view disappears
            settingsViewModel.saveSettings()
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("CreateNewDocument"),
            object: nil,
            queue: .main
        ) { _ in
            showingNewDocumentView = true
        }
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name("CreateNewProject"),
            object: nil,
            queue: .main
        ) { _ in
            isShowingNewProjectSheet = true
        }
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name("CreateNewDocument"),
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name("CreateNewProject"),
            object: nil
        )
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
        else if let selectedProject = selectedProject {
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
        selectedDocument = document
    }
    
    private func calculateDailyGoal(target: Int, deadline: Date?) -> Int? {
        guard let deadline = deadline else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        
        guard let days = components.day, days > 0 else { return target }
        
        return Int(ceil(Double(target) / Double(days)))
    }
}

// A preview provider that sets up the model container
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