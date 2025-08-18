# Architecture Decision Log (ADL)
*Record of all architectural decisions and patterns for OpenPage*

## ADL-001: Dual-Mode Text Editor Architecture
**Date**: 2025-08-18  
**Status**: ✅ Implemented  
**Context**: Need to support both rich text (visual) and markdown syntax editing modes

### Decision
Implemented a three-service architecture:
- **ContentManager**: Single source of truth, manages mode switching
- **MarkdownRenderer**: Bidirectional conversion between markdown and NSAttributedString  
- **FormattingService**: Handles toolbar button actions in both modes

### Rationale
- Separates concerns clearly
- Maintains markdown as canonical data format
- Allows seamless mode switching
- Supports both visual and syntax editing paradigms

### Consequences
- ✅ Clean separation of responsibilities
- ✅ Single source of truth for content
- ⚠️ Complexity in keeping modes synchronized
- ⚠️ Performance overhead in conversions

### Implementation
```swift
// ContentManager maintains state
class ContentManager: ObservableObject {
    @Published private(set) var displayMode: DisplayMode
    private var markdownContent: String // Source of truth
}

// MarkdownRenderer handles conversions
class MarkdownRenderer {
    func markdownToRichText(_ markdown: String) -> NSAttributedString
    func applySyntaxHighlighting(to: NSMutableAttributedString)
}
```

---

## ADL-002: MVVM + Services Pattern
**Date**: 2025-08-18  
**Status**: ✅ Adopted  
**Context**: Need scalable architecture for complex text editing features

### Decision
Adopted MVVM + Services architecture pattern:
- **Models**: Data structures (Document, EditorTheme)
- **ViewModels**: State management for views (@ObservableObject)
- **Views**: UI only (SwiftUI views)
- **Services**: Business logic (ContentManager, FormattingService, etc.)

### Rationale
- Clear separation of concerns
- Testable business logic in services
- Reactive UI updates through @Published properties
- Scalable for additional features

### Consequences
- ✅ Highly testable architecture
- ✅ Clear data flow
- ✅ Easy to add new features
- ⚠️ More files and complexity than simple approaches

---

## ADL-003: NSViewRepresentable for Text Editing
**Date**: 2025-08-18  
**Status**: ✅ Implemented  
**Context**: SwiftUI's native text editing is insufficient for advanced features

### Decision
Use NSViewRepresentable wrapper around NSTextView for sophisticated text editing:
- Custom NSTextView subclass for behavior overrides
- Coordinator pattern for delegation
- Proper text system component setup

### Rationale
- Access to full NSTextView capabilities
- Cursor customization and advanced text features
- Performance optimization for large documents
- Integration with existing AppKit text infrastructure

### Consequences
- ✅ Full control over text editing behavior
- ✅ Advanced features like Focus Mode possible
- ⚠️ Complexity in SwiftUI/AppKit bridging
- ⚠️ Potential for circular update loops

### Best Practices Established
```swift
// Always set up text system components explicitly
let textContainer = NSTextContainer()
let layoutManager = NSLayoutManager()
let textStorage = NSTextStorage()

textStorage.addLayoutManager(layoutManager)
layoutManager.addTextContainer(textContainer)
let textView = CustomTextView(frame: .zero, textContainer: textContainer)
```

---

## ADL-004: Memory Management Strategy
**Date**: 2025-08-18  
**Status**: ✅ Established  
**Context**: Prevent memory leaks in complex delegate/closure patterns

### Decision
Strict memory management rules:
- Always use `[weak self]` in closures
- Implement proper cleanup in `deinit` methods
- Use `weak` references for delegates
- Cancel subscriptions in Combine pipelines

### Rationale
- Prevent retain cycles in complex object graphs
- Ensure proper cleanup when views are deallocated
- Maintain app performance over long sessions

### Implementation Pattern
```swift
class Coordinator: NSObject {
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        // Clean up observers
        NotificationCenter.default.removeObserver(self)
        
        // Cancel subscriptions
        cancellables.removeAll()
        
        // Unregister from services
        FormattingService.shared.unregister(textView)
    }
}
```

---

## ADL-005: Performance-First Text Operations
**Date**: 2025-08-18  
**Status**: ✅ Established  
**Context**: Ensure responsive editing for large documents

### Decision
Performance optimization strategy:
- Debounced syntax highlighting (300ms delay)
- Incremental highlighting of visible ranges only
- Efficient NSString operations over String
- Lazy loading for large documents

### Rationale
- Maintain <16ms keystroke latency
- Support documents up to 100,000+ words
- Smooth 60fps scrolling and editing
- Battery efficiency on laptops

### Implementation Pattern
```swift
func textDidChange(_ notification: Notification) {
    // Immediate updates for critical UI
    updateCharacterCount()
    
    // Debounced updates for expensive operations
    NSObject.cancelPreviousPerformRequests(
        withTarget: self, 
        selector: #selector(performSyntaxHighlighting), 
        object: nil
    )
    perform(#selector(performSyntaxHighlighting), with: nil, afterDelay: 0.3)
}
```

---

## ADL-006: iA Writer Design Philosophy Adoption
**Date**: 2025-08-18  
**Status**: 📋 Planning  
**Context**: Create distraction-free writing experience

### Decision
Adopt iA Writer's core design principles:
- **Radical Simplicity**: "Main feature is not having many features"
- **Focus First**: Every feature serves better writing
- **Typography Excellence**: Beautiful, readable fonts for long sessions
- **Distraction-Free**: UI disappears during writing

### Planned Implementation
- Focus Mode: Sentence/paragraph highlighting
- Zen Mode: Full-screen distraction-free writing
- Custom typography system based on Duospace concept
- Minimal UI that hides during writing

### Success Criteria
- Writing feels effortless and natural
- Users can write for hours without fatigue
- Interface never interrupts writing flow
- Typography is beautiful and highly readable

---

## ADL-007: AI Integration Philosophy
**Date**: 2025-08-18  
**Status**: 📋 Planning  
**Context**: Add AI capabilities without breaking writing flow

### Decision
"AI that enhances, never interrupts" approach:
- Invisible background processing
- Non-intrusive suggestions
- Privacy-first (local processing when possible)
- Context-aware assistance

### Planned Architecture
```swift
protocol AIAssistant {
    func provideSuggestions(for context: WritingContext) async -> [Suggestion]
    func processInBackground(_ content: String) async
    func respectsPrivacy() -> Bool
}
```

### Design Constraints
- Never interrupt writing flow
- Suggestions appear only when helpful
- Complete user control over AI features
- Zero data retention policies

---

## Decision Template

```markdown
## ADL-XXX: [Decision Title]
**Date**: YYYY-MM-DD  
**Status**: [Proposed/Accepted/Implemented/Deprecated]  
**Context**: [Why this decision was needed]

### Decision
[What was decided]

### Rationale  
[Why this decision was made]

### Consequences
[Positive and negative outcomes]

### Implementation
[Code examples or implementation notes]

### Success Criteria
[How to measure if this decision was correct]
```

---

*This ADL should be updated whenever architectural decisions are made or patterns are established.*