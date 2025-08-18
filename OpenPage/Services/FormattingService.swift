import Foundation
import AppKit
import SwiftUI

/// Singleton service to handle text formatting operations
class FormattingService: ObservableObject {
    static let shared = FormattingService()
    
    private weak var activeTextView: NSTextView?
    private var updateContentCallback: ((String) -> Void)?
    
    private init() {}
    
    // MARK: - Registration
    
    func registerTextView(_ textView: NSTextView, updateContentCallback: @escaping (String) -> Void) {
        print("DEBUG: FormattingService registering textView: \(textView)")
        self.activeTextView = textView
        self.updateContentCallback = updateContentCallback
    }
    
    func unregisterTextView(_ textView: NSTextView) {
        if self.activeTextView === textView {
            self.activeTextView = nil
            self.updateContentCallback = nil
        }
    }
    
    // MARK: - Formatting Actions
    
    func applyFormatting(_ action: FormattingAction) {
        print("DEBUG: FormattingService.applyFormatting called with: \(action)")
        guard let textView = activeTextView else {
            print("DEBUG: No active textView registered!")
            return
        }
        print("DEBUG: Active textView found, applying formatting")
        
        switch action {
        case .bold:
            insertMarkdownFormatting("**", "**", in: textView)
        case .italic:
            insertMarkdownFormatting("*", "*", in: textView)
        case .strikethrough:
            insertMarkdownFormatting("~~", "~~", in: textView)
        case .code:
            insertMarkdownFormatting("`", "`", in: textView)
        case .link:
            insertMarkdownFormatting("[", "](url)", in: textView)
        case .header1:
            insertLinePrefix("# ", in: textView)
        case .header2:
            insertLinePrefix("## ", in: textView)
        case .header3:
            insertLinePrefix("### ", in: textView)
        case .bulletList:
            insertLinePrefix("- ", in: textView)
        case .numberedList:
            insertLinePrefix("1. ", in: textView)
        case .quote:
            insertLinePrefix("> ", in: textView)
        }
        
        // Update the content using callback
        DispatchQueue.main.async {
            self.updateContentCallback?(textView.string)
        }
    }
    
    // MARK: - Formatting State Detection
    
    func isFormattingActive(_ action: FormattingAction) -> Bool {
        guard let textView = activeTextView else { return false }
        
        let selectedRange = textView.selectedRange()
        let text = textView.string as NSString
        
        switch action {
        case .bold:
            return isCharacterFormattingActive("**", "**", at: selectedRange, in: text)
        case .italic:
            return isCharacterFormattingActive("*", "*", at: selectedRange, in: text)
        case .strikethrough:
            return isCharacterFormattingActive("~~", "~~", at: selectedRange, in: text)
        case .code:
            return isCharacterFormattingActive("`", "`", at: selectedRange, in: text)
        case .link:
            return isCharacterFormattingActive("[", "](", at: selectedRange, in: text)
        case .header1:
            return isLinePrefixActive("# ", at: selectedRange, in: text)
        case .header2:
            return isLinePrefixActive("## ", at: selectedRange, in: text)
        case .header3:
            return isLinePrefixActive("### ", at: selectedRange, in: text)
        case .bulletList:
            return isAnyListActive(at: selectedRange, in: text)
        case .numberedList:
            return isNumberedListActive(at: selectedRange, in: text)
        case .quote:
            return isLinePrefixActive("> ", at: selectedRange, in: text)
        }
    }
    
    private func isCharacterFormattingActive(_ prefix: String, _ suffix: String, at range: NSRange, in text: NSString) -> Bool {
        var checkRange = range
        
        // If no selection, expand to word boundaries to check
        if range.length == 0 {
            checkRange = expandToWordBoundaries(at: range.location, in: text)
        }
        
        // Also check surrounding area for formatting
        let expandedStart = max(0, checkRange.location - prefix.count)
        let expandedEnd = min(text.length, checkRange.location + checkRange.length + suffix.count)
        let expandedRange = NSRange(location: expandedStart, length: expandedEnd - expandedStart)
        
        let surroundingText = text.substring(with: expandedRange)
        let relativeRange = NSRange(location: checkRange.location - expandedStart, length: checkRange.length)
        
        // Check if the text around the cursor/selection has the formatting
        return surroundingText.hasPrefix(prefix) && 
               surroundingText.hasSuffix(suffix) &&
               relativeRange.location >= prefix.count &&
               relativeRange.location + relativeRange.length <= surroundingText.count - suffix.count
    }
    
    private func isLinePrefixActive(_ prefix: String, at range: NSRange, in text: NSString) -> Bool {
        let lineRange = text.lineRange(for: range)
        let currentLine = text.substring(with: lineRange)
        let trimmedLine = currentLine.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return detectExistingPrefix(in: trimmedLine, targetPrefix: prefix) != nil
    }
    
    private func isAnyListActive(at range: NSRange, in text: NSString) -> Bool {
        let lineRange = text.lineRange(for: range)
        let currentLine = text.substring(with: lineRange)
        let trimmedLine = currentLine.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let listPrefixes = ["- ", "* ", "+ "]
        return listPrefixes.contains { trimmedLine.hasPrefix($0) }
    }
    
    private func isNumberedListActive(at range: NSRange, in text: NSString) -> Bool {
        let lineRange = text.lineRange(for: range)
        let currentLine = text.substring(with: lineRange)
        let trimmedLine = currentLine.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let pattern = #"^\d+\. "#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(location: 0, length: trimmedLine.count)
            return regex.firstMatch(in: trimmedLine, range: range) != nil
        }
        return false
    }
    
    // MARK: - Private Formatting Methods
    
    private func insertMarkdownFormatting(_ prefix: String, _ suffix: String, in textView: NSTextView) {
        let originalRange = textView.selectedRange()
        var workingRange = originalRange
        let text = textView.string as NSString
        
        // If no selection, try to select the current word or expand to smart boundaries
        if workingRange.length == 0 {
            workingRange = expandToWordBoundaries(at: workingRange.location, in: text)
        }
        
        let selectedText = text.substring(with: workingRange)
        
        // Check if the text is already formatted with this prefix/suffix
        if selectedText.hasPrefix(prefix) && selectedText.hasSuffix(suffix) && selectedText.count >= prefix.count + suffix.count {
            // Remove existing formatting (toggle off)
            let innerText = String(selectedText.dropFirst(prefix.count).dropLast(suffix.count))
            textView.replaceCharacters(in: workingRange, with: innerText)
            
            // Position cursor at the end of the unformatted text
            let newPosition = workingRange.location + innerText.count
            textView.setSelectedRange(NSRange(location: newPosition, length: 0))
        } else {
            // Apply formatting (toggle on)
            let newText = prefix + selectedText + suffix
            textView.replaceCharacters(in: workingRange, with: newText)
            
            if originalRange.length == 0 {
                // No original selection - position cursor at end of formatted text
                let newPosition = workingRange.location + newText.count
                textView.setSelectedRange(NSRange(location: newPosition, length: 0))
            } else {
                // Had selection - select the newly formatted text
                textView.setSelectedRange(NSRange(location: workingRange.location, length: newText.count))
            }
        }
    }
    
    private func expandToWordBoundaries(at location: Int, in text: NSString) -> NSRange {
        guard location > 0 && location < text.length else {
            return NSRange(location: location, length: 0)
        }
        
        // Find word boundaries
        var start = location
        var end = location
        
        // Expand backwards to find start of word
        while start > 0 {
            let char = text.character(at: start - 1)
            if CharacterSet.whitespacesAndNewlines.contains(UnicodeScalar(char)!) ||
               CharacterSet.punctuationCharacters.contains(UnicodeScalar(char)!) {
                break
            }
            start -= 1
        }
        
        // Expand forwards to find end of word
        while end < text.length {
            let char = text.character(at: end)
            if CharacterSet.whitespacesAndNewlines.contains(UnicodeScalar(char)!) ||
               CharacterSet.punctuationCharacters.contains(UnicodeScalar(char)!) {
                break
            }
            end += 1
        }
        
        return NSRange(location: start, length: end - start)
    }
    
    private func insertLinePrefix(_ prefix: String, in textView: NSTextView) {
        let selectedRange = textView.selectedRange()
        let text = textView.string as NSString
        
        // Find the start of the current line
        let lineRange = text.lineRange(for: selectedRange)
        let currentLine = text.substring(with: lineRange)
        let trimmedLine = currentLine.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Smart prefix detection and handling
        let prefixToRemove = detectExistingPrefix(in: trimmedLine, targetPrefix: prefix)
        
        if let existingPrefix = prefixToRemove {
            // Remove existing formatting
            removePrefixFromLine(existingPrefix, lineRange: lineRange, textView: textView, originalCursor: selectedRange)
        } else {
            // Apply new formatting
            addPrefixToLine(prefix, lineRange: lineRange, textView: textView, originalCursor: selectedRange)
        }
    }
    
    private func detectExistingPrefix(in line: String, targetPrefix: String) -> String? {
        let trimmedPrefix = targetPrefix.trimmingCharacters(in: .whitespaces)
        
        // Check for exact match first
        if line.hasPrefix(trimmedPrefix) {
            return targetPrefix
        }
        
        // Check for other header levels (if this is a header)
        if trimmedPrefix.hasPrefix("#") {
            for headerLevel in 1...6 {
                let headerPrefix = String(repeating: "#", count: headerLevel) + " "
                if line.hasPrefix(headerPrefix.trimmingCharacters(in: .whitespaces)) {
                    return headerPrefix
                }
            }
        }
        
        // Check for other list types (if this is a list)
        if trimmedPrefix == "- " || trimmedPrefix == "* " || trimmedPrefix == "+ " {
            let listPrefixes = ["- ", "* ", "+ "]
            for listPrefix in listPrefixes {
                if line.hasPrefix(listPrefix) {
                    return listPrefix
                }
            }
        }
        
        // Check for numbered list
        if trimmedPrefix.hasSuffix(". ") {
            let pattern = #"^\d+\. "#
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(location: 0, length: line.count)
                if let match = regex.firstMatch(in: line, range: range) {
                    let matchedText = (line as NSString).substring(with: match.range)
                    return matchedText
                }
            }
        }
        
        // Check for quote
        if trimmedPrefix == "> " && line.hasPrefix("> ") {
            return "> "
        }
        
        return nil
    }
    
    private func removePrefixFromLine(_ prefixToRemove: String, lineRange: NSRange, textView: NSTextView, originalCursor: NSRange) {
        let currentLine = (textView.string as NSString).substring(with: lineRange)
        let newLine = currentLine.replacingOccurrences(of: prefixToRemove, with: "", options: .anchored, range: nil)
        
        textView.replaceCharacters(in: lineRange, with: newLine)
        
        // Adjust cursor position
        let adjustment = prefixToRemove.count
        let newPosition = max(lineRange.location, originalCursor.location - adjustment)
        textView.setSelectedRange(NSRange(location: newPosition, length: 0))
    }
    
    private func addPrefixToLine(_ prefix: String, lineRange: NSRange, textView: NSTextView, originalCursor: NSRange) {
        let lineStart = lineRange.location
        textView.replaceCharacters(in: NSRange(location: lineStart, length: 0), with: prefix)
        
        // Adjust cursor position
        let newPosition = originalCursor.location + prefix.count
        textView.setSelectedRange(NSRange(location: newPosition, length: 0))
    }
}

// MARK: - String Extension

extension String {
    func substring(with range: NSRange) -> String? {
        guard range.location != NSNotFound && range.location + range.length <= count else {
            return nil
        }
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        return String(self[start..<end])
    }
}

// MARK: - Binding Extension

extension Binding where Value == String {
    // Helper to work with the service
}