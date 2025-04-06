import SwiftUI
import SwiftData

struct HierarchicalEditorView: View {
    var document: Document
    @Binding var selectedSectionId: UUID?
    @State private var currentSection: DocumentSection?
    @State private var showingSidebar = true
    
    var body: some View {
        HSplitView {
            // Sections sidebar
            if showingSidebar {
                DocumentSectionsSidebar(
                    document: document,
                    selectedSectionId: $selectedSectionId
                )
                .frame(minWidth: 200, maxWidth: 300)
            }
            
            // Editor for the selected section
            VStack {
                // Editor toolbar
                HStack {
                    if !showingSidebar {
                        Button(action: {
                            showingSidebar = true
                        }) {
                            Image(systemName: "sidebar.left")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .help("Show Sections")
                    } else {
                        Button(action: {
                            showingSidebar = false
                        }) {
                            Image(systemName: "sidebar.left")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .help("Hide Sections")
                    }
                    
                    Spacer()
                    
                    // Section navigation breadcrumb
                    if let section = currentSection {
                        HStack(spacing: 4) {
                            ForEach(section.pathComponents.indices, id: \.self) { index in
                                if index > 0 {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(section.pathComponents[index])
                                    .font(.caption)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Word count and status
                    HStack {
                        Text("\(document.wordCount) words")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let target = document.targetWordCount {
                            ProgressView(value: document.wordCountProgress)
                                .progressViewStyle(.linear)
                                .frame(width: 100)
                            
                            Text("\(Int(document.wordCountProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Divider()
                
                // Content editor
                if let section = currentSection {
                    SectionEditor(section: section)
                } else if let rootSection = document.rootSection {
                    // If no section is selected, select the root
                    Text("Select a section to edit")
                        .foregroundColor(.secondary)
                        .onAppear {
                            selectedSectionId = rootSection.id
                        }
                } else {
                    // If document is not hierarchical
                    NonHierarchicalEditor(document: document)
                }
            }
        }
        .onChange(of: selectedSectionId) { id in
            if let id = id, let sections = document.sections {
                currentSection = sections.first(where: { $0.id == id })
            } else {
                currentSection = nil
            }
        }
        .onChange(of: document.isHierarchical) { isHierarchical in
            if isHierarchical, let rootSection = document.rootSection {
                selectedSectionId = rootSection.id
            }
        }
        .navigationTitle(document.title)
    }
}

// Editor for a specific section
struct SectionEditor: View {
    var section: DocumentSection
    @State private var localContent: String
    @FocusState private var isEditorFocused: Bool
    @Environment(\.modelContext) private var modelContext
    
    // Initialize with section's content
    init(section: DocumentSection) {
        self.section = section
        self._localContent = State(initialValue: section.content)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section title bar
            HStack {
                Text(section.title)
                    .font(.headline)
                
                Spacer()
                
                // Metadata status indicator
                if let status = section.metadata?.status, status != "draft" {
                    Text(status.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor(status))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            
            // Text editor
            TextEditor(text: $localContent)
                .focused($isEditorFocused)
                .font(.body)
                .padding()
                .onChange(of: localContent) { _ in
                    // Update section content in the model context
                    section.content = localContent
                    section.updateCounts()
                }
        }
        .onAppear {
            // Ensure local content is synced with section
            localContent = section.content
            
            // Focus the editor after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isEditorFocused = true
            }
        }
    }
    
    // Helper to determine color based on status
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "draft":
            return .gray
        case "in progress":
            return .blue
        case "complete":
            return .green
        case "archived":
            return .gray
        case "needs revision":
            return .orange
        default:
            return .gray
        }
    }
}

// Editor for non-hierarchical documents
struct NonHierarchicalEditor: View {
    var document: Document
    @State private var localContent: String
    @Environment(\.modelContext) private var modelContext
    
    init(document: Document) {
        self.document = document
        self._localContent = State(initialValue: document.content)
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $localContent)
                .font(.body)
                .padding()
                .onChange(of: localContent) { _ in
                    document.content = localContent
                    document.updateCounts()
                }
                .onAppear {
                    localContent = document.content
                }
        }
    }
}

struct HierarchicalEditorView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview document with sections
        let document = Document(title: "Preview Document")
        document.convertToHierarchical()
        
        if let root = document.rootSection {
            let chapter1 = DocumentSection(
                title: "Chapter 1", 
                content: "This is the first chapter of the story.\n\nIt was a dark and stormy night...",
                type: "folder",
                isContainer: true
            )
            root.addChild(chapter1)
            
            let scene1 = DocumentSection(
                title: "Scene 1",
                content: "The protagonist enters the haunted house, unaware of what awaits inside.",
                type: "text",
                isContainer: false
            )
            chapter1.addChild(scene1)
        }
        
        return HierarchicalEditorView(document: document, selectedSectionId: .constant(nil))
            .frame(width: 800, height: 600)
            .previewLayout(.sizeThatFits)
    }
} 