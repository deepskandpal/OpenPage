import SwiftUI
import SwiftData

struct ProjectCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTemplate: ProjectTemplateType?
    @State private var projectName: String = ""
    @State private var customDescription: String = ""
    @State private var searchText: String = ""
    
    var onProjectCreated: (Project) -> Void
    
    // Filter templates based on search
    private var filteredTemplates: [ProjectTemplateType] {
        if searchText.isEmpty {
            return ProjectTemplateType.allCases
        } else {
            return ProjectTemplateType.allCases.filter { template in
                template.displayName.localizedCaseInsensitiveContains(searchText) ||
                template.description.localizedCaseInsensitiveContains(searchText) ||
                template.defaultTags.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Group templates by category
    private var templateCategories: [(String, [ProjectTemplateType])] {
        let categories = [
            ("Fiction", [ProjectTemplateType.novel, ProjectTemplateType.shortStory, ProjectTemplateType.screenplay, ProjectTemplateType.poetry]),
            ("Non-Fiction", [ProjectTemplateType.nonFiction, ProjectTemplateType.essay, ProjectTemplateType.researchPaper]),
            ("Technical", [ProjectTemplateType.techBlog, ProjectTemplateType.businessPlan]),
            ("Personal", [ProjectTemplateType.journal])
        ]
        
        return categories.compactMap { (name, templates) in
            let filtered = templates.filter { filteredTemplates.contains($0) }
            return filtered.isEmpty ? nil : (name, filtered)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with search
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create New Project")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Choose a template to get started with your writing project")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search templates...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                
                Divider()
                
                // Template selection
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(templateCategories, id: \.0) { categoryName, templates in
                            VStack(alignment: .leading, spacing: 12) {
                                // Category header
                                HStack {
                                    Text(categoryName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                
                                // Template grid
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 280), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(templates, id: \.self) { template in
                                        ProjectTemplateCard(
                                            template: template,
                                            isSelected: selectedTemplate == template
                                        ) {
                                            selectedTemplate = template
                                            projectName = template.displayName
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                // Project details and creation
                if selectedTemplate != nil {
                    Divider()
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Project Details")
                                .font(.headline)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Name:")
                                    .frame(width: 80, alignment: .leading)
                                
                                TextField("Enter project name", text: $projectName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack(alignment: .top) {
                                Text("Description:")
                                    .frame(width: 80, alignment: .leading)
                                
                                TextField("Custom description (optional)", text: $customDescription, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...6)
                            }
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button("Create Project") {
                                createProject()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(projectName.isEmpty || selectedTemplate == nil)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color(.controlBackgroundColor))
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
    
    private func createProject() {
        guard let templateType = selectedTemplate else { return }
        
        let template = ProjectTemplateFactory.createTemplate(for: templateType)
        
        let project = ProjectTemplateFactory.createProject(
            from: template,
            name: projectName,
            modelContext: modelContext
        )
        
        // Update description if custom one provided
        if !customDescription.isEmpty {
            project.summary = customDescription
        }
        
        try? modelContext.save()
        
        onProjectCreated(project)
        dismiss()
    }
}

struct ProjectTemplateCard: View {
    let template: ProjectTemplateType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon
                HStack {
                    Image(systemName: template.icon)
                        .font(.title2)
                        .foregroundColor(getColor(from: template.color))
                        .frame(width: 32, height: 32)
                        .background(getColor(from: template.color).opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(template.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(template.writingTaskType.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                }
                
                // Description
                Text(template.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Tags
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 60), spacing: 4)
                ], spacing: 4) {
                    ForEach(template.defaultTags.prefix(4), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.tertiarySystemFill))
                            .cornerRadius(4)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(.controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func getColor(from colorName: String) -> Color {
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

#Preview {
    ProjectCreationView { _ in
        // Preview callback
    }
    .modelContainer(for: [Project.self, Document.self], inMemory: true)
}