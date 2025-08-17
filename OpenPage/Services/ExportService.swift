import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// Service for exporting documents and projects to various formats
@MainActor
class ExportService: ObservableObject {
    static let shared = ExportService()
    
    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var lastError: ExportError?
    
    private init() {}
    
    // MARK: - Export Types
    enum ExportFormat: String, CaseIterable, Identifiable {
        case markdown = "markdown"
        case html = "html"
        case plainText = "txt"
        case rtf = "rtf"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .markdown: return "Markdown"
            case .html: return "HTML"
            case .plainText: return "Plain Text"
            case .rtf: return "Rich Text Format"
            }
        }
        
        var fileExtension: String {
            switch self {
            case .markdown: return "md"
            case .html: return "html"
            case .plainText: return "txt"
            case .rtf: return "rtf"
            }
        }
        
        var utType: UTType {
            switch self {
            case .markdown: return UTType.plainText
            case .html: return UTType.html
            case .plainText: return UTType.plainText
            case .rtf: return UTType.rtf
            }
        }
        
        var mimeType: String {
            switch self {
            case .markdown: return "text/markdown"
            case .html: return "text/html"
            case .plainText: return "text/plain"
            case .rtf: return "text/rtf"
            }
        }
    }
    
    enum ExportScope: String, CaseIterable {
        case document = "document"
        case project = "project"
        
        var displayName: String {
            switch self {
            case .document: return "Current Document"
            case .project: return "Entire Project"
            }
        }
    }
    
    // MARK: - Export Options
    struct ExportOptions {
        var format: ExportFormat = .markdown
        var scope: ExportScope = .document
        var includeMetadata: Bool = true
        var includeTableOfContents: Bool = false
        var flattenHierarchy: Bool = false
        var includeWordCount: Bool = false
        var includeTimestamps: Bool = false
        var customTitle: String?
        var customAuthor: String?
        
        // Markdown specific options
        var markdownStyle: MarkdownStyle = .standard
        var codeBlockLanguage: String = "text"
        
        // HTML specific options
        var htmlTemplate: HTMLTemplate = .clean
        var includeCSS: Bool = true
    }
    
    enum MarkdownStyle: String, CaseIterable {
        case standard = "standard"
        case github = "github"
        case academic = "academic"
        
        var displayName: String {
            switch self {
            case .standard: return "Standard Markdown"
            case .github: return "GitHub Flavored"
            case .academic: return "Academic Style"
            }
        }
    }
    
    enum HTMLTemplate: String, CaseIterable {
        case clean = "clean"
        case academic = "academic"
        case blog = "blog"
        
        var displayName: String {
            switch self {
            case .clean: return "Clean & Simple"
            case .academic: return "Academic Paper"
            case .blog: return "Blog Post"
            }
        }
    }
    
    // MARK: - Export Methods
    
    /// Export a single document
    func exportDocument(
        _ document: Document,
        options: ExportOptions = ExportOptions()
    ) async throws -> String {
        isExporting = true
        exportProgress = 0.0
        lastError = nil
        
        defer {
            isExporting = false
            exportProgress = 0.0
        }
        
        do {
            exportProgress = 0.2
            
            let content = try await generateContent(from: document, options: options)
            exportProgress = 0.8
            
            let formattedContent = try formatContent(content, format: options.format, options: options)
            exportProgress = 1.0
            
            return formattedContent
        } catch let error as ExportError {
            lastError = error
            throw error
        } catch {
            let exportError = ExportError.exportFailed("Unexpected error: \(error.localizedDescription)")
            lastError = exportError
            throw exportError
        }
    }
    
    /// Export an entire project
    func exportProject(
        _ project: Project,
        options: ExportOptions = ExportOptions()
    ) async throws -> String {
        isExporting = true
        exportProgress = 0.0
        lastError = nil
        
        defer {
            isExporting = false
            exportProgress = 0.0
        }
        
        do {
            exportProgress = 0.1
            
            var projectContent = ProjectContent(
                title: project.name,
                description: project.summary,
                documents: []
            )
            
            let totalDocuments = project.documents.count
            
            for (index, document) in project.documents.enumerated() {
                let documentContent = try await generateContent(from: document, options: options)
                projectContent.documents.append(documentContent)
                
                exportProgress = 0.1 + (0.7 * Double(index + 1) / Double(totalDocuments))
            }
            
            exportProgress = 0.8
            
            let formattedContent = try formatProjectContent(projectContent, format: options.format, options: options)
            exportProgress = 1.0
            
            return formattedContent
        } catch let error as ExportError {
            lastError = error
            throw error
        } catch {
            let exportError = ExportError.exportFailed("Unexpected error: \(error.localizedDescription)")
            lastError = exportError
            throw exportError
        }
    }
    
    /// Save exported content to file
    func saveToFile(
        content: String,
        fileName: String,
        format: ExportFormat
    ) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(fileName).\(format.fileExtension)"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    /// Present system save panel
    func presentSavePanel(
        for content: String,
        suggestedFileName: String,
        format: ExportFormat
    ) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [format.utType]
        savePanel.nameFieldStringValue = "\(suggestedFileName).\(format.fileExtension)"
        savePanel.title = "Export \(format.displayName)"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try content.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    self.lastError = ExportError.saveFailed("Failed to save file: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Content Generation
private extension ExportService {
    func generateContent(from document: Document, options: ExportOptions) async throws -> DocumentContent {
        let content: String
        
        if document.isHierarchical, let rootSection = document.rootSection {
            if options.flattenHierarchy {
                content = flattenHierarchicalContent(rootSection)
            } else {
                content = generateHierarchicalContent(rootSection, level: 0)
            }
        } else {
            content = document.content
        }
        
        return DocumentContent(
            title: document.title,
            content: content,
            wordCount: document.wordCount,
            createdAt: document.createdAt,
            updatedAt: document.updatedAt,
            isHierarchical: document.isHierarchical
        )
    }
    
    func generateHierarchicalContent(_ section: DocumentSection, level: Int) -> String {
        var result = ""
        
        // Add section title as header
        if level > 0 {
            let headerPrefix = String(repeating: "#", count: min(level, 6))
            result += "\(headerPrefix) \(section.title)\n\n"
        }
        
        // Add section content
        if !section.content.isEmpty {
            result += "\(section.content)\n\n"
        }
        
        // Add children
        if let children = section.children?.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            for child in children {
                result += generateHierarchicalContent(child, level: level + 1)
            }
        }
        
        return result
    }
    
    func flattenHierarchicalContent(_ section: DocumentSection) -> String {
        var result = ""
        
        // Add this section's content
        if !section.content.isEmpty {
            if !section.title.isEmpty && section.title != "root" {
                result += "**\(section.title)**\n\n"
            }
            result += "\(section.content)\n\n"
        }
        
        // Add children recursively
        if let children = section.children?.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            for child in children {
                result += flattenHierarchicalContent(child)
            }
        }
        
        return result
    }
}

// MARK: - Content Formatting
private extension ExportService {
    func formatContent(_ documentContent: DocumentContent, format: ExportFormat, options: ExportOptions) throws -> String {
        switch format {
        case .markdown:
            return try formatAsMarkdown(documentContent, options: options)
        case .html:
            return try formatAsHTML(documentContent, options: options)
        case .plainText:
            return formatAsPlainText(documentContent, options: options)
        case .rtf:
            return try formatAsRTF(documentContent, options: options)
        }
    }
    
    func formatProjectContent(_ projectContent: ProjectContent, format: ExportFormat, options: ExportOptions) throws -> String {
        switch format {
        case .markdown:
            return try formatProjectAsMarkdown(projectContent, options: options)
        case .html:
            return try formatProjectAsHTML(projectContent, options: options)
        case .plainText:
            return formatProjectAsPlainText(projectContent, options: options)
        case .rtf:
            return try formatProjectAsRTF(projectContent, options: options)
        }
    }
    
    // MARK: Markdown Formatting
    func formatAsMarkdown(_ content: DocumentContent, options: ExportOptions) throws -> String {
        var result = ""
        
        // Title
        if let customTitle = options.customTitle {
            result += "# \(customTitle)\n\n"
        } else {
            result += "# \(content.title)\n\n"
        }
        
        // Metadata
        if options.includeMetadata {
            result += "---\n"
            if let author = options.customAuthor {
                result += "author: \(author)\n"
            }
            if options.includeWordCount {
                result += "word_count: \(content.wordCount)\n"
            }
            if options.includeTimestamps {
                result += "created: \(formatDate(content.createdAt))\n"
                result += "updated: \(formatDate(content.updatedAt))\n"
            }
            result += "---\n\n"
        }
        
        // Content
        result += content.content
        
        return result
    }
    
    func formatProjectAsMarkdown(_ project: ProjectContent, options: ExportOptions) throws -> String {
        var result = ""
        
        // Project title
        if let customTitle = options.customTitle {
            result += "# \(customTitle)\n\n"
        } else {
            result += "# \(project.title)\n\n"
        }
        
        // Project description
        if !project.description.isEmpty {
            result += "\(project.description)\n\n"
        }
        
        // Table of contents
        if options.includeTableOfContents {
            result += "## Table of Contents\n\n"
            for document in project.documents {
                result += "- [\(document.title)](#\(document.title.lowercased().replacingOccurrences(of: " ", with: "-")))\n"
            }
            result += "\n"
        }
        
        // Documents
        for document in project.documents {
            result += "## \(document.title)\n\n"
            result += document.content
            result += "\n\n---\n\n"
        }
        
        return result
    }
    
    // MARK: HTML Formatting
    func formatAsHTML(_ content: DocumentContent, options: ExportOptions) throws -> String {
        var html = ""
        
        // HTML boilerplate
        html += "<!DOCTYPE html>\n"
        html += "<html lang=\"en\">\n"
        html += "<head>\n"
        html += "    <meta charset=\"UTF-8\">\n"
        html += "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
        html += "    <title>\(content.title)</title>\n"
        
        if options.includeCSS {
            html += getCSS(for: options.htmlTemplate)
        }
        
        html += "</head>\n"
        html += "<body>\n"
        
        // Content
        html += "    <article>\n"
        html += "        <h1>\(content.title)</h1>\n"
        
        // Convert markdown-like content to HTML
        let htmlContent = convertMarkdownToHTML(content.content)
        html += htmlContent
        
        html += "    </article>\n"
        html += "</body>\n"
        html += "</html>\n"
        
        return html
    }
    
    func formatProjectAsHTML(_ project: ProjectContent, options: ExportOptions) throws -> String {
        // Similar to single document but with multiple sections
        // Implementation would be similar to markdown version but with HTML tags
        return try formatAsHTML(
            DocumentContent(
                title: project.title,
                content: project.documents.map { $0.content }.joined(separator: "\n\n---\n\n"),
                wordCount: project.documents.reduce(0) { $0 + $1.wordCount },
                createdAt: Date(),
                updatedAt: Date(),
                isHierarchical: false
            ),
            options: options
        )
    }
    
    // MARK: Plain Text Formatting
    func formatAsPlainText(_ content: DocumentContent, options: ExportOptions) -> String {
        var result = ""
        
        // Title
        result += "\(content.title)\n"
        result += String(repeating: "=", count: content.title.count) + "\n\n"
        
        // Metadata
        if options.includeMetadata {
            if let author = options.customAuthor {
                result += "Author: \(author)\n"
            }
            if options.includeWordCount {
                result += "Word Count: \(content.wordCount)\n"
            }
            result += "\n"
        }
        
        // Content (strip markdown formatting)
        result += stripMarkdownFormatting(content.content)
        
        return result
    }
    
    func formatProjectAsPlainText(_ project: ProjectContent, options: ExportOptions) -> String {
        var result = ""
        
        // Project header
        result += "\(project.title)\n"
        result += String(repeating: "=", count: project.title.count) + "\n\n"
        
        if !project.description.isEmpty {
            result += "\(project.description)\n\n"
        }
        
        // Documents
        for document in project.documents {
            result += "\(document.title)\n"
            result += String(repeating: "-", count: document.title.count) + "\n\n"
            result += stripMarkdownFormatting(document.content)
            result += "\n\n"
        }
        
        return result
    }
    
    // MARK: RTF Formatting
    func formatAsRTF(_ content: DocumentContent, options: ExportOptions) throws -> String {
        // Basic RTF implementation
        var rtf = "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}\\f0\\fs24 "
        
        // Title
        rtf += "\\b\\fs32 \(content.title)\\b0\\fs24\\par\\par "
        
        // Content
        rtf += content.content.replacingOccurrences(of: "\n", with: "\\par ")
        
        rtf += "}"
        
        return rtf
    }
    
    func formatProjectAsRTF(_ project: ProjectContent, options: ExportOptions) throws -> String {
        // Similar RTF implementation for projects
        return try formatAsRTF(
            DocumentContent(
                title: project.title,
                content: project.documents.map { $0.content }.joined(separator: "\n\n"),
                wordCount: project.documents.reduce(0) { $0 + $1.wordCount },
                createdAt: Date(),
                updatedAt: Date(),
                isHierarchical: false
            ),
            options: options
        )
    }
    
    // MARK: Helper Methods
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func convertMarkdownToHTML(_ markdown: String) -> String {
        // Basic markdown to HTML conversion
        var html = markdown
        
        // Headers
        html = html.replacingOccurrences(of: "### ", with: "<h3>")
        html = html.replacingOccurrences(of: "## ", with: "<h2>")
        html = html.replacingOccurrences(of: "# ", with: "<h1>")
        
        // Paragraphs
        html = html.replacingOccurrences(of: "\n\n", with: "</p>\n<p>")
        html = "<p>" + html + "</p>"
        
        // Line breaks
        html = html.replacingOccurrences(of: "\n", with: "<br>")
        
        return html
    }
    
    func stripMarkdownFormatting(_ text: String) -> String {
        var plain = text
        
        // Remove headers
        plain = plain.replacingOccurrences(of: #"^#{1,6}\s+"#, with: "", options: .regularExpression)
        
        // Remove bold/italic
        plain = plain.replacingOccurrences(of: #"\*\*(.*?)\*\*"#, with: "$1", options: .regularExpression)
        plain = plain.replacingOccurrences(of: #"\*(.*?)\*"#, with: "$1", options: .regularExpression)
        
        // Remove links
        plain = plain.replacingOccurrences(of: #"\[([^\]]+)\]\([^\)]+\)"#, with: "$1", options: .regularExpression)
        
        return plain
    }
    
    func getCSS(for template: HTMLTemplate) -> String {
        switch template {
        case .clean:
            return """
                <style>
                    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 2rem; }
                    h1, h2, h3 { color: #333; }
                    article { background: white; }
                </style>
                """
        case .academic:
            return """
                <style>
                    body { font-family: 'Times New Roman', serif; line-height: 2; max-width: 700px; margin: 0 auto; padding: 2rem; }
                    h1 { text-align: center; }
                    p { text-indent: 2em; margin: 0; }
                </style>
                """
        case .blog:
            return """
                <style>
                    body { font-family: Georgia, serif; line-height: 1.8; max-width: 650px; margin: 0 auto; padding: 2rem; color: #444; }
                    h1, h2, h3 { color: #2c3e50; }
                    blockquote { border-left: 4px solid #3498db; padding-left: 1rem; font-style: italic; }
                </style>
                """
        }
    }
}

// MARK: - Data Models
struct DocumentContent {
    let title: String
    let content: String
    let wordCount: Int
    let createdAt: Date
    let updatedAt: Date
    let isHierarchical: Bool
}

struct ProjectContent {
    let title: String
    let description: String
    var documents: [DocumentContent]
    
    init(title: String, description: String, documents: [DocumentContent]) {
        self.title = title
        self.description = description
        self.documents = documents
    }
}

// MARK: - Error Types
enum ExportError: LocalizedError {
    case invalidFormat
    case exportFailed(String)
    case saveFailed(String)
    case unsupportedContent
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Invalid export format selected"
        case .exportFailed(let message):
            return "Export failed: \(message)"
        case .saveFailed(let message):
            return "Save failed: \(message)"
        case .unsupportedContent:
            return "Content type not supported for this export format"
        }
    }
}