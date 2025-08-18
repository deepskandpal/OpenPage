# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenPage is a macOS document editor and writing application built with SwiftUI and SwiftData. **Our vision is to create "iA Writer + AI"** - combining iA Writer's legendary distraction-free writing experience with intelligent AI assistance that enhances without interrupting.

### Design Philosophy
- **Radical Simplicity**: Remove all distractions from writing (inspired by iA Writer)
- **AI Enhancement**: Intelligent assistance that works invisibly in the background
- **Focus First**: Every feature serves the goal of better writing
- **Writer's Privacy**: AI processing with complete data privacy

### Key Features (Current & Planned)
- ✅ Dual-mode markdown editor (rich text ↔ syntax view)
- ✅ Distraction-free writing interface with proper typography
- ✅ AI-powered writing assistance with multiple providers
- 🚧 Focus Mode (iA Writer style sentence highlighting)
- 🚧 Syntax Control (weak verb/filler word detection)
- 📋 Wikilinks and knowledge management
- 📋 Cross-platform iOS companion app

**See [docs/PROJECT_PLAN.md](./docs/PROJECT_PLAN.md) for complete roadmap with epics, sprints, and detailed implementation plan.**
**See [docs/DEVELOPMENT_GUIDE.md](./docs/DEVELOPMENT_GUIDE.md) for best practices, architecture patterns, and common pitfalls.**

## 🎯 **Session Continuity System**

### **CRITICAL: Always Start New Sessions With This Checklist**

#### **1. Review Current State**
- [ ] Read [docs/SESSION_STATE.md](./docs/SESSION_STATE.md) to understand current context
- [ ] Read [docs/PROJECT_PLAN.md](./docs/PROJECT_PLAN.md) to understand current epic/sprint
- [ ] Read [docs/DEVELOPMENT_GUIDE.md](./docs/DEVELOPMENT_GUIDE.md) for architecture patterns  
- [ ] Check todo list for current tasks
- [ ] Review recent git commits to understand what was last implemented

#### **2. Validate Against Standards**
Before making ANY code changes:
- [ ] Does this follow the MVVM + Services pattern?
- [ ] Does this maintain single source of truth for content?
- [ ] Does this avoid circular update loops?
- [ ] Does this use proper memory management (weak references)?
- [ ] Does this follow the file organization structure?

#### **3. Implementation Requirements**
- [ ] Use TodoWrite tool to track all work
- [ ] Follow the exact architecture shown in [docs/DEVELOPMENT_GUIDE.md](./docs/DEVELOPMENT_GUIDE.md)
- [ ] Test build after each significant change
- [ ] Update CLAUDE.md if new patterns are established
- [ ] Document architectural decisions in [docs/ARCHITECTURE_DECISION_LOG.md](./docs/ARCHITECTURE_DECISION_LOG.md)
- [ ] Update [docs/SESSION_STATE.md](./docs/SESSION_STATE.md) with progress and next steps

## 📋 **Required Reading for New Sessions**

### **Before Starting ANY Development:**
1. **[docs/SESSION_STATE.md](./docs/SESSION_STATE.md)** - Current status, priorities, and technical debt
2. **[docs/PROJECT_PLAN.md](./docs/PROJECT_PLAN.md)** - Overall roadmap and current epic/sprint  
3. **[docs/DEVELOPMENT_GUIDE.md](./docs/DEVELOPMENT_GUIDE.md)** - Architecture patterns and best practices
4. **[docs/ARCHITECTURE_DECISION_LOG.md](./docs/ARCHITECTURE_DECISION_LOG.md)** - Record of all architectural decisions

### **Development Workflow:**
1. **Read** [docs/SESSION_STATE.md](./docs/SESSION_STATE.md) to understand current context
2. **Plan** next tasks based on [docs/PROJECT_PLAN.md](./docs/PROJECT_PLAN.md) priorities
3. **Implement** following [docs/DEVELOPMENT_GUIDE.md](./docs/DEVELOPMENT_GUIDE.md) patterns
4. **Document** any architectural decisions in [docs/ARCHITECTURE_DECISION_LOG.md](./docs/ARCHITECTURE_DECISION_LOG.md)
5. **Update** [docs/SESSION_STATE.md](./docs/SESSION_STATE.md) with progress and issues
6. **Test** build and functionality before ending session

### **Quality Gates:**
Every code change must pass these checks:
- ✅ Follows MVVM + Services pattern from [docs/DEVELOPMENT_GUIDE.md](./docs/DEVELOPMENT_GUIDE.md)
- ✅ Uses proper memory management (weak references)  
- ✅ Avoids circular update loops
- ✅ Maintains single source of truth for content
- ✅ Includes proper error handling and cleanup
- ✅ Updates are tracked in TodoWrite tool

## Development Commands

### Building and Running
- **Build and run**: Open the project in Xcode and use `Cmd+R`, or use `xcodebuild` from command line
- **Build only**: `xcodebuild -project OpenPage.xcodeproj -scheme OpenPage -configuration Debug build`
- **Clean build**: `xcodebuild clean` or use Xcode's Product > Clean Build Folder

### Testing
- **Run all tests**: `xcodebuild test -project OpenPage.xcodeproj -scheme OpenPage -destination 'platform=macOS'`
- **Run UI tests**: Target `OpenPageUITests` specifically in Xcode or via xcodebuild

## Architecture Overview

### Core Data Models (SwiftData)
- **Document**: Main content model with hierarchical section support, version tracking, writing goals, and metadata
- **Project**: Container for related documents with organization features
- **DocumentSection**: Hierarchical content structure for complex documents
- **AppSettings**: Application preferences and configuration
- **ChatMessage/Conversation**: AI assistant conversation history

### Application Structure
- **OpenPageApp.swift**: Main app entry point with SwiftData container setup and menu commands
- **MainView**: Primary application interface using HSplitView layout with panels
- **AppState**: Centralized state management using ObservableObject pattern
- **AppStateManager**: Global singleton for menu command coordination

### Panel Architecture
The application uses a panel-based layout:
- **BinderPanel**: Document/project organization and navigation
- **EditorPanel**: Main content editing interface
- **InspectorPanel**: Document metadata and AI assistant
- **AIAssistantPanel**: Integrated AI writing assistance

### Services Layer
- **DocumentService**: Document CRUD operations and auto-save management
- **AIService**: Multi-provider AI integration (Claude, OpenAI, Gemini) with task-specific routing
- **FormattingService**: Text formatting operations for toolbar buttons
- **MarkdownRenderer**: Bidirectional conversion between markdown and rich text
- **ContentManager**: Dual-mode display management (rich text ↔ markdown syntax)
- **ExportService**: Document export functionality
- **APIKeyManager**: Secure API key storage and management

### AI Integration
- **Provider Architecture**: Pluggable AI providers with standardized interfaces
- **Task-Based Routing**: Automatic provider selection based on writing task type
- **Writing Task Types**: Creative, technical, analysis, brainstorming, editing, research

## Key Implementation Patterns

### State Management
- Uses `@StateObject` and `@ObservableObject` for reactive UI updates
- Centralized app state through `AppState` class
- Menu commands coordinated via `AppStateManager` singleton

### Data Persistence
- SwiftData models with proper relationships and cascade delete rules
- In-memory preview containers for SwiftUI previews
- Auto-save functionality with configurable intervals

### Hierarchical Documents
- Documents can be flat or hierarchical with `DocumentSection` trees
- Automatic conversion between flat and hierarchical structures
- Recursive content aggregation for word counts and combined content

### UI Architecture
- Component-based design with reusable view components
- Sheet-based modal presentations for creation flows
- Toolbar and menu integration with keyboard shortcuts

## File Organization

```
OpenPage/
├── Models/           # SwiftData models and data structures
├── Services/         # Business logic and external integrations
│   ├── FormattingService.swift      # Text formatting operations
│   ├── MarkdownRenderer.swift       # Markdown ↔ rich text conversion
│   ├── ContentManager.swift         # Dual-mode display management
│   └── AIService.swift              # AI provider integration
├── ViewModels/       # View state management
├── Views/            # SwiftUI views and components
│   └── Components/   # Reusable UI components
│       ├── ModernTextEditor.swift   # Dual-mode text editor
│       ├── ModernEditorView.swift   # Main editor container
│       └── EditorToolbar.swift      # Formatting toolbar
└── Extensions/       # Swift extensions
```

## Development Guidelines

### Adding New Features
1. Update relevant models in `Models/` directory
2. Add business logic to appropriate service in `Services/`
3. Create view model if complex state management needed
4. Implement UI components in `Views/` hierarchy
5. Update `AppState` for centralized state coordination

### AI Provider Integration
- Implement `AIProvider` protocol for new AI services
- Add provider type to `AIProviderType` enum
- Register in `AIService` provider factory method
- Configure task-specific routing in `preferredProviderForTask`

### Document Structure Extensions
- Extend `DocumentSection` model for new section types
- Update hierarchical conversion logic in `Document` model
- Implement UI components for new section types in editor

### Markdown & Text Editing
- **ModernTextEditor**: Dual-mode text editor supporting rich text and markdown syntax views
- **ContentManager**: Manages mode switching and content synchronization
- **MarkdownRenderer**: Handles conversion between markdown and NSAttributedString
- **FormattingService**: Provides toolbar button functionality for both display modes

### iA Writer-Inspired Features
- Focus Mode: Highlight current sentence/paragraph while dimming others
- Syntax Control: Identify and highlight weak verbs, filler words, repetitive phrases
- Distraction-free interface: Minimal UI that disappears during writing
- Typography excellence: Beautiful, readable fonts optimized for long writing sessions

## Entitlements and Sandboxing

The app uses macOS sandboxing with:
- `com.apple.security.app-sandbox`: Enabled for App Store compliance
- `com.apple.security.files.user-selected.read-only`: User-selected file access for document imports