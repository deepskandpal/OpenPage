import Foundation
import AppKit
import SwiftUI

/// Service for converting between markdown text and rich text (NSAttributedString)
/// Supports bidirectional conversion for dual-mode text editing
class MarkdownRenderer: ObservableObject {
    static let shared = MarkdownRenderer()
    
    private init() {}
    
    // MARK: - Markdown to Rich Text Conversion
    
    /// Convert markdown string to NSAttributedString for rich text display
    func markdownToRichText(_ markdown: String, theme: EditorTheme, fontSize: Double, lineHeight: Double) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: markdown)
        
        // Base text attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = CGFloat(lineHeight)
        paragraphStyle.lineSpacing = 4
        
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // Apply base attributes
        attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: attributedString.length))
        
        // Apply markdown formatting
        applyRichTextFormatting(to: attributedString, theme: theme, fontSize: fontSize)
        
        return attributedString
    }
    
    private func applyRichTextFormatting(to attributedString: NSMutableAttributedString, theme: EditorTheme, fontSize: Double) {
        let text = attributedString.string
        let range = NSRange(location: 0, length: text.count)
        
        // Headers - make them larger and bold, hide markdown syntax
        applyHeaderFormatting(to: attributedString, theme: theme, fontSize: fontSize)
        
        // Bold text - make it bold, hide ** syntax
        applyBoldFormatting(to: attributedString, fontSize: fontSize)
        
        // Italic text - make it italic, hide * syntax
        applyItalicFormatting(to: attributedString, fontSize: fontSize)
        
        // Code - monospace font, hide ` syntax
        applyCodeFormatting(to: attributedString, theme: theme, fontSize: fontSize)
        
        // Strikethrough - add strikethrough, hide ~~ syntax
        applyStrikethroughFormatting(to: attributedString)
        
        // Links - blue color, hide markdown syntax
        applyLinkFormatting(to: attributedString, theme: theme)
        
        // Lists - proper indentation, hide markdown syntax
        applyListFormatting(to: attributedString)
        
        // Quotes - styled, hide > syntax
        applyQuoteFormatting(to: attributedString, theme: theme)
    }
    
    private func applyHeaderFormatting(to attributedString: NSMutableAttributedString, theme: EditorTheme, fontSize: Double) {
        let text = attributedString.string
        let range = NSRange(location: 0, length: text.count)
        
        let headerRegex = try! NSRegularExpression(pattern: "^(#{1,6})\\s(.+)$", options: [.anchorsMatchLines])
        
        // Process matches in reverse order to avoid range issues
        let matches = headerRegex.matches(in: text, options: [], range: range).reversed()
        
        for match in matches {
            let headerLevel = match.range(at: 1).length
            let textRange = match.range(at: 2)
            let fullRange = match.range
            
            // Calculate header font size
            let headerFontSize = CGFloat(fontSize) + CGFloat(18 - (headerLevel * 2))
            let headerFont = NSFont.systemFont(ofSize: headerFontSize, weight: .bold)
            
            // Get the header text without markdown syntax
            let headerText = (text as NSString).substring(with: textRange)
            
            // Replace the entire line with just the header text
            attributedString.replaceCharacters(in: fullRange, with: headerText)
            
            // Apply header formatting to the replaced text
            let newRange = NSRange(location: fullRange.location, length: headerText.count)
            attributedString.addAttribute(.font, value: headerFont, range: newRange)
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: newRange)
        }
    }
    
    private func applyBoldFormatting(to attributedString: NSMutableAttributedString, fontSize: Double) {
        let text = attributedString.string
        let boldRegex = try! NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*", options: [])
        
        // Process matches in reverse order
        let matches = boldRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)).reversed()
        
        for match in matches {
            let contentRange = match.range(at: 1)
            let fullRange = match.range
            
            let boldText = (attributedString.string as NSString).substring(with: contentRange)
            let boldFont = NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .bold)
            
            // Replace markdown with plain text
            attributedString.replaceCharacters(in: fullRange, with: boldText)
            
            // Apply bold formatting
            let newRange = NSRange(location: fullRange.location, length: boldText.count)
            attributedString.addAttribute(.font, value: boldFont, range: newRange)
        }
    }
    
    private func applyItalicFormatting(to attributedString: NSMutableAttributedString, fontSize: Double) {
        let text = attributedString.string
        let italicRegex = try! NSRegularExpression(pattern: "(?<!\\*)\\*([^*]+?)\\*(?!\\*)", options: [])
        
        let matches = italicRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)).reversed()
        
        for match in matches {
            let contentRange = match.range(at: 1)
            let fullRange = match.range
            
            let italicText = (attributedString.string as NSString).substring(with: contentRange)
            let italicFont = NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular).withTraits(.italic)
            
            // Replace markdown with plain text
            attributedString.replaceCharacters(in: fullRange, with: italicText)
            
            // Apply italic formatting
            let newRange = NSRange(location: fullRange.location, length: italicText.count)
            attributedString.addAttribute(.font, value: italicFont, range: newRange)
        }
    }
    
    private func applyCodeFormatting(to attributedString: NSMutableAttributedString, theme: EditorTheme, fontSize: Double) {
        let text = attributedString.string
        let codeRegex = try! NSRegularExpression(pattern: "`(.+?)`", options: [])
        
        let matches = codeRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)).reversed()
        
        for match in matches {
            let contentRange = match.range(at: 1)
            let fullRange = match.range
            
            let codeText = (attributedString.string as NSString).substring(with: contentRange)
            let codeFont = NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize - 1), weight: .regular)
            
            // Replace markdown with plain text
            attributedString.replaceCharacters(in: fullRange, with: codeText)
            
            // Apply code formatting
            let newRange = NSRange(location: fullRange.location, length: codeText.count)
            attributedString.addAttribute(.font, value: codeFont, range: newRange)
            attributedString.addAttribute(.backgroundColor, value: NSColor(theme.accentColor.opacity(0.1)), range: newRange)
        }
    }
    
    private func applyStrikethroughFormatting(to attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        let strikeRegex = try! NSRegularExpression(pattern: "~~(.+?)~~", options: [])
        
        let matches = strikeRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)).reversed()
        
        for match in matches {
            let contentRange = match.range(at: 1)
            let fullRange = match.range
            
            let strikeText = (attributedString.string as NSString).substring(with: contentRange)
            
            // Replace markdown with plain text
            attributedString.replaceCharacters(in: fullRange, with: strikeText)
            
            // Apply strikethrough formatting
            let newRange = NSRange(location: fullRange.location, length: strikeText.count)
            attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: newRange)
        }
    }
    
    private func applyLinkFormatting(to attributedString: NSMutableAttributedString, theme: EditorTheme) {
        let text = attributedString.string
        let linkRegex = try! NSRegularExpression(pattern: "\\[(.+?)\\]\\((.+?)\\)", options: [])
        
        let matches = linkRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)).reversed()
        
        for match in matches {
            let textRange = match.range(at: 1)
            let urlRange = match.range(at: 2)
            let fullRange = match.range
            
            let linkText = (attributedString.string as NSString).substring(with: textRange)
            let linkURL = (attributedString.string as NSString).substring(with: urlRange)
            
            // Replace markdown with just the link text
            attributedString.replaceCharacters(in: fullRange, with: linkText)
            
            // Apply link formatting
            let newRange = NSRange(location: fullRange.location, length: linkText.count)
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: newRange)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: newRange)
            
            if let url = URL(string: linkURL) {
                attributedString.addAttribute(.link, value: url, range: newRange)
            }
        }
    }
    
    private func applyListFormatting(to attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        let lines = text.components(separatedBy: .newlines)
        var currentOffset = 0
        
        for line in lines {
            let lineLength = line.count
            let lineRange = NSRange(location: currentOffset, length: lineLength)
            
            // Bullet lists
            if let bulletMatch = line.range(of: #"^[\s]*[-*+]\s"#, options: .regularExpression) {
                let prefixLength = bulletMatch.upperBound.utf16Offset(in: line)
                let bulletText = String(line[bulletMatch.upperBound...])
                
                attributedString.replaceCharacters(in: NSRange(location: currentOffset, length: lineLength), with: "• " + bulletText)
            }
            
            // Numbered lists  
            else if let numberMatch = line.range(of: #"^[\s]*\d+\.\s"#, options: .regularExpression) {
                let prefixLength = numberMatch.upperBound.utf16Offset(in: line)
                let numberText = String(line[line.startIndex..<numberMatch.upperBound])
                let listText = String(line[numberMatch.upperBound...])
                
                // Extract just the number
                if let numberPart = numberText.range(of: #"\d+"#, options: .regularExpression) {
                    let number = String(numberText[numberPart])
                    attributedString.replaceCharacters(in: NSRange(location: currentOffset, length: lineLength), with: number + ". " + listText)
                }
            }
            
            currentOffset += attributedString.string.components(separatedBy: .newlines)[lines.firstIndex(of: line) ?? 0].count + 1
        }
    }
    
    private func applyQuoteFormatting(to attributedString: NSMutableAttributedString, theme: EditorTheme) {
        let text = attributedString.string
        let quoteRegex = try! NSRegularExpression(pattern: "^>\\s(.+)$", options: [.anchorsMatchLines])
        
        let matches = quoteRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)).reversed()
        
        for match in matches {
            let contentRange = match.range(at: 1)
            let fullRange = match.range
            
            let quoteText = (attributedString.string as NSString).substring(with: contentRange)
            
            // Replace with styled quote
            attributedString.replaceCharacters(in: fullRange, with: "❝ " + quoteText)
            
            // Apply quote styling
            let newRange = NSRange(location: fullRange.location, length: quoteText.count + 2)
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: newRange)
        }
    }
    
    // MARK: - Rich Text to Markdown Conversion
    
    /// Convert NSAttributedString back to markdown syntax
    func richTextToMarkdown(_ attributedString: NSAttributedString) -> String {
        // This is a simplified reverse conversion
        // In a full implementation, you'd track the original markdown structure
        // For now, we'll use a basic approach that converts common formatting back
        
        var markdown = attributedString.string
        let length = attributedString.length
        var offset = 0
        
        // This is a placeholder - full implementation would need to:
        // 1. Track original markdown positions during rich text conversion
        // 2. Maintain a mapping of rich text ranges to markdown syntax
        // 3. Reconstruct markdown from attributed string properties
        
        return markdown
    }
    
    // MARK: - Syntax Highlighting (for markdown mode)
    
    /// Apply syntax highlighting to markdown text (when markdown mode is ON)
    func applySyntaxHighlighting(to attributedString: NSMutableAttributedString, theme: EditorTheme, fontSize: Double) {
        let text = attributedString.string
        let range = NSRange(location: 0, length: text.count)
        
        // Base text attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.6
        paragraphStyle.lineSpacing = 4
        
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // Apply base attributes
        attributedString.addAttributes(baseAttributes, range: range)
        
        // Highlight markdown syntax
        highlightHeaders(in: attributedString, theme: theme, fontSize: fontSize)
        highlightBold(in: attributedString, theme: theme)
        highlightItalic(in: attributedString, theme: theme)
        highlightCode(in: attributedString, theme: theme, fontSize: fontSize)
        highlightLinks(in: attributedString, theme: theme)
        highlightLists(in: attributedString, theme: theme)
        highlightQuotes(in: attributedString, theme: theme)
    }
    
    private func highlightHeaders(in attributedString: NSMutableAttributedString, theme: EditorTheme, fontSize: Double) {
        let text = attributedString.string
        let headerRegex = try! NSRegularExpression(pattern: "^(#{1,6})\\s(.+)$", options: [.anchorsMatchLines])
        
        headerRegex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { match, _, _ in
            guard let match = match else { return }
            
            let headerLevel = match.range(at: 1).length
            let headerFontSize = CGFloat(fontSize) + CGFloat(6 - headerLevel)
            let headerFont = NSFont.systemFont(ofSize: headerFontSize, weight: .bold)
            
            // Highlight the # symbols
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.accentColor.opacity(0.7)), range: match.range(at: 1))
            
            // Style the header text
            attributedString.addAttribute(.font, value: headerFont, range: match.range(at: 2))
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: match.range(at: 2))
        }
    }
    
    private func highlightBold(in attributedString: NSMutableAttributedString, theme: EditorTheme) {
        let text = attributedString.string
        let boldRegex = try! NSRegularExpression(pattern: "(\\*\\*)(.+?)(\\*\\*)", options: [])
        
        boldRegex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { match, _, _ in
            guard let match = match else { return }
            
            // Highlight the ** markers
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 1))
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 3))
            
            // Bold the content
            attributedString.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 16), range: match.range(at: 2))
        }
    }
    
    private func highlightItalic(in attributedString: NSMutableAttributedString, theme: EditorTheme) {
        let text = attributedString.string
        let italicRegex = try! NSRegularExpression(pattern: "(?<!\\*)(\\*)([^*]+?)(\\*)(?!\\*)", options: [])
        
        italicRegex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { match, _, _ in
            guard let match = match else { return }
            
            // Highlight the * markers
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 1))
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 3))
            
            // Italicize the content
            let italicFont = NSFont.systemFont(ofSize: 16, weight: .regular).withTraits(.italic)
            attributedString.addAttribute(.font, value: italicFont, range: match.range(at: 2))
        }
    }
    
    private func highlightCode(in attributedString: NSMutableAttributedString, theme: EditorTheme, fontSize: Double) {
        let text = attributedString.string
        let codeRegex = try! NSRegularExpression(pattern: "(`)(.*?)(`)", options: [])
        
        codeRegex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { match, _, _ in
            guard let match = match else { return }
            
            // Highlight the ` markers
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 1))
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 3))
            
            // Style the code content
            let codeFont = NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize - 1), weight: .regular)
            attributedString.addAttribute(.font, value: codeFont, range: match.range(at: 2))
            attributedString.addAttribute(.backgroundColor, value: NSColor(theme.accentColor.opacity(0.1)), range: match.range)
        }
    }
    
    private func highlightLinks(in attributedString: NSMutableAttributedString, theme: EditorTheme) {
        let text = attributedString.string
        let linkRegex = try! NSRegularExpression(pattern: "(\\[)(.+?)(\\])(\\()(.+?)(\\))", options: [])
        
        linkRegex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { match, _, _ in
            guard let match = match else { return }
            
            // Highlight markdown syntax
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 1)) // [
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 3)) // ]
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 4)) // (
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 6)) // )
            
            // Highlight link text and URL
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: match.range(at: 2)) // link text
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: match.range(at: 5)) // URL
        }
    }
    
    private func highlightLists(in attributedString: NSMutableAttributedString, theme: EditorTheme) {
        let text = attributedString.string
        let listRegex = try! NSRegularExpression(pattern: "^(\\s*)([-*+]|\\d+\\.)\\s", options: [.anchorsMatchLines])
        
        listRegex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { match, _, _ in
            guard let match = match else { return }
            
            // Highlight list markers
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: match.range)
        }
    }
    
    private func highlightQuotes(in attributedString: NSMutableAttributedString, theme: EditorTheme) {
        let text = attributedString.string
        let quoteRegex = try! NSRegularExpression(pattern: "^(>)\\s(.+)$", options: [.anchorsMatchLines])
        
        quoteRegex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { match, _, _ in
            guard let match = match else { return }
            
            // Highlight > symbol
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: match.range(at: 1))
            
            // Style quote content
            attributedString.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range(at: 2))
        }
    }
}

// MARK: - NSFont Extension is already defined in ModernTextEditor.swift