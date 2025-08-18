import SwiftUI
import AppKit

/// Modern text editor with rich text capabilities and markdown support
struct ModernTextEditor: NSViewRepresentable {
    @Binding var content: String
    let theme: EditorTheme
    let fontSize: Double
    let lineHeight: Double
    let isMarkdownMode: Bool
    let focusMode: WritingFocusMode
    var isEditorFocused: FocusState<Bool>.Binding
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = ModernNSTextView(frame: .zero, textContainer: nil)
        
        // Configure text view
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = true
        textView.isAutomaticTextReplacementEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isContinuousSpellCheckingEnabled = true
        textView.isGrammarCheckingEnabled = true
        textView.usesInspectorBar = true
        textView.usesFindBar = true
        textView.string = content
        
        // Configure text container
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        // Configure scroll view
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.documentView = textView
        scrollView.borderType = .noBorder
        
        // Store references
        context.coordinator.textView = textView
        context.coordinator.scrollView = scrollView
        
        // Defer focus until the text view is fully set up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if textView.superview != nil {
                textView.window?.makeFirstResponder(textView)
            }
        }
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? ModernNSTextView else { return }
        
        // Update content if needed
        if textView.string != content {
            textView.string = content
        }
        
        // Update styling
        updateTextViewAppearance(textView)
        
        // Update focus mode
        context.coordinator.updateFocusMode(focusMode)
        
        // Handle focus state - ensure text view gets focus when requested
        if isEditorFocused.wrappedValue && textView.window?.firstResponder != textView {
            DispatchQueue.main.async {
                textView.window?.makeFirstResponder(textView)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateTextViewAppearance(_ textView: ModernNSTextView) {
        // Create paragraph style with line height
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = CGFloat(lineHeight)
        paragraphStyle.lineSpacing = 4
        
        // Create text attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular),
            .foregroundColor: NSColor(theme.textColor),
            .paragraphStyle: paragraphStyle
        ]
        
        // Apply attributes to all text
        let range = NSRange(location: 0, length: textView.string.count)
        textView.textStorage?.addAttributes(attributes, range: range)
        
        // Update background color
        textView.backgroundColor = NSColor(theme.backgroundColor)
        textView.insertionPointColor = NSColor(theme.accentColor)
        
        // Apply markdown highlighting if enabled
        if isMarkdownMode {
            applyMarkdownSyntaxHighlighting(textView)
        }
    }
    
    private func applyMarkdownSyntaxHighlighting(_ textView: NSTextView) {
        let text = textView.string
        let range = NSRange(location: 0, length: text.count)
        
        // Headers
        let headerRegex = try! NSRegularExpression(pattern: "^(#{1,6})\\s(.+)$", options: [.anchorsMatchLines])
        headerRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            
            let headerLevel = match.range(at: 1).length
            let fontSize = CGFloat(24 - (headerLevel * 2))
            let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
            
            textView.textStorage?.addAttribute(.font, value: font, range: match.range)
            textView.textStorage?.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: match.range(at: 1))
        }
        
        // Bold text
        let boldRegex = try! NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*", options: [])
        boldRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            
            let font = NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .bold)
            textView.textStorage?.addAttribute(.font, value: font, range: match.range(at: 1))
            textView.textStorage?.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range)
        }
        
        // Italic text
        let italicRegex = try! NSRegularExpression(pattern: "\\*(.+?)\\*", options: [])
        italicRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            
            let font = NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular).withTraits(.italic)
            textView.textStorage?.addAttribute(.font, value: font, range: match.range(at: 1))
            textView.textStorage?.addAttribute(.foregroundColor, value: NSColor(theme.secondaryTextColor), range: match.range)
        }
        
        // Code blocks
        let codeRegex = try! NSRegularExpression(pattern: "`(.+?)`", options: [])
        codeRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            
            let font = NSFont.monospacedSystemFont(ofSize: CGFloat(fontSize - 1), weight: .regular)
            textView.textStorage?.addAttribute(.font, value: font, range: match.range)
            textView.textStorage?.addAttribute(.backgroundColor, value: NSColor(theme.accentColor.opacity(0.1)), range: match.range)
        }
        
        // Links
        let linkRegex = try! NSRegularExpression(pattern: "\\[(.+?)\\]\\((.+?)\\)", options: [])
        linkRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            
            textView.textStorage?.addAttribute(.foregroundColor, value: NSColor(theme.accentColor), range: match.range(at: 1))
            textView.textStorage?.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range(at: 1))
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: ModernTextEditor
        var textView: ModernNSTextView?
        var scrollView: NSScrollView?
        
        init(_ parent: ModernTextEditor) {
            self.parent = parent
            super.init()
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            DispatchQueue.main.async {
                self.parent.content = textView.string
            }
            
            // Apply syntax highlighting with debouncing
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(applySyntaxHighlighting), object: nil)
            perform(#selector(applySyntaxHighlighting), with: nil, afterDelay: 0.3)
        }
        
        @objc private func applySyntaxHighlighting() {
            guard let textView = textView else { return }
            parent.updateTextViewAppearance(textView)
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            // Handle focus mode behaviors
            if parent.focusMode == .typewriter {
                centerCurrentLine()
            }
        }
        
        func textViewDidBecomeFirstResponder(_ notification: Notification) {
            DispatchQueue.main.async {
                self.parent.isEditorFocused.wrappedValue = true
            }
        }
        
        func textViewDidResignFirstResponder(_ notification: Notification) {
            DispatchQueue.main.async {
                self.parent.isEditorFocused.wrappedValue = false
            }
        }
        
        func updateFocusMode(_ mode: WritingFocusMode) {
            switch mode {
            case .zen, .distraction_free:
                // Hide scroll bars
                scrollView?.hasVerticalScroller = false
                scrollView?.hasHorizontalScroller = false
            default:
                // Show scroll bars
                scrollView?.hasVerticalScroller = true
                scrollView?.hasHorizontalScroller = false
            }
        }
        
        private func centerCurrentLine() {
            guard let textView = textView,
                  let scrollView = scrollView else { return }
            
            let selectedRange = textView.selectedRange()
            let glyphRange = textView.layoutManager?.glyphRange(forCharacterRange: selectedRange, actualCharacterRange: nil) ?? NSRange()
            let lineRect = textView.layoutManager?.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil) ?? NSRect()
            
            let visibleRect = scrollView.contentView.visibleRect
            let targetY = lineRect.midY - visibleRect.height / 2
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                scrollView.contentView.animator().setBoundsOrigin(NSPoint(x: 0, y: targetY))
            }
        }
    }
}

// MARK: - Custom NSTextView

class ModernNSTextView: NSTextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextView()
    }
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextView()
    }
    
    private func setupTextView() {
        // Enable editing
        isEditable = true
        isSelectable = true
        
        // Enable modern text features
        isAutomaticQuoteSubstitutionEnabled = true
        isAutomaticDashSubstitutionEnabled = true
        isAutomaticTextReplacementEnabled = true
        isAutomaticSpellingCorrectionEnabled = true
        isContinuousSpellCheckingEnabled = true
        isGrammarCheckingEnabled = true
        
        // Configure appearance
        drawsBackground = true
        allowsUndo = true
        isRichText = false
        importsGraphics = false
        
        // Configure text container
        textContainer?.widthTracksTextView = true
        textContainer?.heightTracksTextView = false
        
        // Line numbering and better wrapping
        isVerticallyResizable = true
        isHorizontallyResizable = false
        textContainer?.containerSize = NSSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        // Handle special key combinations
        if event.modifierFlags.contains(.command) {
            switch event.charactersIgnoringModifiers {
            case "b":
                let currentRange = selectedRange()
                replaceCharacters(in: currentRange, with: "****")
                setSelectedRange(NSRange(location: currentRange.location + 2, length: 0))
                return
            case "i":
                let currentRange = selectedRange()
                replaceCharacters(in: currentRange, with: "**")
                setSelectedRange(NSRange(location: currentRange.location + 1, length: 0))
                return
            default:
                break
            }
        }
        
        super.keyDown(with: event)
    }
}

// MARK: - NSFont Extension

extension NSFont {
    func withTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return NSFont(descriptor: descriptor, size: pointSize) ?? self
    }
}