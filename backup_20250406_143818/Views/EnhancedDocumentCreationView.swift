import SwiftUI
import SwiftData

struct EnhancedDocumentCreationView: View {
    @Binding var isPresented: Bool
    @Query private var projects: [Project]
    @State private var documentTitle = "Untitled"
    @State private var selectedProjectId: PersistentIdentifier?
    @State private var selectedTab = 0
    @State private var selectedTemplate = DocumentTemplate.empty
    @State private var author = ""
    @State private var synopsis = ""
    @State private var tags = [String]()
    @State private var category = ""
    @State private var hasGoal = false
    @State private var targetWordCount = 1000
    @State private var hasDeadline = false
    @State private var deadline = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var dailyGoal = 0
    
    var onSave: (String, PersistentIdentifier?, DocumentTemplate, String, String, [String], String, Int?, Date?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            HStack(spacing: 0) {
                TabButton(title: "Template", systemImage: "doc.text", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "Details", systemImage: "info.circle", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabButton(title: "Goals", systemImage: "chart.bar.fill", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.top)
            
            // Tab content
            TabView(selection: $selectedTab) {
                // Template tab
                TemplateSelectionView(selectedTemplate: $selectedTemplate)
                    .tag(0)
                
                // Details tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Document Title")
                                .font(.headline)
                            
                            TextField("Title", text: $documentTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Author")
                                .font(.headline)
                            
                            TextField("Author name", text: $author)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Project")
                                .font(.headline)
                            
                            if projects.isEmpty {
                                Text("Default Project (will be created)")
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            } else {
                                Picker("Project", selection: $selectedProjectId) {
                                    Text("Default Project").tag(nil as PersistentIdentifier?)
                                    
                                    ForEach(projects) { project in
                                        Text(project.name).tag(project.id as PersistentIdentifier?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Synopsis")
                                .font(.headline)
                            
                            TextEditor(text: $synopsis)
                                .font(.body)
                                .frame(height: 100)
                                .border(Color.gray.opacity(0.2), width: 1)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Category")
                                .font(.headline)
                            
                            TextField("Category", text: $category)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Tags")
                                .font(.headline)
                            
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    TagView(tag: tag) {
                                        if let index = tags.firstIndex(of: tag) {
                                            tags.remove(at: index)
                                        }
                                    }
                                }
                            }
                            
                            TagAddView { newTag in
                                withAnimation {
                                    if !tags.contains(newTag) {
                                        tags.append(newTag)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .tag(1)
                
                // Goals tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Toggle("Set Word Count Goal", isOn: $hasGoal)
                            .font(.headline)
                        
                        if hasGoal {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Target Word Count: \(targetWordCount)")
                                    .foregroundColor(.secondary)
                                
                                Slider(value: Binding(
                                    get: { Double(targetWordCount) },
                                    set: { targetWordCount = Int($0) }
                                ), in: 100...100000, step: 100)
                                
                                HStack {
                                    ForEach([1000, 5000, 10000, 25000, 50000], id: \.self) { value in
                                        Button("\(value)") {
                                            targetWordCount = value
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            Toggle("Set Deadline", isOn: $hasDeadline)
                                .font(.headline)
                            
                            if hasDeadline {
                                DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    if let days = daysUntilDeadline, days > 0 {
                                        Text("Daily word goal to meet deadline: \(dailyWordGoal)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .tag(2)
            }
            
            Divider()
            
            // Bottom controls
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                
                Spacer()
                
                Button(action: {
                    if selectedTab < 2 {
                        withAnimation {
                            selectedTab += 1
                        }
                    } else {
                        createDocument()
                    }
                }) {
                    Text(selectedTab < 2 ? "Next" : "Create")
                        .frame(width: 100)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 700, height: 500)
        .onAppear {
            // Initialize tags with template suggestions
            tags = selectedTemplate.suggestedTags
            
            // Set the author from system if empty
            if author.isEmpty {
                author = NSFullUserName()
            }
        }
        .onChange(of: selectedTemplate) { _, newValue in
            // Update tags when template changes
            if tags.isEmpty {
                tags = newValue.suggestedTags
            } else {
                // Add any new suggested tags that aren't already included
                for tag in newValue.suggestedTags {
                    if !tags.contains(tag) {
                        tags.append(tag)
                    }
                }
            }
        }
        .onChange(of: hasDeadline) { _, newValue in
            if newValue {
                updateDailyGoal()
            }
        }
        .onChange(of: deadline) { _, _ in
            updateDailyGoal()
        }
        .onChange(of: targetWordCount) { _, _ in
            updateDailyGoal()
        }
    }
    
    private func createDocument() {
        let finalTargetWords = hasGoal ? targetWordCount : nil
        let finalDeadline = hasGoal && hasDeadline ? deadline : nil
        
        onSave(
            documentTitle,
            selectedProjectId,
            selectedTemplate,
            author,
            synopsis,
            tags,
            category,
            finalTargetWords,
            finalDeadline
        )
        
        isPresented = false
    }
    
    private var daysUntilDeadline: Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return components.day
    }
    
    private var dailyWordGoal: Int {
        guard let days = daysUntilDeadline, days > 0 else { return targetWordCount }
        let calculated = Int(ceil(Double(targetWordCount) / Double(days)))
        dailyGoal = calculated
        return calculated
    }
    
    private func updateDailyGoal() {
        if hasGoal && hasDeadline {
            _ = dailyWordGoal
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 18))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .foregroundColor(isSelected ? .accentColor : .secondary)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(isSelected ? .accentColor : .clear),
            alignment: .bottom
        )
    }
}

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.1))
        .foregroundColor(.accentColor)
        .cornerRadius(8)
    }
}

struct TagAddView: View {
    @State private var newTag = ""
    let onAdd: (String) -> Void
    
    var body: some View {
        HStack {
            TextField("Add tag...", text: $newTag)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                if !newTag.isEmpty {
                    onAdd(newTag)
                    newTag = ""
                }
            }) {
                Image(systemName: "plus")
            }
            .disabled(newTag.isEmpty)
        }
    }
}

struct EnhancedDocumentCreationView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedDocumentCreationView(isPresented: .constant(true)) { _, _, _, _, _, _, _, _, _ in
            // Preview callback
        }
    }
} 