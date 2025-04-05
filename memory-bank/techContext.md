# Technology Context - Vibe Writing App

## Development Stack
- **Frontend**: SwiftUI for modern, responsive interface
- **Data Layer**: SwiftData for document storage and management
- **Backend Services**: CloudKit for synchronization across devices
- **AI Integration**: Core ML for on-device processing and OpenAI API for advanced features
- **Architecture**: MVVM pattern with Combine framework for reactive programming

## Frameworks
- SwiftUI for UI components
- SwiftData for local data persistence
- Markdown parsing with AttributedString and custom renderers
- FileManager for document handling
- CloudKit for synchronization
- Core ML for on-device AI processing
- OpenAI API for advanced AI features

## Development Environment
- Xcode 15+
- Swift 5.9+
- macOS Sonoma 14+ (target platform)
- iOS/iPadOS 17+ (future expansion)

## Performance Considerations
- Efficient document rendering for large texts
- Background processing for AI features
- Optimized save/sync operations to prevent UI freezing
- Memory management for large document libraries

## Security & Privacy
- End-to-end encryption for synced documents
- Local processing of sensitive content
- Optional opt-in for AI analysis
- Privacy-first data handling compliant with App Store guidelines

## Technology Stack

### Core Technologies
- **Swift 5.9+**: Primary programming language
- **SwiftUI**: User interface framework
- **SwiftData**: Data persistence layer (replacement for Core Data)
- **Foundation**: Apple's fundamental library for data types and collections
- **Combine**: Reactive programming framework for handling asynchronous events

### Architecture
- **Model-View-ViewModel (MVVM)**: Primary architectural pattern
- **SwiftData Entity Models**: Document, Project, DocumentSection, AppSettings, etc.
- **ViewModels**: State management and business logic for views
- **SwiftUI Views**: Declarative UI components
- **Environment Objects**: For dependency injection and state sharing

### Key Dependencies
- No external dependencies currently - using only Apple frameworks
- Will evaluate options for rich text editing and AI integration

## Development Environment
- **Xcode 15+**: Primary IDE
- **macOS 14+**: Development and target platform
- **Swift Package Manager**: Dependency management (if needed)
- **GitHub**: Version control (presumed)

## Redesign Technical Requirements

### UI Components for Scrivener-Like Interface
- **NSViewRepresentable**: Will be required for custom NSTextView integration
- **HSplitView**: For creating the three-panel layout (binder, editor, inspector)
- **NSTextView/TextKit 2**: For enhanced rich text editing capabilities
- **NSTableView/NSOutlineView**: For outliner view implementation
- **Drag and Drop API**: For content reorganization in binder and corkboard
- **Custom Collection View**: For corkboard implementation

### Rich Text Implementation
- **NSTextStorage/NSAttributedString**: For rich text content management
- **TextKit 2**: For advanced text handling and formatting
- **NSTextView**: For custom editor implementation beyond TextEditor capabilities
- **Custom Text Attachments**: For inline images and other content

### AI Integration Options
- **OpenAI API**: Potential for GPT integration
- **Apple MLCore**: For on-device processing where appropriate
- **Custom Context Management**: To track and provide document context to AI
- **Prompt Engineering System**: For crafting effective AI interactions
- **Message Handler**: For processing and displaying AI responses

### Data Model Enhancements
- **Extended Metadata**: Additional SwiftData attributes for Scrivener-like functionality
- **Relationship Management**: Enhanced parent-child relationships for documents
- **Snapshot System**: Version control implementation using duplicate entities
- **Custom Attribute Types**: For specialized metadata fields
- **Compilation Settings**: Data structures for export configuration

## Implementation Challenges

### Technical Challenges
- **Rich Text Editing**: SwiftUI's TextEditor lacks advanced formatting capabilities
- **Three-Panel Layout**: Requires custom implementation beyond NavigationSplitView
- **Document Compilation**: Need custom export system for multiple formats
- **Performance**: Ensuring responsive UI with large document collections
- **Context Management**: Providing relevant document context to AI without token overflow

### Integration Points
- **NSViewRepresentable**: Bridge between AppKit and SwiftUI for rich text editing
- **AI API Integration**: Connection to chosen LLM provider
- **Export System**: Integration with document formats (Word, PDF, etc.)
- **SwiftData Extensions**: Custom attribute types and persistence

## Research Areas

### Priority Research
- **Rich Text Editing in SwiftUI**: Best approaches for implementing advanced editing
- **AI Integration Options**: Evaluating APIs and implementation strategies
- **Performance Optimization**: Techniques for handling large document collections
- **Custom UI Components**: Implementation of corkboard and outliner views
- **Text Compilation**: Strategies for flexible document export

### Technical Decision Points
1. **Rich Text Implementation**: NSTextView vs. WebView vs. custom solution
2. **AI Provider Selection**: OpenAI vs. Anthropic vs. other options
3. **Sync Implementation**: iCloud vs. custom sync solution
4. **Export Strategy**: Direct generation vs. template-based approach
5. **Performance Approach**: Lazy loading vs. pagination vs. virtual scrolling

## Development Challenges

### Data Migration
As we enhance the document model, we'll need careful migration paths to preserve user data.

### Performance Optimization
Working with large projects containing many documents, research items, and complex hierarchies will require performance optimization.

### Backend Services
For the chat and collaboration features, we'll need to:
- Evaluate third-party AI services vs. building custom solutions
- Design secure API communications
- Handle offline/online states gracefully

### Testing
The expanded scope will require:
- More comprehensive unit and integration tests
- Performance testing for large document sets
- UI testing for complex interactions like drag-and-drop

## Future Technical Considerations
- iOS version will require adaptation for smaller screens
- WebSocket or similar real-time protocols for collaboration
- Potential integration with LLM APIs for AI assistant features
- CloudKit integration for seamless syncing across Apple devices
