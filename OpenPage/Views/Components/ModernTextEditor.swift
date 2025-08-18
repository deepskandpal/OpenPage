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
        print("DEBUG: makeNSView initial scrollView frame: \(scrollView.frame)")
        
        // Create text container and layout manager explicitly
        let textContainer = NSTextContainer()
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage()
        
        // Set up the text system components
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        let textView = ModernNSTextView(frame: .zero, textContainer: textContainer)
        
        // Configure text view - be very explicit about editability
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.drawsBackground = true
        // Set initial background - will be updated by theme in updateTextViewAppearance
        textView.backgroundColor = NSColor(theme.backgroundColor)
        textView.insertionPointColor = NSColor(theme.accentColor)
        
        // Set cursor width to match font size
        if let layoutManager = textView.layoutManager {
            layoutManager.showsInvisibleCharacters = false
            layoutManager.showsControlCharacters = false
        }
        
        // Ensure cursor is visible
        textView.displaysLinkToolTips = true
        
        // Ensure notifications are sent for text changes
        textView.isAutomaticTextCompletionEnabled = true
        textView.textStorage?.delegate = context.coordinator
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = true
        textView.isAutomaticTextReplacementEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isContinuousSpellCheckingEnabled = true
        textView.isGrammarCheckingEnabled = true
        textView.usesInspectorBar = true
        textView.usesFindBar = true
        textView.string = content
        
        // Set initial typing attributes to ensure text is visible when typed
        let initialParagraphStyle = NSMutableParagraphStyle()
        initialParagraphStyle.lineHeightMultiple = CGFloat(lineHeight)
        initialParagraphStyle.lineSpacing = 4
        
        textView.typingAttributes = [
            .font: NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: initialParagraphStyle
        ]
        
        // Configure text container with proper sizing
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        textView.textContainer?.containerSize = NSSize(width: 1000, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: 0)
        
        // Set a reasonable frame to start with
        textView.frame = NSRect(x: 0, y: 0, width: 1000, height: 400)
        
        // Ensure text view can receive events
        textView.needsLayout = true
        textView.layoutSubtreeIfNeeded()
        
        // Configure scroll view with proper size
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.documentView = textView
        scrollView.borderType = .noBorder
        
        // Set a minimum frame size for the scroll view
        scrollView.frame = NSRect(x: 0, y: 0, width: 1000, height: 400)
        print("DEBUG: makeNSView set scrollView frame to: \(scrollView.frame)")
        
        // Add tap gesture to ensure focus
        let tapGesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap))
        scrollView.addGestureRecognizer(tapGesture)
        
        // Store references
        context.coordinator.textView = textView
        context.coordinator.scrollView = scrollView
        
        // Register with formatting service
        print("DEBUG: ModernTextEditor about to register textView")
        FormattingService.shared.registerTextView(textView) { [weak textView] newContent in
            guard textView?.string != newContent else { return }
            DispatchQueue.main.async {
                content = newContent
            }
        }
        
        // Force the text view to become first responder immediately
        DispatchQueue.main.async {
            if let window = scrollView.window {
                print("DEBUG: Making textView first responder immediately")
                let success = window.makeFirstResponder(textView)
                print("DEBUG: Initial makeFirstResponder success: \(success)")
            }
        }
        
        // Also try again after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = textView.window ?? textView.superview?.window {
                print("DEBUG: Attempting to make textView first responder - delayed")
                let success = window.makeFirstResponder(textView)
                print("DEBUG: Delayed makeFirstResponder success: \(success)")
                print("DEBUG: Current first responder: \(String(describing: window.firstResponder))")
                print("DEBUG: TextView isEditable: \(textView.isEditable)")
                print("DEBUG: TextView acceptsFirstResponder: \(textView.acceptsFirstResponder)")
                print("DEBUG: TextView in view hierarchy properly")
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
        
        // Ensure proper sizing
        let scrollViewFrame = nsView.frame
        print("DEBUG: updateNSView scrollViewFrame: \(scrollViewFrame)")
        if scrollViewFrame.width > 0 {
            let containerWidth = scrollViewFrame.width - 40 // Account for padding
            let frameWidth = containerWidth > 0 ? containerWidth : 800
            
            textView.textContainer?.containerSize = NSSize(
                width: frameWidth,
                height: CGFloat.greatestFiniteMagnitude
            )
            textView.frame = NSRect(
                x: 0, 
                y: 0, 
                width: frameWidth, 
                height: max(scrollViewFrame.height, 400)
            )
            print("DEBUG: Set textView frame to: \(textView.frame)")
            print("DEBUG: Set container size to: \(textView.textContainer?.containerSize ?? NSSize.zero)")
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
        
        // Force layout update
        textView.needsLayout = true
        textView.needsDisplay = true
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    private func updateTextViewAppearance(_ textView: ModernNSTextView) {
        // Create paragraph style with line height
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = CGFloat(lineHeight)
        paragraphStyle.lineSpacing = 4
        
        // Create text attributes with explicit text color
        let textColor = NSColor.labelColor // Use system label color for better contrast
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular),
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // Apply attributes to all text
        let range = NSRange(location: 0, length: textView.string.count)
        textView.textStorage?.addAttributes(attributes, range: range)
        
        // Update background color and ensure proper cursor visibility
        DispatchQueue.main.async {
            textView.backgroundColor = NSColor(theme.backgroundColor)
            textView.insertionPointColor = NSColor(theme.accentColor)
            textView.needsDisplay = true
        }
        
        // Configure selection appearance
        textView.selectedTextAttributes = [
            .backgroundColor: NSColor(theme.accentColor.opacity(0.3)),
            .foregroundColor: NSColor.labelColor
        ]
        
        // Set default typing attributes to ensure new text is visible
        textView.typingAttributes = [
            .font: NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle
        ]
        
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
    
    class Coordinator: NSObject, NSTextViewDelegate, NSTextStorageDelegate {
        let parent: ModernTextEditor
        var textView: ModernNSTextView?
        var scrollView: NSScrollView?
        
        init(_ parent: ModernTextEditor) {
            self.parent = parent
            super.init()
        }
        
        deinit {
            // Unregister from formatting service
            if let textView = textView {
                FormattingService.shared.unregisterTextView(textView)
            }
        }
        
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            print("DEBUG: textDidChange called - textView.string: '\(textView.string)'")
            print("DEBUG: textDidChange - parent.content before: '\(parent.content)'")
            
            // Update the SwiftUI binding immediately
            parent.content = textView.string
            print("DEBUG: textDidChange - parent.content after: '\(parent.content)'")
            
            // Force immediate display refresh
            textView.needsDisplay = true
            textView.needsLayout = true
            
            // Apply syntax highlighting with debouncing
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(applySyntaxHighlighting), object: nil)
            perform(#selector(applySyntaxHighlighting), with: nil, afterDelay: 0.3)
        }
        
        @objc private func applySyntaxHighlighting() {
            guard let textView = textView else { return }
            parent.updateTextViewAppearance(textView)
        }
        
        // MARK: - NSTextStorageDelegate
        
        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            print("DEBUG: textStorage didProcessEditing - new string: '\(textStorage.string)'")
            
            DispatchQueue.main.async {
                self.parent.content = textStorage.string
                print("DEBUG: Updated parent.content to: '\(self.parent.content)'")
                
                // Force display refresh to ensure text is visible
                self.textView?.needsDisplay = true
            }
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
        
        @objc func handleTap() {
            guard let textView = textView else { return }
            print("DEBUG: Tap detected, making textView first responder")
            textView.window?.makeFirstResponder(textView)
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
        
        // Configure text container with proper sizing
        textContainer?.widthTracksTextView = true
        textContainer?.heightTracksTextView = false
        
        // Line numbering and better wrapping
        isVerticallyResizable = true
        isHorizontallyResizable = false
        
        // Set container size - use reasonable default if frame is not set
        let containerWidth = frame.width > 0 ? frame.width : 800
        textContainer?.containerSize = NSSize(width: containerWidth, height: CGFloat.greatestFiniteMagnitude)
        
        // Ensure proper min/max sizes
        minSize = NSSize(width: 0, height: 0)
        maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
    
    override var acceptsFirstResponder: Bool {
        print("DEBUG: ModernNSTextView acceptsFirstResponder called - returning true")
        return true
    }
    
    
    override func becomeFirstResponder() -> Bool {
        print("DEBUG: ModernNSTextView becomeFirstResponder called")
        let result = super.becomeFirstResponder()
        print("DEBUG: ModernNSTextView becomeFirstResponder result: \(result)")
        if result {
            // Ensure the text view is ready for input and cursor is visible
            needsDisplay = true
            updateInsertionPointStateAndRestartTimer(true)
            
            // Force cursor to be visible with proper styling
            insertionPointColor = .controlAccentColor
        }
        return result
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        // Ensure this text view becomes first responder when clicked
        window?.makeFirstResponder(self)
        print("DEBUG: ModernNSTextView mouseDown - making first responder")
    }
    
    override func keyDown(with event: NSEvent) {
        print("DEBUG: ModernNSTextView keyDown received: \(event.charactersIgnoringModifiers ?? "nil")")
        print("DEBUG: Current string length: \(string.count)")
        
        // Always call super to handle text input
        super.keyDown(with: event)
        
        print("DEBUG: String length after super.keyDown: \(string.count)")
        
        // Force immediate display refresh after text input
        needsDisplay = true
        needsLayout = true
        
        // Handle special key combinations AFTER normal text processing
        if event.modifierFlags.contains(.command) {
            switch event.charactersIgnoringModifiers {
            case "b":
                let currentRange = selectedRange()
                replaceCharacters(in: currentRange, with: "**BOLD**")
                setSelectedRange(NSRange(location: currentRange.location + 2, length: 4))
                needsDisplay = true
                return
            case "i":
                let currentRange = selectedRange()
                replaceCharacters(in: currentRange, with: "*ITALIC*")
                setSelectedRange(NSRange(location: currentRange.location + 1, length: 6))
                needsDisplay = true
                return
            default:
                break
            }
        }
    }
    
    override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
        // Get current font to calculate proper cursor height
        let font = self.font ?? NSFont.systemFont(ofSize: 16)
        let cursorWidth: CGFloat = 1.0 // Thin cursor like modern editors
        let cursorHeight = font.pointSize + 2 // Slightly taller than font
        
        // Center the cursor vertically in the line
        let centeredRect = NSRect(
            x: rect.origin.x,
            y: rect.origin.y + (rect.height - cursorHeight) / 2,
            width: cursorWidth,
            height: cursorHeight
        )
        
        super.drawInsertionPoint(in: centeredRect, color: color, turnedOn: flag)
    }
}

// MARK: - NSFont Extension

extension NSFont {
    func withTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return NSFont(descriptor: descriptor, size: pointSize) ?? self
    }
}

