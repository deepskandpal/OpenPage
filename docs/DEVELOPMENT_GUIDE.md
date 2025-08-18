# OpenPage Development Guide
*Best Practices, Architecture Patterns, and Common Pitfalls*

## Table of Contents
1. [SwiftUI + AppKit Text Editor Architecture](#swiftui--appkit-text-editor-architecture)
2. [State Management Patterns](#state-management-patterns)
3. [Performance Best Practices](#performance-best-practices)
4. [Common Pitfalls and Solutions](#common-pitfalls-and-solutions)
5. [Testing Strategies](#testing-strategies)
6. [Code Organization](#code-organization)

---

## SwiftUI + AppKit Text Editor Architecture

### ✅ **Best Practices**

#### 1. **Clear Separation of Concerns**
```swift
// ❌ BAD: Everything in one massive NSViewRepresentable
struct TextEditor: NSViewRepresentable {
    // 500+ lines of mixed UI, business logic, and data handling
}

// ✅ GOOD: Separated concerns
struct TextEditor: NSViewRepresentable {
    // Only UI bridging logic
}

class TextEditorCoordinator: NSObject, NSTextViewDelegate {
    // Only delegation and coordination
}

class ContentManager: ObservableObject {
    // Only content and state management
}

class FormattingService {
    // Only formatting operations
}
```

#### 2. **Single Source of Truth for Content**
```swift
// ✅ GOOD: One canonical content source
class ContentManager: ObservableObject {
    @Published private(set) var content: String = ""
    private var markdownSource: String = "" // Source of truth
    
    func updateContent(_ newContent: String) {
        markdownSource = newContent
        content = processForDisplay(newContent)
    }
}
```

#### 3. **Delegate Pattern for NSTextView Integration**
```swift
// ✅ GOOD: Proper delegate coordination
class Coordinator: NSObject, NSTextViewDelegate, NSTextStorageDelegate {
    private weak var parent: TextEditor?
    private let contentManager: ContentManager
    
    func textDidChange(_ notification: Notification) {
        // Update content manager, not parent directly
        contentManager.updateContent(textView.string)
    }
}
```

### ⚠️ **Common Pitfalls**

#### 1. **Circular Update Loops**
```swift
// ❌ BAD: Creates infinite update cycles
func updateNSView(_ nsView: NSScrollView, context: Context) {
    if textView.string != content {
        textView.string = content // This triggers textDidChange
    }
}

func textDidChange(_ notification: Notification) {
    content = textView.string // This triggers updateNSView
}

// ✅ GOOD: Guard against unnecessary updates
func updateNSView(_ nsView: NSScrollView, context: Context) {
    guard textView.string != content else { return }
    
    // Use flag to prevent circular updates
    isUpdatingFromSwiftUI = true
    textView.string = content
    isUpdatingFromSwiftUI = false
}

func textDidChange(_ notification: Notification) {
    guard !isUpdatingFromSwiftUI else { return }
    content = textView.string
}
```

#### 2. **Memory Leaks in Closures**
```swift
// ❌ BAD: Strong reference cycles
FormattingService.shared.registerTextView(textView) { newContent in
    self.content = newContent // Strong reference to self
}

// ✅ GOOD: Weak references
FormattingService.shared.registerTextView(textView) { [weak self] newContent in
    self?.content = newContent
}
```

#### 3. **Thread Safety Issues**
```swift
// ❌ BAD: UI updates on background threads
func textDidChange(_ notification: Notification) {
    // This might be called on background thread
    parent.content = textView.string
}

// ✅ GOOD: Ensure main thread updates
func textDidChange(_ notification: Notification) {
    DispatchQueue.main.async {
        self.parent.content = textView.string
    }
}
```

---

## State Management Patterns

### ✅ **Recommended Architecture**

#### 1. **MVVM + Services Pattern**
```swift
// Model: Data structures
struct Document {
    var content: String
    var metadata: DocumentMetadata
}

// View Model: State management for views
class EditorViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var displayMode: DisplayMode = .richText
    
    private let contentManager = ContentManager()
    private let formattingService = FormattingService()
}

// Services: Business logic
class ContentManager {
    func convertToRichText(_ markdown: String) -> NSAttributedString
    func convertToMarkdown(_ richText: NSAttributedString) -> String
}

// View: UI only
struct EditorView: View {
    @StateObject private var viewModel = EditorViewModel()
}
```

#### 2. **Publisher/Subscriber Pattern for Communication**
```swift
// ✅ GOOD: Decoupled communication
class ContentManager: ObservableObject {
    @Published var contentChanged = PassthroughSubject<String, Never>()
    
    func updateContent(_ content: String) {
        // Update internal state
        self.content = content
        
        // Notify subscribers
        contentChanged.send(content)
    }
}

class FormattingService {
    private var cancellables = Set<AnyCancellable>()
    
    init(contentManager: ContentManager) {
        contentManager.contentChanged
            .sink { [weak self] content in
                self?.refreshFormattingState(content)
            }
            .store(in: &cancellables)
    }
}
```

### ⚠️ **State Management Pitfalls**

#### 1. **Too Many @Published Properties**
```swift
// ❌ BAD: Every property published causes view updates
class ViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var wordCount: Int = 0
    @Published var characterCount: Int = 0
    @Published var lineCount: Int = 0
    @Published var readingTime: Int = 0
    // 20+ @Published properties...
}

// ✅ GOOD: Group related state
class ViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var statistics: DocumentStatistics = .empty
    
    private func updateStatistics() {
        statistics = DocumentStatistics(
            wordCount: calculateWordCount(),
            characterCount: content.count,
            // ...
        )
    }
}
```

#### 2. **Inappropriate Use of @StateObject vs @ObservedObject**
```swift
// ❌ BAD: Creating new instances on every view update
struct EditorView: View {
    @ObservedObject var viewModel = EditorViewModel() // NEW INSTANCE!
}

// ✅ GOOD: Persistent state object
struct EditorView: View {
    @StateObject private var viewModel = EditorViewModel()
}

// ✅ GOOD: Injected dependency
struct EditorView: View {
    @ObservedObject var viewModel: EditorViewModel
}
```

---

## Performance Best Practices

### ✅ **Text Rendering Optimization**

#### 1. **Efficient Syntax Highlighting**
```swift
// ❌ BAD: Re-highlight entire document on every change
func textDidChange(_ notification: Notification) {
    highlightEntireDocument()
}

// ✅ GOOD: Incremental highlighting with debouncing
func textDidChange(_ notification: Notification) {
    // Cancel previous highlighting requests
    NSObject.cancelPreviousPerformRequests(
        withTarget: self, 
        selector: #selector(performHighlighting), 
        object: nil
    )
    
    // Schedule new highlighting with delay
    perform(
        #selector(performHighlighting), 
        with: nil, 
        afterDelay: 0.3
    )
}

@objc private func performHighlighting() {
    // Only highlight visible range
    let visibleRange = textView.visibleRect
    highlightRange(visibleRange)
}
```

#### 2. **Lazy Loading and Virtualization**
```swift
// ✅ GOOD: Only process visible content
class LargeDocumentRenderer {
    private var visibleRange: NSRange = NSRange()
    
    func updateVisibleRange(_ range: NSRange) {
        guard range != visibleRange else { return }
        visibleRange = range
        
        // Only render visible portion
        renderRange(range)
    }
}
```

#### 3. **Memory Management**
```swift
// ✅ GOOD: Proper cleanup
class TextEditorCoordinator: NSObject {
    private var textView: NSTextView?
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        // Clean up observers
        NotificationCenter.default.removeObserver(self)
        
        // Cancel subscriptions
        cancellables.removeAll()
        
        // Unregister from services
        if let textView = textView {
            FormattingService.shared.unregister(textView)
        }
    }
}
```

### ⚠️ **Performance Pitfalls**

#### 1. **Excessive View Updates**
```swift
// ❌ BAD: Every keystroke triggers expensive operations
func textDidChange(_ notification: Notification) {
    updateWordCount()        // Expensive
    updateReadingTime()      // Expensive  
    updateDocumentStats()    // Expensive
    refreshPreview()         // Very expensive
}

// ✅ GOOD: Batch updates with debouncing
func textDidChange(_ notification: Notification) {
    // Immediate updates for critical UI
    updateCharacterCount()
    
    // Debounced updates for expensive operations
    debouncer.debounce {
        self.updateExpensiveStatistics()
        self.refreshPreview()
    }
}
```

#### 2. **Inefficient String Operations**
```swift
// ❌ BAD: O(n) operations on every keystroke
func highlightSyntax(_ text: String) {
    for i in 0..<text.count {
        let char = text[text.index(text.startIndex, offsetBy: i)]
        // Process character
    }
}

// ✅ GOOD: Use NSString for efficient range operations
func highlightSyntax(_ text: String) {
    let nsText = text as NSString
    let range = NSRange(location: 0, length: nsText.length)
    
    // Use efficient NSString methods
    nsText.enumerateSubstrings(
        in: range,
        options: [.byWords, .localized]
    ) { substring, range, _, _ in
        // Process efficiently
    }
}
```

---

## Common Pitfalls and Solutions

### 1. **NSTextView Lifecycle Management**

#### ❌ **Problem: Improper Text View Setup**
```swift
func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSScrollView()
    let textView = NSTextView()
    
    // BAD: Missing essential configuration
    scrollView.documentView = textView
    return scrollView
}
```

#### ✅ **Solution: Comprehensive Setup**
```swift
func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSScrollView()
    
    // Create text system components explicitly
    let textContainer = NSTextContainer()
    let layoutManager = NSLayoutManager() 
    let textStorage = NSTextStorage()
    
    // Link components properly
    textStorage.addLayoutManager(layoutManager)
    layoutManager.addTextContainer(textContainer)
    
    let textView = CustomTextView(frame: .zero, textContainer: textContainer)
    
    // Configure text view completely
    setupTextView(textView)
    setupScrollView(scrollView, with: textView)
    setupDelegates(textView, context: context)
    
    return scrollView
}

private func setupTextView(_ textView: NSTextView) {
    textView.isEditable = true
    textView.isSelectable = true
    textView.allowsUndo = true
    textView.isRichText = false
    textView.usesFindBar = true
    
    // Configure text container
    textView.textContainer?.widthTracksTextView = true
    textView.textContainer?.heightTracksTextView = false
    textView.textContainer?.containerSize = NSSize(
        width: 800, 
        height: CGFloat.greatestFiniteMagnitude
    )
    
    // Configure layout manager
    textView.layoutManager?.showsInvisibleCharacters = false
    textView.layoutManager?.showsControlCharacters = false
}
```

### 2. **Coordinate System and Layout Issues**

#### ❌ **Problem: Frame and Bounds Confusion**
```swift
// BAD: Mixing coordinate systems
func updateLayout() {
    textView.frame = scrollView.bounds  // Wrong coordinate system
}
```

#### ✅ **Solution: Proper Coordinate Handling**
```swift
func updateLayout() {
    let scrollerWidth = scrollView.hasVerticalScroller ? 15.0 : 0.0
    let contentWidth = scrollView.contentSize.width - scrollerWidth
    
    // Use proper coordinate systems
    textView.frame = NSRect(
        x: 0,
        y: 0, 
        width: contentWidth,
        height: scrollView.contentSize.height
    )
    
    textView.textContainer?.containerSize = NSSize(
        width: contentWidth,
        height: CGFloat.greatestFiniteMagnitude
    )
}
```

### 3. **Focus and First Responder Management**

#### ❌ **Problem: Unreliable Focus Handling**
```swift
func makeNSView(context: Context) -> NSScrollView {
    // BAD: Immediate focus attempt
    textView.window?.makeFirstResponder(textView)
    return scrollView
}
```

#### ✅ **Solution: Proper Focus Management**
```swift
func makeNSView(context: Context) -> NSScrollView {
    // Configure views first
    let scrollView = setupScrollView()
    
    // Schedule focus for after view hierarchy is established
    DispatchQueue.main.async {
        self.attemptFocus(scrollView)
    }
    
    return scrollView
}

private func attemptFocus(_ scrollView: NSScrollView) {
    guard let textView = scrollView.documentView as? NSTextView,
          let window = scrollView.window else { return }
    
    // Ensure view accepts first responder
    guard textView.acceptsFirstResponder else { return }
    
    // Attempt to make first responder
    let success = window.makeFirstResponder(textView)
    print("Focus attempt: \(success)")
}
```

---

## Testing Strategies

### ✅ **Unit Testing Text Operations**

```swift
class ContentManagerTests: XCTestCase {
    var contentManager: ContentManager!
    
    override func setUp() {
        contentManager = ContentManager()
    }
    
    func testMarkdownToRichTextConversion() {
        // Given
        let markdown = "**Bold** and *italic* text"
        
        // When
        let richText = contentManager.convertToRichText(markdown)
        
        // Then
        XCTAssertTrue(richText.containsBoldText(in: NSRange(location: 0, length: 4)))
        XCTAssertTrue(richText.containsItalicText(in: NSRange(location: 10, length: 6)))
    }
    
    func testDisplayModeToggling() {
        // Given
        contentManager.setContent("# Header", theme: .system, fontSize: 16, lineHeight: 1.6)
        
        // When
        contentManager.setDisplayMode(.richText, theme: .system, fontSize: 16, lineHeight: 1.6)
        
        // Then
        XCTAssertEqual(contentManager.displayMode, .richText)
        XCTAssertEqual(contentManager.getMarkdownContent(), "# Header")
    }
}
```

### ✅ **Integration Testing UI Components**

```swift
class TextEditorIntegrationTests: XCTestCase {
    func testFormattingButtonsUpdateContent() {
        // Given
        let editorView = ModernEditorView(
            content: .constant("Test content"),
            focusMode: .constant(.normal)
        )
        
        // When
        editorView.handleFormatting(.bold)
        
        // Then
        // Verify content was updated with markdown syntax
        XCTAssertTrue(editorView.content.contains("**"))
    }
}
```

---

## Code Organization

### ✅ **Recommended File Structure**

```
OpenPage/
├── Core/
│   ├── Models/
│   │   ├── Document.swift
│   │   └── EditorTheme.swift
│   ├── Services/
│   │   ├── ContentManager.swift
│   │   ├── FormattingService.swift
│   │   └── MarkdownRenderer.swift
│   └── Extensions/
│       ├── NSFont+Extensions.swift
│       └── String+Extensions.swift
├── Features/
│   ├── Editor/
│   │   ├── Views/
│   │   │   ├── ModernEditorView.swift
│   │   │   ├── ModernTextEditor.swift
│   │   │   └── EditorToolbar.swift
│   │   ├── ViewModels/
│   │   │   └── EditorViewModel.swift
│   │   └── Components/
│   │       ├── FocusMode.swift
│   │       └── SyntaxHighlighter.swift
│   └── DocumentLibrary/
│       ├── Views/
│       └── ViewModels/
├── Infrastructure/
│   ├── Networking/
│   ├── Storage/
│   └── Utils/
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

### ✅ **Protocol-Oriented Design**

```swift
// Define clear interfaces
protocol TextRenderer {
    func render(_ content: String, with theme: EditorTheme) -> NSAttributedString
}

protocol ContentPersistence {
    func save(_ content: String, to url: URL) throws
    func load(from url: URL) throws -> String
}

protocol FormattingProvider {
    func applyFormatting(_ action: FormattingAction, to textView: NSTextView)
    func isFormattingActive(_ action: FormattingAction, in textView: NSTextView) -> Bool
}

// Implement with clear separation
struct MarkdownRenderer: TextRenderer {
    func render(_ content: String, with theme: EditorTheme) -> NSAttributedString {
        // Implementation
    }
}

class FormattingService: FormattingProvider {
    func applyFormatting(_ action: FormattingAction, to textView: NSTextView) {
        // Implementation
    }
}
```

---

## Key Takeaways

### 🎯 **Critical Success Factors**

1. **Start Simple**: Build the core functionality first, add complexity gradually
2. **Single Responsibility**: Each class/service should have one clear purpose
3. **Clear Data Flow**: Content should flow through well-defined paths
4. **Performance First**: Consider performance implications of every text operation
5. **Test Early**: Unit test text operations and content transformations
6. **Memory Management**: Always clean up observers, delegates, and subscriptions

### 🚫 **Critical Failure Points**

1. **Circular Updates**: Between SwiftUI and NSTextView
2. **Memory Leaks**: In delegate patterns and closures
3. **Thread Safety**: UI updates on wrong threads
4. **Performance**: Synchronous operations on main thread
5. **State Synchronization**: Multiple sources of truth
6. **Layout Issues**: Improper coordinate system handling

### 📚 **Recommended Resources**

- **Apple Documentation**: NSTextView, NSLayoutManager, NSTextStorage
- **WWDC Sessions**: Advanced Text Kit, Text Editing Best Practices
- **Books**: "Thinking in SwiftUI" for state management patterns
- **Community**: Swift forums for specific text editing questions

---

*This guide is based on real-world experience building OpenPage and common patterns in successful macOS text editors.*