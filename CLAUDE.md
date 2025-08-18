# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenPage is a macOS document editor and writing application built with SwiftUI and SwiftData. It features hierarchical document organization, AI-powered writing assistance, and project management capabilities for writers.

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
├── ViewModels/       # View state management
├── Views/            # SwiftUI views and components
│   └── Components/   # Reusable UI components
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

## Entitlements and Sandboxing

The app uses macOS sandboxing with:
- `com.apple.security.app-sandbox`: Enabled for App Store compliance
- `com.apple.security.files.user-selected.read-only`: User-selected file access for document imports