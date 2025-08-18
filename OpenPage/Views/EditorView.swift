import SwiftUI
import SwiftData
import Combine

struct EditorView: View {
    var document: Document
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = "edit"
    @State private var selectedSectionId: UUID? = nil
    @State private var documentContent: String
    @State private var isDirty = false
    @State private var lastSavedDate: Date?
    @State private var autoSaveTimer: Timer?
    
    @State private var showCommandPalette = false
    @FocusState private var isEditorFocused: Bool
    
    init(document: Document) {
        self.document = document
        self._documentContent = State(initialValue: document.content)
        self._isDirty = State(initialValue: false)
        self._lastSavedDate = State(initialValue: document.lastSavedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Document Header
            DocumentHeader(
                document: document,
                selectedTab: $selectedTab,
                showCommandPalette: $showCommandPalette
            )
            
            // Main Editor Area
            Group {
                if !document.isHierarchical {
                    // Modern editor with full formatting functionality
                    if selectedTab == "edit" {
                        ModernEditorView(
                            content: $documentContent,
                            focusMode: .constant(.normal)
                        )
                        .onChange(of: documentContent) { oldValue, newValue in
                            document.content = newValue
                            document.updateCounts()
                            isDirty = true
                        }
                    } else if selectedTab == "preview" {
                        MarkdownPreviewView(content: documentContent)
                    } else {
                        // Split view - use modern editor on left
                        HSplitView {
                            ModernEditorView(
                                content: $documentContent,
                                focusMode: .constant(.normal)
                            )
                            .onChange(of: documentContent) { oldValue, newValue in
                                document.content = newValue
                                document.updateCounts()
                                isDirty = true
                            }
                            
                            MarkdownPreviewView(content: documentContent)
                        }
                    }
                } else {
                    // Hierarchical document editor
                    HierarchicalEditorView(document: document, selectedSectionId: $selectedSectionId)
                }
            }
        }
        .overlay(alignment: .top) {
            if showCommandPalette {
                CommandPaletteView(isShowing: $showCommandPalette)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            // Ensure documentContent is synced with document.content
            documentContent = document.content
            startAutoSave()
            // Focus the editor when it appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isEditorFocused = true
            }
        }
        .onDisappear {
            stopAutoSave()
            if isDirty {
                saveDocument()
            }
        }
        .onChange(of: document.content) { oldValue, newValue in
            // Update documentContent when document.content changes (e.g., from convert operations)
            if documentContent != newValue {
                documentContent = newValue
            }
        }
    }
    
    private func saveDocument() {
        document.content = documentContent
        document.saveDocument()
        isDirty = false
        lastSavedDate = Date()
    }
    
    private func startAutoSave() {
        stopAutoSave()
        // Auto-save every 30 seconds
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            if isDirty {
                saveDocument()
            }
        }
    }
    
    private func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Supporting Views

struct DocumentHeader: View {
    let document: Document
    @Binding var selectedTab: String
    @Binding var showCommandPalette: Bool
    
    var body: some View {
        HStack {
            Text(document.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Convert buttons
            if !document.isHierarchical {
                Button("Convert to Hierarchical") {
                    document.convertToHierarchical()
                }
                .buttonStyle(.bordered)
                .help("Convert to a hierarchical document with sections")
            } else {
                Button("Convert to Flat") {
                    document.convertToFlat()
                }
                .buttonStyle(.bordered)
                .help("Convert back to a flat document structure")
            }
            
            // View selector
            Picker("View", selection: $selectedTab) {
                Text("Edit").tag("edit")
                Text("Preview").tag("preview") 
                Text("Split").tag("split")
            }
            .pickerStyle(.segmented)
            .frame(width: 180)
            
            // Command palette toggle
            Button(action: {
                showCommandPalette.toggle()
            }) {
                Image(systemName: "command")
            }
            .buttonStyle(.borderless)
            .help("Command Palette (⌘K)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary.opacity(0.3)),
            alignment: .bottom
        )
    }
}

struct MarkdownPreviewView: View {
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // This is a simplified markdown preview
                // In a real app, you'd use a proper markdown renderer
                Text(LocalizedStringKey(content))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(40)
        }
        .background(Color(.textBackgroundColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CommandPaletteView: View {
    @Binding var isShowing: Bool
    @State private var searchText: String = ""
    @State private var commands: [String] = [
        "New Document",
        "Open Document",
        "Save Document",
        "Export as PDF",
        "Export as HTML",
        "Insert Table",
        "Insert Image",
        "Word Count",
        "Focus Mode",
        "Find and Replace"
    ]
    
    var body: some View {
        VStack {
            TextField("Search commands...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            List {
                ForEach(filteredCommands, id: \.self) { command in
                    Text(command)
                        .padding(.vertical, 4)
                        .onTapGesture {
                            executeCommand(command)
                        }
                }
            }
            .frame(height: min(CGFloat(filteredCommands.count * 40), 300))
        }
        .frame(width: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 10)
        .padding()
        .onAppear {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
        .onExitCommand {
            isShowing = false
        }
    }
    
    private var filteredCommands: [String] {
        if searchText.isEmpty {
            return commands
        } else {
            return commands.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func executeCommand(_ command: String) {
        // In a real implementation, we'd execute the command
        print("Executing command: \(command)")
        isShowing = false
    }
}

// MARK: - Simple Editor Toolbar

struct SimpleEditorToolbar: View {
    let content: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Text formatting
            Button(action: {}) {
                Image(systemName: "bold")
            }
            .help("Bold")
            
            Button(action: {}) {
                Image(systemName: "italic")
            }
            .help("Italic")
            
            Button(action: {}) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
            }
            .help("Code")
            
            Divider()
                .frame(height: 20)
            
            // Headers
            Button(action: {}) {
                Text("H1")
                    .font(.caption)
            }
            .help("Header 1")
            
            Button(action: {}) {
                Text("H2")
                    .font(.caption)
            }
            .help("Header 2")
            
            Button(action: {}) {
                Text("H3")
                    .font(.caption)
            }
            .help("Header 3")
            
            Divider()
                .frame(height: 20)
            
            // Lists
            Button(action: {}) {
                Image(systemName: "list.bullet")
            }
            .help("Bullet List")
            
            Button(action: {}) {
                Image(systemName: "list.number")
            }
            .help("Numbered List")
            
            Spacer()
            
            Text("Words: \(countWords(in: content)) Characters: \(countChars(in: content))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary.opacity(0.3)),
            alignment: .bottom
        )
    }
    
    private func countWords(in text: String) -> Int {
        text.split(separator: " ").count
    }
    
    private func countChars(in text: String) -> Int {
        text.count
    }
}

// MARK: - Preview
struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        let document = Document(title: "Sample Document", content: "# Hello World\n\nThis is a **sample document** with *italic text* and `code`.\n\n## Features\n\n- Modern editor\n- Markdown support\n- Multiple themes\n- Writing statistics")
        return EditorView(document: document)
            .environmentObject(AppState.preview)
    }
} 