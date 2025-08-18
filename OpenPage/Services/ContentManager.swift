import Foundation
import AppKit
import SwiftUI

/// Manages content state and conversion between markdown and rich text display modes
/// Maintains markdown as the source of truth while providing seamless mode switching
class ContentManager: ObservableObject {
    static let shared = ContentManager()
    
    // MARK: - Published Properties
    
    @Published private(set) var displayMode: DisplayMode = .richText
    @Published private(set) var currentContent: String = ""
    
    // MARK: - Private Properties
    
    private var markdownContent: String = "" // Source of truth
    private var richTextContent: NSAttributedString = NSAttributedString()
    private weak var activeTextView: NSTextView?
    private var updateCallback: ((String) -> Void)?
    
    // MARK: - Content Display Modes
    
    enum DisplayMode: String, CaseIterable {
        case richText = "richText"     // Visual formatting (markdown OFF)
        case markdown = "markdown"     // Syntax highlighting (markdown ON)
        
        var displayName: String {
            switch self {
            case .richText: return "Rich Text"
            case .markdown: return "Markdown"
            }
        }
    }
    
    private init() {}
    
    // MARK: - Registration & Setup
    
    func registerTextView(_ textView: NSTextView, updateCallback: @escaping (String) -> Void) {
        print("DEBUG: ContentManager registering textView")
        self.activeTextView = textView
        self.updateCallback = updateCallback
    }
    
    func unregisterTextView(_ textView: NSTextView) {
        if self.activeTextView === textView {
            self.activeTextView = nil
            self.updateCallback = nil
        }
    }
    
    // MARK: - Content Management
    
    /// Set the initial content (should be markdown)
    func setContent(_ content: String, theme: EditorTheme, fontSize: Double, lineHeight: Double) {
        self.markdownContent = content
        self.currentContent = content
        
        // Convert to rich text for rich text mode
        self.richTextContent = MarkdownRenderer.shared.markdownToRichText(
            content, 
            theme: theme, 
            fontSize: fontSize, 
            lineHeight: lineHeight
        )
        
        print("DEBUG: ContentManager setContent - markdown: '\(content)'")
        updateDisplay(theme: theme, fontSize: fontSize, lineHeight: lineHeight)
    }
    
    /// Update content from text input (handles both modes)
    func updateContent(_ newContent: String, theme: EditorTheme, fontSize: Double, lineHeight: Double) {
        print("DEBUG: ContentManager updateContent called with mode: \(displayMode)")
        
        switch displayMode {
        case .richText:
            // In rich text mode, we need to convert changes back to markdown
            // For now, we'll use a simplified approach
            markdownContent = newContent
            currentContent = newContent
            
        case .markdown:
            // In markdown mode, update is straightforward
            markdownContent = newContent
            currentContent = newContent
        }
        
        // Notify parent of content change
        updateCallback?(markdownContent)
    }
    
    // MARK: - Display Mode Switching
    
    /// Toggle between rich text and markdown display modes
    func toggleDisplayMode(theme: EditorTheme, fontSize: Double, lineHeight: Double) {
        let newMode: DisplayMode = displayMode == .richText ? .markdown : .richText
        setDisplayMode(newMode, theme: theme, fontSize: fontSize, lineHeight: lineHeight)
    }
    
    /// Set specific display mode
    func setDisplayMode(_ mode: DisplayMode, theme: EditorTheme, fontSize: Double, lineHeight: Double) {
        print("DEBUG: ContentManager switching from \(displayMode) to \(mode)")
        
        // Save current content before switching
        saveCurrentContent()
        
        displayMode = mode
        updateDisplay(theme: theme, fontSize: fontSize, lineHeight: lineHeight)
        
        // Store user preference
        UserDefaults.standard.set(mode.rawValue, forKey: "ContentDisplayMode")
    }
    
    private func saveCurrentContent() {
        guard let textView = activeTextView else { return }
        
        switch displayMode {
        case .richText:
            // Convert rich text back to markdown (simplified)
            markdownContent = textView.string
            
        case .markdown:
            // Direct markdown update
            markdownContent = textView.string
        }
        
        currentContent = textView.string
    }
    
    private func updateDisplay(theme: EditorTheme, fontSize: Double, lineHeight: Double) {
        guard let textView = activeTextView else { return }
        
        print("DEBUG: ContentManager updateDisplay - mode: \(displayMode)")
        
        switch displayMode {
        case .richText:
            // Convert markdown to rich text and display
            let richText = MarkdownRenderer.shared.markdownToRichText(
                markdownContent,
                theme: theme,
                fontSize: fontSize,
                lineHeight: lineHeight
            )
            
            // Update text view with rich text
            textView.textStorage?.setAttributedString(richText)
            currentContent = richText.string
            
        case .markdown:
            // Display raw markdown with syntax highlighting
            let attributedString = NSMutableAttributedString(string: markdownContent)
            MarkdownRenderer.shared.applySyntaxHighlighting(
                to: attributedString,
                theme: theme,
                fontSize: fontSize
            )
            
            // Update text view with highlighted markdown
            textView.textStorage?.setAttributedString(attributedString)
            currentContent = markdownContent
        }
        
        // Force display update
        textView.needsDisplay = true
        
        print("DEBUG: ContentManager updated display - content length: \(currentContent.count)")
    }
    
    // MARK: - Formatting Integration
    
    /// Apply formatting in the current display mode
    func applyFormatting(_ action: FormattingAction, theme: EditorTheme, fontSize: Double, lineHeight: Double) {
        guard let textView = activeTextView else { return }
        
        print("DEBUG: ContentManager applyFormatting - mode: \(displayMode), action: \(action)")
        
        switch displayMode {
        case .richText:
            // Apply visual formatting and convert to markdown
            applyRichTextFormatting(action, textView: textView, theme: theme, fontSize: fontSize, lineHeight: lineHeight)
            
        case .markdown:
            // Insert markdown syntax directly
            FormattingService.shared.applyFormatting(action)
        }
        
        // Update content after formatting
        updateContent(textView.string, theme: theme, fontSize: fontSize, lineHeight: lineHeight)
    }
    
    private func applyRichTextFormatting(_ action: FormattingAction, textView: NSTextView, theme: EditorTheme, fontSize: Double, lineHeight: Double) {
        let selectedRange = textView.selectedRange()
        let text = textView.string as NSString
        
        // For rich text mode, we need to:
        // 1. Apply visual formatting to the text view
        // 2. Update the underlying markdown
        
        switch action {
        case .bold:
            applyRichTextBold(textView: textView, selectedRange: selectedRange, fontSize: fontSize)
        case .italic:
            applyRichTextItalic(textView: textView, selectedRange: selectedRange, fontSize: fontSize)
        case .strikethrough:
            applyRichTextStrikethrough(textView: textView, selectedRange: selectedRange)
        case .code:
            applyRichTextCode(textView: textView, selectedRange: selectedRange, theme: theme, fontSize: fontSize)
        case .link:
            applyRichTextLink(textView: textView, selectedRange: selectedRange, theme: theme)
        case .header1, .header2, .header3:
            applyRichTextHeader(action: action, textView: textView, selectedRange: selectedRange, theme: theme, fontSize: fontSize)
        case .bulletList, .numberedList:
            applyRichTextList(action: action, textView: textView, selectedRange: selectedRange, theme: theme)
        case .quote:
            applyRichTextQuote(textView: textView, selectedRange: selectedRange, theme: theme)
        }
    }
    
    private func applyRichTextBold(textView: NSTextView, selectedRange: NSRange, fontSize: Double) {
        let boldFont = NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .bold)
        
        if selectedRange.length > 0 {
            // Apply bold to selection
            textView.textStorage?.addAttribute(.font, value: boldFont, range: selectedRange)
        } else {
            // Set typing attributes for new text
            var typingAttributes = textView.typingAttributes
            typingAttributes[.font] = boldFont
            textView.typingAttributes = typingAttributes
        }
    }
    
    private func applyRichTextItalic(textView: NSTextView, selectedRange: NSRange, fontSize: Double) {
        let italicFont = NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular).withTraits(.italic)
        
        if selectedRange.length > 0 {
            textView.textStorage?.addAttribute(.font, value: italicFont, range: selectedRange)
        } else {
            var typingAttributes = textView.typingAttributes
            typingAttributes[.font] = italicFont
            textView.typingAttributes = typingAttributes
        }
    }
    
    private func applyRichTextStrikethrough(textView: NSTextView, selectedRange: NSRange) {
        if selectedRange.length > 0 {
            textView.textStorage?.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: selectedRange)
        } else {
            var typingAttributes = textView.typingAttributes
            typingAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            textView.typingAttributes = typingAttributes
        }
    }
    
    private func applyRichTextCode(textView: NSTextView, selectedRange: NSRange, theme: EditorTheme, fontSize: Double) {
        let codeFont = NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize - 1), weight: .regular)
        let backgroundColor = NSColor(theme.accentColor.opacity(0.1))
        
        if selectedRange.length > 0 {
            textView.textStorage?.addAttribute(.font, value: codeFont, range: selectedRange)
            textView.textStorage?.addAttribute(.backgroundColor, value: backgroundColor, range: selectedRange)
        } else {
            var typingAttributes = textView.typingAttributes
            typingAttributes[.font] = codeFont
            typingAttributes[.backgroundColor] = backgroundColor
            textView.typingAttributes = typingAttributes
        }
    }
    
    private func applyRichTextLink(textView: NSTextView, selectedRange: NSRange, theme: EditorTheme) {
        if selectedRange.length > 0 {
            textView.textStorage?.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: selectedRange)
            textView.textStorage?.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: selectedRange)
        }
    }
    
    private func applyRichTextHeader(action: FormattingAction, textView: NSTextView, selectedRange: NSRange, theme: EditorTheme, fontSize: Double) {
        let headerLevel: Int
        switch action {
        case .header1: headerLevel = 1
        case .header2: headerLevel = 2
        case .header3: headerLevel = 3
        default: headerLevel = 1
        }
        
        let headerFontSize = CGFloat(fontSize) + CGFloat(18 - (headerLevel * 2))
        let headerFont = NSFont.systemFont(ofSize: headerFontSize, weight: .bold)
        
        // Find the line range
        let text = textView.string as NSString
        let lineRange = text.lineRange(for: selectedRange)
        
        textView.textStorage?.addAttribute(.font, value: headerFont, range: lineRange)
        textView.textStorage?.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: lineRange)
    }
    
    private func applyRichTextList(action: FormattingAction, textView: NSTextView, selectedRange: NSRange, theme: EditorTheme) {
        // Find the line and add list formatting
        let text = textView.string as NSString
        let lineRange = text.lineRange(for: selectedRange)
        let currentLine = text.substring(with: lineRange)
        
        let listPrefix = action == .bulletList ? "• " : "1. "
        let newLine = listPrefix + currentLine.trimmingCharacters(in: .whitespacesAndNewlines)
        
        textView.replaceCharacters(in: lineRange, with: newLine)
        
        // Apply list styling
        let newRange = NSRange(location: lineRange.location, length: 2)
        textView.textStorage?.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: newRange)
    }
    
    private func applyRichTextQuote(textView: NSTextView, selectedRange: NSRange, theme: EditorTheme) {
        let text = textView.string as NSString
        let lineRange = text.lineRange(for: selectedRange)
        let currentLine = text.substring(with: lineRange)
        
        let quoteLine = "❝ " + currentLine.trimmingCharacters(in: .whitespacesAndNewlines)
        textView.replaceCharacters(in: lineRange, with: quoteLine)
        
        // Apply quote styling
        let newRange = NSRange(location: lineRange.location, length: quoteLine.count)
        textView.textStorage?.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: newRange)
    }
    
    // MARK: - User Preferences
    
    /// Load user's preferred display mode
    func loadUserPreferences() {
        let savedMode = UserDefaults.standard.string(forKey: "ContentDisplayMode") ?? DisplayMode.richText.rawValue
        if let mode = DisplayMode(rawValue: savedMode) {
            displayMode = mode
        }
    }
    
    // MARK: - Content Validation & Utilities
    
    /// Get the current markdown content (source of truth)
    func getMarkdownContent() -> String {
        return markdownContent
    }
    
    /// Get the current display content
    func getDisplayContent() -> String {
        return currentContent
    }
    
    /// Check if content has unsaved changes
    func hasUnsavedChanges(comparedTo savedContent: String) -> Bool {
        return markdownContent != savedContent
    }
}