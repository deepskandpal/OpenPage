import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    
    @Binding var selectedDocument: Document?
    @Binding var selectedProject: Project?
    @State private var isShowingNewProjectSheet = false
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            // Search bar
            TextField("Search documents", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            
            // Project list
            List {
                Section("Projects") {
                    ForEach(projects) { project in
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { selectedProject?.id == project.id },
                                set: { if $0 { selectedProject = project } }
                            ),
                            content: {
                                ForEach(project.documents) { document in
                                    HStack {
                                        Button(action: {
                                            selectedDocument = document
                                        }) {
                                            HStack {
                                                Text(document.title)
                                                Spacer()
                                                Text("\(document.wordCount)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .background(selectedDocument?.id == document.id ? Color.accentColor.opacity(0.2) : Color.clear)
                                        .cornerRadius(4)
                                    }
                                    .contextMenu {
                                        Button("Rename", action: {
                                            // Rename functionality would go here
                                        })
                                        Button("Delete", role: .destructive) {
                                            deleteDocument(document, from: project)
                                        }
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteDocuments(from: project, at: indexSet)
                                }
                                
                                Button(action: {
                                    addDocument(to: project)
                                }) {
                                    Label("New Document", systemImage: "plus")
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                            },
                            label: {
                                HStack {
                                    if let icon = project.icon {
                                        Image(systemName: icon)
                                            .foregroundColor(getColor(from: project.color))
                                    }
                                    Text(project.name)
                                        .font(.headline)
                                    Spacer()
                                    Text("\(project.documentCount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        )
                    }
                    .onDelete(perform: deleteProjects)
                }
                
                Section("Smart Filters") {
                    FilterView(title: "All Documents", systemImage: "doc")
                    FilterView(title: "Favorites", systemImage: "star")
                    FilterView(title: "Recent", systemImage: "clock")
                    FilterView(title: "Tags", systemImage: "tag")
                }
            }
            .listStyle(.sidebar)
        }
    }
    
    private func addProject(name: String, description: String) {
        let newProject = Project(name: name, projectDescription: description)
        modelContext.insert(newProject)
        selectedProject = newProject
    }
    
    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            let project = projects[index]
            
            // If the project being deleted is selected, deselect it
            if selectedProject?.id == project.id {
                selectedProject = nil
            }
            
            // If any document from this project is selected, deselect it
            if let selected = selectedDocument, project.documents.contains(where: { $0.id == selected.id }) {
                selectedDocument = nil
            }
            
            modelContext.delete(project)
        }
    }
    
    private func addDocument(to project: Project) {
        let newDocument = Document(title: "Untitled", createdAt: Date())
        project.addDocument(newDocument)
        selectedProject = project
        selectedDocument = newDocument
    }
    
    private func deleteDocument(_ document: Document, from project: Project) {
        if selectedDocument?.id == document.id {
            selectedDocument = nil
        }
        modelContext.delete(document)
    }
    
    private func deleteDocuments(from project: Project, at offsets: IndexSet) {
        for index in offsets {
            let document = project.documents[index]
            if selectedDocument?.id == document.id {
                selectedDocument = nil
            }
            modelContext.delete(document)
        }
    }
    
    private func getColor(from colorName: String?) -> Color {
        guard let colorName = colorName else { return .blue }
        
        switch colorName {
        case "Blue": return .blue
        case "Purple": return .purple
        case "Pink": return .pink
        case "Red": return .red
        case "Orange": return .orange
        case "Yellow": return .yellow
        case "Green": return .green
        case "Teal": return .teal
        default: return .blue
        }
    }
}

struct FilterView: View {
    var title: String
    var systemImage: String
    
    var body: some View {
        Label(title, systemImage: systemImage)
    }
}

struct NewProjectView: View {
    @Binding var isPresented: Bool
    @State private var projectName = ""
    @State private var projectDescription = ""
    
    var onSave: (String, String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $projectName)
                    
                    TextField("Description (optional)", text: $projectDescription)
                        .frame(height: 100, alignment: .topLeading)
                }
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onSave(projectName, projectDescription)
                        isPresented = false
                    }
                    .disabled(projectName.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(
            selectedDocument: .constant(nil),
            selectedProject: .constant(nil)
        )
    } detail: {
        Text("Select a document")
    }
    .modelContainer(for: [Project.self, Document.self], inMemory: true)
} 