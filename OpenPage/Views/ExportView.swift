import SwiftUI
import SwiftData

struct ExportView: View {
    let document: Document?
    let project: Project?
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var exportService = ExportService.shared
    
    @State private var exportOptions = ExportService.ExportOptions()
    @State private var customFileName: String = ""
    @State private var exportedContent: String = ""
    @State private var showingExportedContent = false
    @State private var showingError = false
    
    init(document: Document) {
        self.document = document
        self.project = nil
        self._customFileName = State(initialValue: document.title)
    }
    
    init(project: Project) {
        self.document = nil
        self.project = project
        self._customFileName = State(initialValue: project.name)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Export")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            if let document = document {
                                Text("Export '\(document.title)' to various formats")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else if let project = project {
                                Text("Export project '\(project.name)' with \(project.documents.count) document(s)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                
                Divider()
                
                // Export options
                ScrollView {
                    VStack(spacing: 24) {
                        // Basic options
                        GroupBox("Export Settings") {
                            VStack(spacing: 16) {
                                // Format selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Format")
                                        .font(.headline)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.adaptive(minimum: 150), spacing: 12)
                                    ], spacing: 12) {
                                        ForEach(ExportService.ExportFormat.allCases) { format in
                                            FormatCard(
                                                format: format,
                                                isSelected: exportOptions.format == format
                                            ) {
                                                exportOptions.format = format
                                            }
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                // Scope (only show for projects with multiple documents)
                                if let project = project, project.documents.count > 1 {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Scope")
                                            .font(.headline)
                                        
                                        Picker("Export Scope", selection: $exportOptions.scope) {
                                            ForEach(ExportService.ExportScope.allCases, id: \.self) { scope in
                                                Text(scope.displayName).tag(scope)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                    
                                    Divider()
                                }
                                
                                // File name
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("File Name")
                                        .font(.headline)
                                    
                                    TextField("Enter file name", text: $customFileName)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        
                        // Content options
                        GroupBox("Content Options") {
                            VStack(spacing: 12) {
                                Toggle("Include metadata", isOn: $exportOptions.includeMetadata)
                                Toggle("Include table of contents", isOn: $exportOptions.includeTableOfContents)
                                Toggle("Include word count", isOn: $exportOptions.includeWordCount)
                                Toggle("Include timestamps", isOn: $exportOptions.includeTimestamps)
                                
                                if document?.isHierarchical == true {
                                    Toggle("Flatten hierarchy", isOn: $exportOptions.flattenHierarchy)
                                        .help("Convert hierarchical structure to flat content")
                                }
                            }
                        }
                        
                        // Format-specific options
                        if exportOptions.format == .markdown {
                            GroupBox("Markdown Options") {
                                VStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Style")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Picker("Markdown Style", selection: $exportOptions.markdownStyle) {
                                            ForEach(ExportService.MarkdownStyle.allCases, id: \.self) { style in
                                                Text(style.displayName).tag(style)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                    }
                                }
                            }
                        }
                        
                        if exportOptions.format == .html {
                            GroupBox("HTML Options") {
                                VStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Template")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Picker("HTML Template", selection: $exportOptions.htmlTemplate) {
                                            ForEach(ExportService.HTMLTemplate.allCases, id: \.self) { template in
                                                Text(template.displayName).tag(template)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                    }
                                    
                                    Toggle("Include CSS styles", isOn: $exportOptions.includeCSS)
                                }
                            }
                        }
                        
                        // Custom metadata
                        GroupBox("Custom Metadata") {
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Custom Title")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    TextField("Leave empty to use original title", text: Binding(
                                        get: { exportOptions.customTitle ?? "" },
                                        set: { exportOptions.customTitle = $0.isEmpty ? nil : $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Author")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    TextField("Enter author name", text: Binding(
                                        get: { exportOptions.customAuthor ?? "" },
                                        set: { exportOptions.customAuthor = $0.isEmpty ? nil : $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                
                Divider()
                
                // Export actions
                VStack(spacing: 16) {
                    if exportService.isExporting {
                        VStack(spacing: 8) {
                            ProgressView(value: exportService.exportProgress)
                                .progressViewStyle(.linear)
                            
                            Text("Exporting...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Button("Preview") {
                            previewExport()
                        }
                        .buttonStyle(.bordered)
                        .disabled(exportService.isExporting || customFileName.isEmpty)
                        
                        Spacer()
                        
                        Button("Export & Save") {
                            exportAndSave()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(exportService.isExporting || customFileName.isEmpty)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
        .frame(minWidth: 600, minHeight: 700)
        .sheet(isPresented: $showingExportedContent) {
            ExportPreviewView(
                content: exportedContent,
                format: exportOptions.format,
                fileName: customFileName
            )
        }
        .alert("Export Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(exportService.lastError?.localizedDescription ?? "Unknown error occurred")
        }
    }
    
    private func previewExport() {
        Task {
            do {
                if let document = document {
                    exportedContent = try await exportService.exportDocument(document, options: exportOptions)
                } else if let project = project {
                    exportedContent = try await exportService.exportProject(project, options: exportOptions)
                }
                showingExportedContent = true
            } catch {
                showingError = true
            }
        }
    }
    
    private func exportAndSave() {
        Task {
            do {
                let content: String
                if let document = document {
                    content = try await exportService.exportDocument(document, options: exportOptions)
                } else if let project = project {
                    content = try await exportService.exportProject(project, options: exportOptions)
                } else {
                    return
                }
                
                await MainActor.run {
                    exportService.presentSavePanel(
                        for: content,
                        suggestedFileName: customFileName,
                        format: exportOptions.format
                    )
                    dismiss()
                }
            } catch {
                showingError = true
            }
        }
    }
}

struct FormatCard: View {
    let format: ExportService.ExportFormat
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image(systemName: formatIcon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(format.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(".\(format.fileExtension)")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.accentColor : Color(.controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var formatIcon: String {
        switch format {
        case .markdown: return "doc.text"
        case .html: return "safari"
        case .plainText: return "doc.plaintext"
        case .rtf: return "doc.richtext"
        }
    }
}

struct ExportPreviewView: View {
    let content: String
    let format: ExportService.ExportFormat
    let fileName: String
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Export Preview")
                            .font(.headline)
                        
                        Text("\(fileName).\(format.fileExtension)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.borderless)
                }
                .padding()
                
                Divider()
                
                // Content preview
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(content)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                }
                .background(Color(.textBackgroundColor))
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}

#Preview {
    let document = Document(title: "Sample Document", content: "# Sample Content\n\nThis is a sample document for export preview.")
    
    ExportView(document: document)
}