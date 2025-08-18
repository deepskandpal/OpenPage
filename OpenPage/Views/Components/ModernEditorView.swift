import SwiftUI
import AppKit

/// Modern, feature-rich text editor inspired by Typora, Bear, and Notion
struct ModernEditorView: View {
    @Binding var content: String
    @Binding var focusMode: WritingFocusMode
    
    @State private var editorTheme: EditorTheme = .system
    @State private var fontSize: Double = 16
    @State private var lineHeight: Double = 1.6
    @State private var showWordCount: Bool = true
    @State private var showReadingTime: Bool = true
    @State private var isMarkdownMode: Bool = true // Default to markdown for better rendering
    @State private var showToolbar: Bool = true
    
    @FocusState private var isEditorFocused: Bool
    
    // Writing statistics
    private var wordCount: Int {
        content.split(separator: " ").count
    }
    
    private var characterCount: Int {
        content.count
    }
    
    private var readingTime: Int {
        max(1, wordCount / 200) // Average reading speed: 200 words per minute
    }
    
    private var lineCount: Int {
        content.components(separatedBy: .newlines).count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor Toolbar
            if showToolbar && focusMode != .zen && focusMode != .distraction_free {
                EditorToolbar(
                    theme: $editorTheme,
                    fontSize: $fontSize,
                    lineHeight: $lineHeight,
                    isMarkdownMode: $isMarkdownMode,
                    onFormat: handleFormatting
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Main Editor Area
            ZStack {
                // Background
                editorTheme.backgroundColor
                    .ignoresSafeArea()
                
                // Editor Content - Simplified layout
                ModernTextEditor(
                    content: $content,
                    theme: editorTheme,
                    fontSize: fontSize,
                    lineHeight: lineHeight,
                    isMarkdownMode: isMarkdownMode,
                    focusMode: focusMode,
                    isEditorFocused: $isEditorFocused
                )
                .padding(.horizontal, editorHorizontalPadding)
            }
            
            // Status Bar
            if showWordCount || showReadingTime {
                EditorStatusBar(
                    wordCount: wordCount,
                    characterCount: characterCount,
                    readingTime: readingTime,
                    lineCount: lineCount,
                    showWordCount: showWordCount,
                    showReadingTime: showReadingTime,
                    theme: editorTheme
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: focusMode)
        .animation(.easeInOut(duration: 0.3), value: showToolbar)
        .onAppear {
            setupEditor()
            // Focus the editor when it appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isEditorFocused = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var editorHorizontalPadding: Double {
        switch focusMode {
        case .normal:
            return 40
        case .typewriter:
            return 60
        case .zen, .distraction_free:
            return 80
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupEditor() {
        // Configure editor based on focus mode
        switch focusMode {
        case .zen, .distraction_free:
            showToolbar = false
            showWordCount = false
            showReadingTime = false
        default:
            showToolbar = true
            showWordCount = true
            showReadingTime = true
        }
    }
    
    private func handleFormatting(_ action: FormattingAction) {
        print("DEBUG: ModernEditorView.handleFormatting called with: \(action)")
        // Use ContentManager for dual-mode formatting support
        ContentManager.shared.applyFormatting(action, theme: editorTheme, fontSize: fontSize, lineHeight: lineHeight)
    }
}


// MARK: - Editor Theme

enum EditorTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    case sepia = "sepia"
    case nord = "nord"
    case monokai = "monokai"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        case .sepia: return "Sepia"
        case .nord: return "Nord"
        case .monokai: return "Monokai"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .system:
            return Color(.textBackgroundColor)
        case .light:
            return Color.white
        case .dark:
            return Color(red: 0.12, green: 0.12, blue: 0.12)
        case .sepia:
            return Color(red: 0.98, green: 0.96, blue: 0.90)
        case .nord:
            return Color(red: 0.18, green: 0.20, blue: 0.25)
        case .monokai:
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        }
    }
    
    var textColor: Color {
        switch self {
        case .system:
            return Color(.textColor)
        case .light:
            return Color(red: 0.2, green: 0.2, blue: 0.2)
        case .dark:
            return Color(red: 0.9, green: 0.9, blue: 0.9)
        case .sepia:
            return Color(red: 0.3, green: 0.25, blue: 0.2)
        case .nord:
            return Color(red: 0.85, green: 0.87, blue: 0.91)
        case .monokai:
            return Color(red: 0.97, green: 0.97, blue: 0.95)
        }
    }
    
    var secondaryTextColor: Color {
        textColor.opacity(0.7)
    }
    
    var accentColor: Color {
        switch self {
        case .system:
            return Color.accentColor
        case .light:
            return Color.blue
        case .dark:
            return Color.blue
        case .sepia:
            return Color.brown
        case .nord:
            return Color(red: 0.53, green: 0.75, blue: 0.82)
        case .monokai:
            return Color(red: 0.98, green: 0.82, blue: 0.76)
        }
    }
}

// MARK: - Formatting Actions

enum FormattingAction: Hashable {
    case bold, italic, strikethrough, code, link
    case header1, header2, header3
    case bulletList, numberedList, quote
}

// MARK: - Preview

#Preview {
    @Previewable @State var content = """
    # Sample Document
    
    This is a **sample document** with *italic text* and some `code`.
    
    ## Features
    
    - Modern design
    - Markdown support
    - Multiple themes
    - Writing statistics
    
    > This is a quote block to show how the editor handles different content types.
    
    ```swift
    let example = "Code blocks look great too!"
    ```
    """
    
    @Previewable @State var focusMode = WritingFocusMode.normal
    
    return ModernEditorView(
        content: $content,
        focusMode: $focusMode
    )
    .frame(width: 800, height: 600)
}