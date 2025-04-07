# Tasks

## Current Active Tasks

### 🔥 Emergency Tasks
- **Create Scrivener-like UI redesign plan** - Develop detailed implementation plan with milestones
  - Create component diagram for Scrivener-like three-panel layout
  - Define component responsibilities and interactions
  - Determine needed model enhancements for Scrivener features
- **Design AI chat integration architecture** - Determine API, interface, and context management
  - Research available LLM options and APIs
  - Design chat UI component as inspector panel or floating window
  - Create context collection protocol for document awareness

### 🚀 Priority Tasks
- **Three-panel layout implementation** - Create binder, editor, and inspector panels
  - Modify MainView.swift to use HSplitView instead of NavigationSplitView
  - Create InspectorView component with multiple tabs
  - Enhance SidebarView to function as proper binder
- **Rich text formatting toolbar** - Implement complete formatting capabilities
  - Create TextFormatToolbar component for font, style, alignment controls
  - Implement NSAttributedString support for rich text 
  - Add additional text styling options matching Scrivener
- **Template selection system** - Create project templates matching Scrivener functionality
  - Add project template models and UI
  - Create template gallery with previews
  - Implement template-based project creation flow

### 🔄 In Progress
- ✅ **Fix SwiftData migration error** - COMPLETED
  - Made `useHierarchicalEditing` property optional with default value
  - Added migration options to ModelConfiguration
  - Deleted existing database file to ensure clean start
- ✅ **Implement hierarchical document structure** - COMPLETED
- ✅ **Project restructuring and renaming** - PARTIALLY COMPLETED
  - ✅ Created comprehensive restructuring plan in activeContext.md
  - ✅ Created and executed scripts to identify duplicate files (find_duplicates.sh)
  - ✅ Created and executed script to consolidate files (consolidate_files.sh)
  - ✅ Updated OpenPageApp.swift to initialize new database
  - ✅ Created OpenPage.entitlements
  - ✅ Cleaned up original files with backup (cleanup.sh)
  - ✅ Added Conversation model to fix build error in OpenPageApp.swift
  - ✅ Fixed SweetPad/Cursor configuration to use new scheme name
  - 🔄 Pending: Final testing and verification of all features
- ✅ **Fix dark mode inconsistencies** - COMPLETED
  - Added adaptable color scheme support for inspector views
  - Created centralized Color+Theme extension for app-wide color consistency
  - Fixed white backgrounds in dark mode for chat and inspector views
  - Ensured proper text color contrast in dark mode
- **Design advanced metadata UI** - Create schema for extended document properties
  - Design Inspector panel mockups
  - Expand Document and DocumentSection models for additional metadata
  - Create UI components for metadata editing

### 📅 Upcoming
- **Implement binder navigation** - Create hierarchical document browser
  - Add drag-and-drop rearrangement of documents and folders
  - Implement collapsible document groups
  - Create visual cues for document status and type
- **Build inspector panel** - Create multi-tabbed metadata and notes panel
  - Create tabs for metadata, notes, references
  - Implement custom metadata fields and editing
  - Add support for document snapshots
- **Develop corkboard interface** - Design visual card-based organization system
  - Create card UI for document synopsis
  - Implement grid layout with customizable card size
  - Add drag-and-drop reordering of cards
- **Create outliner view** - Implement hierarchical outline view of document
  - Design table-based interface with expandable rows
  - Add column customization for different metadata
  - Create drag-and-drop outline reorganization
- **Implement AI assistant panel** - Design chat interface for AI writing help
  - Build floating or docked chat UI
  - Create prompt management system
  - Implement context-aware assistance based on current selection

## Implementation Plan

### Phase 1: Core UI Restructuring (1-2 weeks)
1. **Replace NavigationSplitView with HSplitView (1 day)**
   - Modify MainView.swift to create three-panel layout
   - Keep basic functionality working during transition

2. **Create Enhanced Binder (2-3 days)**
   - Expand SidebarView with folder support
   - Add custom project icons and status indicators
   - Implement drag-and-drop reorganization

3. **Develop Inspector Panel (2-3 days)**
   - Create basic inspector panel structure
   - Implement metadata tab with core fields
   - Add notes tab for document annotations

4. **Implement Rich Text Editor (3-4 days)**
   - Replace TextEditor with NSTextView-based solution
   - Create formatting toolbar with style controls
   - Add support for headers, lists, and basic formatting

### Phase 2: Advanced Views (2-3 weeks)
1. **Corkboard Interface (4-5 days)**
   - Design card-based UI for document sections
   - Implement grid layout with reordering
   - Add synopsis editing and visual indicators

2. **Outliner View (3-4 days)**
   - Create outline table structure
   - Implement hierarchy visualization
   - Add metadata columns and filters

3. **Split Editor and Composition Mode (3-4 days)**
   - Add support for multiple editor panes
   - Create distraction-free composition mode
   - Implement editor synchronization

### Phase 3: AI Integration (2-3 weeks)
1. **Chat UI Component (3-4 days)**
   - Design and implement chat interface
   - Create message handling and display
   - Add support for message types and formatting

2. **Context Collection (2-3 days)**
   - Implement document context gathering
   - Create prompt engineering system
   - Add document awareness to chat

3. **LLM Integration (3-4 days)**
   - Select and connect to LLM API
   - Create request and response handling
   - Implement error recovery and fallbacks

4. **Writing Assistance Features (3-4 days)**
   - Add style suggestions and improvements
   - Implement research and fact-checking
   - Create character and plot development tools

### Phase 4: Polish & Integration (2-3 weeks)
1. **Refinement and Performance (3-4 days)**
   - Address layout issues and edge cases
   - Optimize performance for large documents
   - Implement caching for better responsiveness

2. **Export and Compile System (3-4 days)**
   - Create multiple format export options
   - Add compile settings and customization
   - Implement template-based output

3. **Final Integration and Testing (4-5 days)**
   - Ensure all components work together seamlessly
   - Test with large document collections
   - Add comprehensive error handling

## Completed Tasks

### Core Architecture
- ✅ **Project Setup and Data Models** - Basic SwiftData models and views
- ✅ **Core Document Structure** - Document model with content and metadata
- ✅ **Template System** - Template-based document creation
- ✅ **Hierarchical Document Structure** - Sections with parent-child relationships
- ✅ **Basic Editor Interface** - Text editing functionality

### Bug Fixes
- ✅ **Timer-related SwiftData errors** - Fixed with @Transient attribute
- ✅ **DocumentSection immutability issues** - Updated child management methods
- ✅ **Build errors in Document model** - Resolved property handling issues
- ✅ **SweetPad extension simctl access error** - Fixed by redirecting xcode-select to Xcode.app
- ✅ **ValidateDevelopmentAssets build failure** - Fixed by moving Preview Content to correct location

## Future Tasks

### Phase 1: Core UI Restructuring (1-2 weeks)
- **Three-panel layout** - Implement binder, editor, inspector design
- **Binder component** - Create hierarchical navigation sidebar
- **Rich text editor** - Develop advanced formatting capabilities
- **Project templates** - Create system for different writing types
- **Enhanced metadata** - Extend document model for additional properties

### Phase 2: Advanced Views (2-3 weeks)
- **Corkboard interface** - Visual organization of document sections
- **Outliner view** - Hierarchical document planning
- **Split editor view** - Side-by-side document editing
- **Composition mode** - Distraction-free writing environment
- **Inspector tabs** - Multiple metadata and note views

### Phase 3: AI Integration (2-3 weeks)
- **Chat component** - Build UI for AI interactions
- **Context management** - Create system to track current writing context
- **LLM API integration** - Connect to chosen AI provider
- **Writing assistance** - Implement suggestions and improvements
- **Research tools** - Create fact-checking and information retrieval
- **Creative assistance** - Build character and plot development tools

### Phase 4: Polish & Advanced Features (2-3 weeks)
- **Keyboard shortcuts** - Implement industry-standard shortcuts
- **Compile system** - Create export with multiple format options
- **Versioning** - Implement document snapshots and history
- **Writing goals** - Build statistics and progress tracking
- **Theming** - Add light/dark and custom theme options
- **Cloud sync** - Implement backup and synchronization
