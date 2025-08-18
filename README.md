<div align="center">
  <img src="OpenPage/OpenPage.png" alt="OpenPage Logo" width="128" height="128">
  
  # OpenPage
  
  **iA Writer + AI** - A distraction-free, AI-enhanced writing environment that combines iA Writer's legendary simplicity with intelligent writing assistance.
  
  [![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://developer.apple.com/macos/)
  [![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)
  [![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-green.svg)](https://developer.apple.com/swiftui/)
  [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

## Features

### 🎯 **Distraction-Free Writing Experience**
- **Focus Mode**: iA Writer-style sentence/paragraph highlighting with text dimming
- **Zen Mode**: True full-screen writing with no UI distractions
- **Typography Excellence**: Beautiful, readable fonts optimized for long writing sessions
- **Minimal Interface**: UI disappears during writing to maintain flow

### ✍️ **Dual-Mode Text Editor**
- **Rich Text Mode**: Visual formatting (bold, italic, headers) with markdown stored behind scenes
- **Syntax Mode**: Raw markdown editing with intelligent syntax highlighting
- **Seamless Switching**: Toggle between modes instantly while preserving content
- **Live Preview**: Real-time markdown rendering and formatting

### 🤖 **AI Writing Assistant**
- **Invisible Enhancement**: AI suggestions that appear only when helpful
- **Privacy-First**: Local processing when possible, encrypted transmission
- **Context-Aware**: Understands your writing style and document context
- **Multi-Provider Support**: Claude, OpenAI, and Gemini integration

### 🔧 **Advanced Text Features**
- **Syntax Control**: Highlight weak verbs, filler words, and repetitive phrases
- **Wikilinks**: Connect documents with [[double bracket]] linking
- **Smart Formatting**: Intelligent markdown shortcuts and auto-completion
- **Document Organization**: Project-based file management

### 📊 **Writing Analytics** (Planned)
- **Writing Statistics**: Word count, reading time, character analysis
- **Focus Metrics**: Track distraction-free writing sessions
- **Progress Tracking**: Daily writing goals and streak monitoring

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for development)
- API keys for AI services (optional, for AI features)

## Installation

### For Users
1. Download the latest release from the [Releases](../../releases) page
2. Drag OpenPage.app to your Applications folder
3. Launch the application
4. Configure AI providers in Settings (optional)

### For Developers
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/OpenPage.git
   cd OpenPage
   ```

2. **Read the documentation first:**
   - [docs/SESSION_STATE.md](./docs/SESSION_STATE.md) - Current development status
   - [docs/PROJECT_PLAN.md](./docs/PROJECT_PLAN.md) - Complete roadmap
   - [docs/DEVELOPMENT_GUIDE.md](./docs/DEVELOPMENT_GUIDE.md) - Best practices
   - [CLAUDE.md](./CLAUDE.md) - Claude Code guidance

3. Open the project in Xcode:
   ```bash
   open OpenPage.xcodeproj
   ```

4. Build and run the project using `Cmd+R`

## Configuration

### AI Services Setup
To enable AI writing assistance, configure your API keys in the application settings:

1. Open OpenPage preferences (`Cmd+,`)
2. Navigate to the AI Settings tab
3. Enter your API keys for the desired providers:
   - **Claude**: Anthropic API key
   - **OpenAI**: OpenAI API key  
   - **Gemini**: Google AI Studio API key

API keys are stored securely in the macOS Keychain.

## Usage

### Creating Documents
- **New Document**: `Cmd+N` or File → New Document
- **New Project**: `Cmd+Shift+N` or File → New Project
- **From Template**: Choose from built-in document templates

### AI Assistant
- **Quick Chat**: `Cmd+A` to toggle the AI assistant panel
- **New Conversation**: `Cmd+Shift+A` to start a fresh chat
- **Context-Aware**: The AI understands your current document context

### Focus Modes
- Access focus modes from the View menu or toolbar
- Switch between different writing environments based on your needs
- Customize panel visibility for optimal writing experience

### Keyboard Shortcuts
- `Cmd+N`: New Document
- `Cmd+Shift+N`: New Project
- `Cmd+A`: Toggle AI Assistant
- `Cmd+Shift+A`: New AI Chat
- `Cmd+,`: Preferences
- `Cmd+Shift+E`: Export Document

## Architecture

OpenPage follows **iA Writer's design philosophy** with modern Swift technologies:

### **Design Principles**
- **Radical Simplicity**: "The main feature is not having many features"
- **Focus First**: Every feature serves the goal of better writing
- **AI Enhancement**: Intelligent assistance that works invisibly
- **Writer's Privacy**: AI processing with complete data privacy

### **Technical Stack**
- **SwiftUI + AppKit**: Native macOS text editing with NSTextView
- **MVVM + Services**: Clean architecture with clear separation of concerns
- **SwiftData**: Modern data persistence
- **Combine**: Reactive state management

### **Key Components**
- **ContentManager**: Dual-mode display management (rich text ↔ markdown)
- **MarkdownRenderer**: Bidirectional conversion with syntax highlighting
- **FormattingService**: Toolbar button functionality for both modes
- **AI Service Layer**: Multi-provider integration with privacy focus

### **Documentation**
Complete technical documentation is available in the [docs/](./docs/) directory:
- **[Project Plan](./docs/PROJECT_PLAN.md)**: 6 epics, 14 sprints roadmap
- **[Development Guide](./docs/DEVELOPMENT_GUIDE.md)**: Best practices and patterns
- **[Architecture Decisions](./docs/ARCHITECTURE_DECISION_LOG.md)**: Decision history and rationale

## Contributing

We welcome contributions to OpenPage! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code style and conventions
- Development workflow
- Submitting pull requests
- Reporting bugs and feature requests

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and ensure code builds
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Privacy & Security

- **Data Privacy**: All documents are stored locally on your device
- **API Security**: AI API keys are stored securely in macOS Keychain
- **Sandboxing**: App runs in macOS sandbox for enhanced security
- **No Telemetry**: No usage data is collected or transmitted

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Apple's SwiftUI and SwiftData frameworks
- AI integration powered by Anthropic Claude, OpenAI, and Google Gemini
- Icons and design inspired by macOS Human Interface Guidelines

## Support

- **Documentation**: Check the in-app help system
- **Issues**: Report bugs via [GitHub Issues](../../issues)
- **Discussions**: Join the community in [GitHub Discussions](../../discussions)

---

**OpenPage** - Empowering writers with AI-assisted creativity and organization.