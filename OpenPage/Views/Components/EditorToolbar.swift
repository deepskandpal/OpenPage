import SwiftUI

/// Modern editor toolbar with formatting controls and settings
struct EditorToolbar: View {
    @Binding var theme: EditorTheme
    @Binding var fontSize: Double
    @Binding var lineHeight: Double
    @Binding var isMarkdownMode: Bool
    let onFormat: (FormattingAction) -> Void
    
    @State private var showThemePopover: Bool = false
    @State private var showFontPopover: Bool = false
    @State private var activeFormats: Set<FormattingAction> = []
    
    // Timer to update active formatting states
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 16) {
            // Text Formatting Group
            HStack(spacing: 8) {
                FormattingButton(
                    icon: "bold",
                    tooltip: "Bold (⌘B)",
                    isActive: activeFormats.contains(.bold),
                    action: { onFormat(.bold) }
                )
                
                FormattingButton(
                    icon: "italic",
                    tooltip: "Italic (⌘I)",
                    isActive: activeFormats.contains(.italic),
                    action: { onFormat(.italic) }
                )
                
                FormattingButton(
                    icon: "strikethrough",
                    tooltip: "Strikethrough",
                    isActive: activeFormats.contains(.strikethrough),
                    action: { onFormat(.strikethrough) }
                )
                
                FormattingButton(
                    icon: "curlybraces",
                    tooltip: "Inline Code",
                    isActive: activeFormats.contains(.code),
                    action: { onFormat(.code) }
                )
                
                FormattingButton(
                    icon: "link",
                    tooltip: "Insert Link",
                    isActive: activeFormats.contains(.link),
                    action: { onFormat(.link) }
                )
            }
            
            Divider()
                .frame(height: 20)
            
            // Headers Group
            HStack(spacing: 8) {
                FormattingButton(
                    text: "H1",
                    tooltip: "Heading 1",
                    isActive: activeFormats.contains(.header1),
                    action: { onFormat(.header1) }
                )
                
                FormattingButton(
                    text: "H2",
                    tooltip: "Heading 2",
                    isActive: activeFormats.contains(.header2),
                    action: { onFormat(.header2) }
                )
                
                FormattingButton(
                    text: "H3",
                    tooltip: "Heading 3",
                    isActive: activeFormats.contains(.header3),
                    action: { onFormat(.header3) }
                )
            }
            
            Divider()
                .frame(height: 20)
            
            // Lists Group
            HStack(spacing: 8) {
                FormattingButton(
                    icon: "list.bullet",
                    tooltip: "Bullet List",
                    isActive: activeFormats.contains(.bulletList),
                    action: { onFormat(.bulletList) }
                )
                
                FormattingButton(
                    icon: "list.number",
                    tooltip: "Numbered List",
                    isActive: activeFormats.contains(.numberedList),
                    action: { onFormat(.numberedList) }
                )
                
                FormattingButton(
                    icon: "quote.bubble",
                    tooltip: "Quote Block",
                    isActive: activeFormats.contains(.quote),
                    action: { onFormat(.quote) }
                )
            }
            
            Spacer()
            
            // Editor Settings Group
            HStack(spacing: 8) {
                // Markdown Toggle
                Toggle("", isOn: $isMarkdownMode)
                    .toggleStyle(SwitchToggleStyle(tint: theme.accentColor))
                    .scaleEffect(0.8)
                    .help("Enable Markdown Syntax Highlighting")
                
                Text("MD")
                    .font(.caption2)
                    .foregroundColor(isMarkdownMode ? theme.accentColor : theme.secondaryTextColor)
                
                Divider()
                    .frame(height: 20)
                
                // Font Settings
                Button(action: { showFontPopover.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "textformat.size")
                        Text("\(Int(fontSize))")
                            .font(.caption)
                            .monospacedDigit()
                    }
                }
                .buttonStyle(.borderless)
                .foregroundColor(theme.textColor)
                .help("Font Settings")
                .popover(isPresented: $showFontPopover) {
                    FontSettingsPopover(
                        fontSize: $fontSize,
                        lineHeight: $lineHeight,
                        theme: theme
                    )
                    .frame(width: 220, height: 120)
                }
                
                // Theme Selector
                Button(action: { showThemePopover.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "paintbrush")
                        Text(theme.displayName)
                            .font(.caption)
                    }
                }
                .buttonStyle(.borderless)
                .foregroundColor(theme.textColor)
                .help("Editor Theme")
                .popover(isPresented: $showThemePopover) {
                    ThemeSelectionPopover(
                        selectedTheme: $theme
                    )
                    .frame(width: 200, height: 180)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(theme.backgroundColor.opacity(0.8))
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(theme.secondaryTextColor.opacity(0.3)),
            alignment: .bottom
        )
        .onReceive(timer) { _ in
            updateActiveFormats()
        }
    }
    
    private func updateActiveFormats() {
        let allActions: [FormattingAction] = [
            .bold, .italic, .strikethrough, .code, .link,
            .header1, .header2, .header3,
            .bulletList, .numberedList, .quote
        ]
        
        var newActiveFormats: Set<FormattingAction> = []
        for action in allActions {
            if FormattingService.shared.isFormattingActive(action) {
                newActiveFormats.insert(action)
            }
        }
        
        activeFormats = newActiveFormats
    }
}

// MARK: - Formatting Button

struct FormattingButton: View {
    let icon: String?
    let text: String?
    let tooltip: String
    let isActive: Bool
    let action: () -> Void
    
    init(icon: String, tooltip: String, isActive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.text = nil
        self.tooltip = tooltip
        self.isActive = isActive
        self.action = action
    }
    
    init(text: String, tooltip: String, isActive: Bool = false, action: @escaping () -> Void) {
        self.icon = nil
        self.text = text
        self.tooltip = tooltip
        self.isActive = isActive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                } else if let text = text {
                    Text(text)
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .frame(width: 24, height: 24)
            .foregroundColor(isActive ? .white : .primary)
        }
        .buttonStyle(.borderless)
        .help(tooltip)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isActive ? Color.accentColor : Color.clear)
        )
        .onHover { isHovered in
            // Add hover effect if needed
        }
    }
}

// MARK: - Font Settings Popover

struct FontSettingsPopover: View {
    @Binding var fontSize: Double
    @Binding var lineHeight: Double
    let theme: EditorTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Font Settings")
                .font(.headline)
                .foregroundColor(theme.textColor)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Size:")
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                    
                    Spacer()
                    
                    Text("\(Int(fontSize))pt")
                        .font(.caption)
                        .foregroundColor(theme.textColor)
                        .monospacedDigit()
                }
                
                Slider(value: $fontSize, in: 12...24, step: 1)
                    .accentColor(theme.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Line Height:")
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                    
                    Spacer()
                    
                    Text("\(lineHeight, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(theme.textColor)
                        .monospacedDigit()
                }
                
                Slider(value: $lineHeight, in: 1.2...2.0, step: 0.1)
                    .accentColor(theme.accentColor)
            }
        }
        .padding()
        .background(theme.backgroundColor)
    }
}

// MARK: - Theme Selection Popover

struct ThemeSelectionPopover: View {
    @Binding var selectedTheme: EditorTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Editor Theme")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 8)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(EditorTheme.allCases, id: \.self) { theme in
                    ThemePreviewCard(
                        theme: theme,
                        isSelected: selectedTheme == theme
                    ) {
                        selectedTheme = theme
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Theme Preview Card

struct ThemePreviewCard: View {
    let theme: EditorTheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                // Theme preview
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(theme.textColor.opacity(0.3), lineWidth: 0.5)
                    )
                    .frame(height: 30)
                    .overlay(
                        HStack(spacing: 2) {
                            Rectangle()
                                .fill(theme.textColor)
                                .frame(width: 8, height: 2)
                            Rectangle()
                                .fill(theme.accentColor)
                                .frame(width: 4, height: 2)
                            Rectangle()
                                .fill(theme.secondaryTextColor)
                                .frame(width: 6, height: 2)
                        }
                    )
                
                // Theme name
                Text(theme.displayName)
                    .font(.caption2)
                    .foregroundColor(isSelected ? theme.accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var theme = EditorTheme.system
    @Previewable @State var fontSize = 16.0
    @Previewable @State var lineHeight = 1.6
    @Previewable @State var isMarkdownMode = true
    
    return EditorToolbar(
        theme: $theme,
        fontSize: $fontSize,
        lineHeight: $lineHeight,
        isMarkdownMode: $isMarkdownMode,
        onFormat: { _ in }
    )
    .frame(width: 800)
}