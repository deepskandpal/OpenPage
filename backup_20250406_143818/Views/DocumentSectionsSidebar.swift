import SwiftUI
import SwiftData

struct DocumentSectionsSidebar: View {
    var document: Document
    @Binding var selectedSectionId: UUID?
    @State private var isAddingSection = false
    @State private var newSectionTitle = ""
    @State private var newSectionParent: DocumentSection?
    @State private var showingContextMenu = false
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Sections")
                    .font(.headline)
                Spacer()
                Button(action: {
                    isAddingSection = true
                    newSectionParent = document.rootSection
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Add new section")
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Hierarchical tree of sections
            if document.isHierarchical, let rootSection = document.rootSection {
                List {
                    SectionTreeItem(
                        section: rootSection,
                        selectedSectionId: $selectedSectionId,
                        onAddSection: { section in
                            isAddingSection = true
                            newSectionParent = section
                        }
                    )
                }
                .listStyle(SidebarListStyle())
            } else {
                VStack {
                    Text("This document has no sections yet.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Convert to Hierarchical Document") {
                        document.convertToHierarchical()
                        if let rootSection = document.rootSection {
                            selectedSectionId = rootSection.id
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .padding(.bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 200)
        .sheet(isPresented: $isAddingSection) {
            // Add section sheet
            VStack(spacing: 16) {
                Text("Add New Section")
                    .font(.headline)
                
                VStack(alignment: .leading) {
                    Text("Title")
                        .font(.caption)
                    TextField("Section Title", text: $newSectionTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                if let parent = newSectionParent {
                    VStack(alignment: .leading) {
                        Text("Parent")
                            .font(.caption)
                        Text(parent.title)
                            .padding(6)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                HStack {
                    Spacer()
                    Button("Cancel") {
                        isAddingSection = false
                        newSectionTitle = ""
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Add") {
                        guard !newSectionTitle.isEmpty, let parent = newSectionParent else { return }
                        
                        // Create the new section
                        let _ = document.createSection(
                            title: newSectionTitle,
                            content: "",
                            parent: parent
                        )
                        
                        // Reset state
                        isAddingSection = false
                        newSectionTitle = ""
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(newSectionTitle.isEmpty)
                }
            }
            .padding()
            .frame(width: 400)
        }
    }
}

// A recursive tree item component
struct SectionTreeItem: View {
    var section: DocumentSection
    @Binding var selectedSectionId: UUID?
    @State private var isExpanded = true
    var onAddSection: (DocumentSection) -> Void
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // Children
            if let children = section.children, !children.isEmpty {
                ForEach(children.sorted(by: { $0.sortOrder < $1.sortOrder }), id: \.id) { child in
                    SectionTreeItem(
                        section: child,
                        selectedSectionId: $selectedSectionId,
                        onAddSection: onAddSection
                    )
                    .padding(.leading, 4)
                }
            }
        } label: {
            HStack {
                // Icon based on type
                Image(systemName: iconForType(section.type, isContainer: section.isContainer))
                    .foregroundColor(section.metadata?.color != nil ? Color(section.metadata!.color!) : .primary)
                
                Text(section.title)
                    .lineLimit(1)
                
                Spacer()
                
                // Section actions
                if selectedSectionId == section.id {
                    Menu {
                        if section.isContainer {
                            Button(action: {
                                onAddSection(section)
                            }) {
                                Label("Add Subsection", systemImage: "plus")
                            }
                            
                            Divider()
                        }
                        
                        if section.parent != nil { // Can't delete root
                            Button(action: {
                                section.parent?.removeChild(section)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .foregroundColor(.red)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.secondary)
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .fixedSize()
                }
            }
            .padding(.vertical, 4)
            .background(selectedSectionId == section.id ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(4)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedSectionId = section.id
            }
            .contextMenu {
                if section.isContainer {
                    Button(action: {
                        onAddSection(section)
                    }) {
                        Label("Add Subsection", systemImage: "plus")
                    }
                    
                    Divider()
                }
                
                if section.parent != nil { // Can't delete root
                    Button(action: {
                        section.parent?.removeChild(section)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .padding(.vertical, 1)
    }
    
    // Helper to determine icon based on section type
    private func iconForType(_ type: String, isContainer: Bool) -> String {
        if isContainer {
            return "folder"
        }
        
        switch type {
        case "text":
            return "doc.text"
        case "header":
            return "h.square"
        default:
            return "doc"
        }
    }
}

struct DocumentSectionsSidebar_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview document with sections
        let document = Document(title: "Preview Document")
        document.convertToHierarchical()
        
        if let root = document.rootSection {
            let chapter1 = DocumentSection(
                title: "Chapter 1",
                content: "This is chapter 1",
                type: "folder",
                isContainer: true
            )
            root.addChild(chapter1)
            
            let scene1 = DocumentSection(
                title: "Scene 1",
                content: "This is scene 1",
                type: "text",
                isContainer: false
            )
            chapter1.addChild(scene1)
            
            let scene2 = DocumentSection(
                title: "Scene 2",
                content: "This is scene 2",
                type: "text",
                isContainer: false
            )
            chapter1.addChild(scene2)
            
            let chapter2 = DocumentSection(
                title: "Chapter 2",
                content: "This is chapter 2",
                type: "folder",
                isContainer: true
            )
            root.addChild(chapter2)
        }
        
        return DocumentSectionsSidebar(
            document: document,
            selectedSectionId: .constant(document.rootSection?.id)
        )
        .frame(width: 250, height: 400)
        .previewLayout(.sizeThatFits)
    }
} 