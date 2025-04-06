import SwiftUI
import SwiftData
import Combine

struct EditorView: View {
    var document: Document
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var selectedTab = "edit"
    @State private var selectedSectionId: UUID? = nil
    @State private var documentContent: String
    @State private var isDirty = false
    @State private var lastSavedDate: Date?
    @State private var autoSaveTimer: Timer?
    
    @State private var showFormatToolbar = false
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
            // Editor toolbar
            HStack {
                Text(document.title)
                    .font(.headline)
                
                Spacer()
                
                // Convert to hierarchical button if not already hierarchical
                if document.sections?.isEmpty ?? true {
                    Button("Convert to Hierarchical") {
                        document.convertToHierarchical()
                    }
                    .help("Convert to a hierarchical document with sections")
                }
                
                // Word count display
                if settingsViewModel.showWordCount {
                    Text("\(document.wordCount) words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Character count display
                if settingsViewModel.showCharacterCount {
                    Text("\(document.characterCount) chars")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
                
                // View selector
                Picker("View", selection: $selectedTab) {
                    Text("Edit").tag("edit")
                    Text("Preview").tag("preview") 
                    Text("Split").tag("split")
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
                
                // Format toolbar toggle
                Button(action: {
                    showFormatToolbar.toggle()
                }) {
                    Image(systemName: "textformat")
                }
                .buttonStyle(.borderless)
                .help("Formatting Tools")
                
                // Command palette toggle
                Button(action: {
                    showCommandPalette.toggle()
                }) {
                    Image(systemName: "command")
                }
                .buttonStyle(.borderless)
                .help("Command Palette")
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Format toolbar if showing
            if showFormatToolbar {
                FormatToolbar(text: $documentContent)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Main editor area
            if document.sections?.isEmpty ?? true || !settingsViewModel.useHierarchicalEditing {
                // Use traditional editor when document has no sections or hierarchical editing is disabled
                if selectedTab == "edit" {
                    TextEditor(text: $documentContent)
                        .font(Font.custom(settingsViewModel.fontName, size: settingsViewModel.fontSize))
                        .focused($isEditorFocused)
                        .padding()
                        .background(settingsViewModel.isDarkMode ? Color.black.opacity(0.8) : Color.white)
                        .cornerRadius(4)
                        .padding(4)
                        .onChange(of: documentContent) {
                            document.content = documentContent
                            document.updateCounts()
                            isDirty = true
                        }
                } else if selectedTab == "preview" {
                    ScrollView {
                        Text(LocalizedStringKey(documentContent))
                            .textSelection(.enabled)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                } else {
                    HSplitView {
                        TextEditor(text: $documentContent)
                            .font(Font.custom(settingsViewModel.fontName, size: settingsViewModel.fontSize))
                            .focused($isEditorFocused)
                            .padding()
                            .background(settingsViewModel.isDarkMode ? Color.black.opacity(0.8) : Color.white)
                            .cornerRadius(4)
                            .padding(4)
                            .onChange(of: documentContent) {
                                document.content = documentContent
                                document.updateCounts()
                                isDirty = true
                            }
                        
                        Divider()
                        
                        ScrollView {
                            Text(LocalizedStringKey(documentContent))
                                .textSelection(.enabled)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                }
            } else {
                // Use hierarchical editor when document has sections and hierarchical editing is enabled
                HierarchicalEditorView(document: document, selectedSectionId: $selectedSectionId)
            }
            
            // Status bar
            HStack {
                if let lastSaved = lastSavedDate {
                    Text("Last saved: \(lastSaved, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Dirty indicator
                if isDirty {
                    Text("Unsaved changes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .overlay(alignment: .top) {
            if showCommandPalette {
                CommandPaletteView(isShowing: $showCommandPalette)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            if settingsViewModel.autoSaveEnabled {
                startAutoSave(interval: TimeInterval(settingsViewModel.autoSaveInterval))
            }
        }
        .onDisappear {
            stopAutoSave()
            
            // Save before leaving
            if isDirty {
                saveDocument()
            }
        }
    }
    
    private func saveDocument() {
        document.content = documentContent
        document.saveDocument()
        isDirty = false
        lastSavedDate = Date()
    }
    
    private func startAutoSave(interval: TimeInterval) {
        stopAutoSave()
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
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

struct FormatToolbar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Button(action: { formatText(with: "**") }) {
                Image(systemName: "bold")
            }
            .buttonStyle(.borderless)
            
            Button(action: { formatText(with: "*") }) {
                Image(systemName: "italic")
            }
            .buttonStyle(.borderless)
            
            Button(action: { formatText(with: "~~") }) {
                Image(systemName: "strikethrough")
            }
            .buttonStyle(.borderless)
            
            Divider()
            
            Button(action: { insertMarkdown("# ") }) {
                Text("H1")
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderless)
            
            Button(action: { insertMarkdown("## ") }) {
                Text("H2")
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderless)
            
            Button(action: { insertMarkdown("### ") }) {
                Text("H3")
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderless)
            
            Divider()
            
            Button(action: { insertMarkdown("- ") }) {
                Image(systemName: "list.bullet")
            }
            .buttonStyle(.borderless)
            
            Button(action: { insertMarkdown("1. ") }) {
                Image(systemName: "list.number")
            }
            .buttonStyle(.borderless)
            
            Button(action: { insertMarkdown("> ") }) {
                Image(systemName: "text.quote")
            }
            .buttonStyle(.borderless)
            
            Button(action: { insertMarkdown("```\n\n```") }) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func formatText(with marker: String) {
        // This would require access to the NSTextView to handle selections
        // In a real implementation, we'd need to handle this properly
        text = text + marker + "text" + marker
    }
    
    private func insertMarkdown(_ markdown: String) {
        // Again, in a real implementation, we'd insert at cursor position
        text = text + "\n" + markdown
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

// MARK: - Preview
struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        let document = Document(title: "Sample Document", content: "# Hello World\n\nThis is a sample document.")
        return EditorView(document: document)
            .environmentObject(SettingsViewModel(appSettings: AppSettings()))
    }
} 