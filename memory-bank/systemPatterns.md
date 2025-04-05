# System Architecture - Vibe Writing App

## Core Components

### 1. Document Engine
- Document model with rich text and markdown support
- Versioning system for history and snapshots
- Change tracking and conflict resolution
- Export/import capabilities for various formats

### 2. User Interface Layer
- Editor view with customizable typography and themes
- Split view for markdown editing and preview
- Distraction-free focus mode
- Command palette (Cursor-inspired) for quick actions
- Sidebar for document organization

### 3. Data Management
- SwiftData models for document storage
- CloudKit integration for sync
- Local caching for offline capability
- Background saving and version control

### 4. AI Assistant System
- Text analysis for grammar and style suggestions
- Content expansion and summarization capabilities
- Research assistance with relevant information
- Context-aware suggestions that appear only when needed

### 5. Theme Engine
- Light/dark mode support with system integration
- Custom theme creation and sharing
- Font management with dynamic type support
- Color scheme customization

## Architecture Patterns

### MVVM Architecture
- **Models**: Document, Project, Settings objects
- **ViewModels**: DocumentViewModel, ProjectListViewModel, etc.
- **Views**: EditorView, SidebarView, SettingsView, etc.

### Reactive Programming
- Combine publishers for real-time UI updates
- SwiftUI state management
- Document change observation

### Services Layer
- DocumentService for file operations
- SyncService for CloudKit integration
- AIService for machine learning features
- AnalyticsService for optional usage tracking

# System Patterns

## Architecture

The application follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Core data structures using SwiftData
- **Views**: SwiftUI interface components
- **ViewModels**: Logic layer connecting models and views

## Data Models

### Core Entities
- **Document**: Writing content with metadata and formatting
  - Adding hierarchical structure with parent-child relationships
  - Will support sections, chapters, and nested organization
- **Project**: Collection of related documents
- **AppSettings**: User preferences and application configuration
- **DocumentTemplate**: Templates for different document types
- **ResearchItem**: Supporting materials linked to documents (pending implementation)

### New Planned Models
- **DocumentSection**: Represents a part of a document in hierarchical structure
- **ResearchItem**: Stores references, images, PDFs, and notes
- **Snapshot**: Version history for document content
- **ChatMessage**: For storing conversation history with AI or collaborators

## Component Organization

### Views
- **MainView**: Root navigation and primary interface
- **SidebarView**: Project and document navigation
- **EditorView**: Document editing and formatting
- **SettingsView**: Application configuration
- **TemplateSelectionView**: Template gallery for new documents
- **EnhancedDocumentCreationView**: Multi-tab document setup
- **CorkboardView**: Visual document planning interface (planned)
- **OutlinerView**: Structural document planning interface (planned)
- **ResearchView**: Research materials management (planned)
- **ChatView**: AI assistant and collaboration interface (planned)

### ViewModels
- **DocumentViewModel**: Document state and operations
- **ProjectViewModel**: Project management
- **SettingsViewModel**: User preferences

## Patterns & Practices

### Data Flow
- One-way data binding with SwiftUI's state management
- Centralized persistence through SwiftData
- Observable state for real-time updates

### UI Components
- Reusable view components
- Compositional design for complex interfaces
- Adaptive layouts for different screen sizes

### State Management
- `@State` for view-local state
- `@StateObject` for view model instances
- `@ObservedObject` for passed view models
- `@Environment` for global context
- `@Query` for SwiftData access

## Technical Decisions

- Using SwiftData for persistence rather than Core Data for better SwiftUI integration
- Native macOS application with potential for future iOS version
- Custom templating system for document flexibility
- Will implement hierarchical document structure similar to Scrivener
- Planning to add research integration with the ability to store various media types
- Will implement a dual-pane view for side-by-side document and research viewing
- Considering backend options for chat functionality and collaboration
- Planning snapshot system for version control
