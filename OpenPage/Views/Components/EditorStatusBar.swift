import SwiftUI

/// Status bar for the editor showing writing statistics and information
struct EditorStatusBar: View {
    let wordCount: Int
    let characterCount: Int
    let readingTime: Int
    let lineCount: Int
    let showWordCount: Bool
    let showReadingTime: Bool
    let theme: EditorTheme
    
    @State private var showDetailedStats: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Main Statistics
            HStack(spacing: 12) {
                if showWordCount {
                    StatisticView(
                        label: "Words",
                        value: "\(wordCount)",
                        theme: theme
                    )
                }
                
                StatisticView(
                    label: "Characters",
                    value: "\(characterCount)",
                    theme: theme
                )
                
                if showReadingTime {
                    StatisticView(
                        label: "Read Time",
                        value: "\(readingTime) min",
                        theme: theme
                    )
                }
                
                StatisticView(
                    label: "Lines",
                    value: "\(lineCount)",
                    theme: theme
                )
            }
            
            Spacer()
            
            // Additional Info
            HStack(spacing: 12) {
                // Writing Goal Progress (if applicable)
                WritingGoalProgress(
                    currentWords: wordCount,
                    goalWords: 1000, // This would come from app state
                    theme: theme
                )
                
                // Detailed Stats Toggle
                Button(action: { showDetailedStats.toggle() }) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 11))
                        .foregroundColor(theme.secondaryTextColor)
                }
                .buttonStyle(.borderless)
                .help("Detailed Statistics")
                .popover(isPresented: $showDetailedStats) {
                    DetailedStatsPopover(
                        wordCount: wordCount,
                        characterCount: characterCount,
                        readingTime: readingTime,
                        lineCount: lineCount,
                        theme: theme
                    )
                    .frame(width: 280, height: 200)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(theme.backgroundColor.opacity(0.8))
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(theme.secondaryTextColor.opacity(0.3)),
            alignment: .top
        )
    }
}

// MARK: - Statistic View

struct StatisticView: View {
    let label: String
    let value: String
    let theme: EditorTheme
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(theme.secondaryTextColor)
            
            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(theme.textColor)
                .monospacedDigit()
        }
    }
}

// MARK: - Writing Goal Progress

struct WritingGoalProgress: View {
    let currentWords: Int
    let goalWords: Int
    let theme: EditorTheme
    
    private var progress: Double {
        guard goalWords > 0 else { return 0 }
        return min(1.0, Double(currentWords) / Double(goalWords))
    }
    
    var body: some View {
        if goalWords > 0 {
            HStack(spacing: 6) {
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(theme.secondaryTextColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(theme.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 16, height: 16)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
                
                // Goal text
                Text("\(currentWords)/\(goalWords)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.secondaryTextColor)
                    .monospacedDigit()
            }
        }
    }
}

// MARK: - Detailed Stats Popover

struct DetailedStatsPopover: View {
    let wordCount: Int
    let characterCount: Int
    let readingTime: Int
    let lineCount: Int
    let theme: EditorTheme
    
    // Additional calculated statistics
    private var charactersWithSpaces: Int { characterCount }
    private var charactersWithoutSpaces: Int { 
        // This would need the actual text content to calculate properly
        max(0, characterCount - wordCount + 1)
    }
    private var paragraphCount: Int { 
        max(1, lineCount / 3) // Rough estimate
    }
    private var averageWordsPerSentence: Double {
        let sentenceCount = max(1, characterCount / 100) // Rough estimate
        return Double(wordCount) / Double(sentenceCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Writing Statistics")
                .font(.headline)
                .foregroundColor(theme.textColor)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .leading),
                GridItem(.flexible(), alignment: .trailing)
            ], spacing: 8) {
                DetailedStatRow(label: "Words", value: "\(wordCount)", theme: theme)
                DetailedStatRow(label: "Characters", value: "\(charactersWithSpaces)", theme: theme)
                DetailedStatRow(label: "Characters (no spaces)", value: "\(charactersWithoutSpaces)", theme: theme)
                DetailedStatRow(label: "Lines", value: "\(lineCount)", theme: theme)
                DetailedStatRow(label: "Paragraphs", value: "\(paragraphCount)", theme: theme)
                DetailedStatRow(label: "Reading time", value: "\(readingTime) min", theme: theme)
                DetailedStatRow(label: "Avg. words/sentence", value: String(format: "%.1f", averageWordsPerSentence), theme: theme)
            }
            
            Divider()
                .background(theme.secondaryTextColor.opacity(0.3))
            
            // Reading level and complexity (placeholder)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Readability")
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                    
                    Text("Grade 8-9")
                        .font(.caption)
                        .foregroundColor(theme.textColor)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Complexity")
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                    
                    Text("Medium")
                        .font(.caption)
                        .foregroundColor(theme.accentColor)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(theme.backgroundColor)
    }
}

// MARK: - Detailed Stat Row

struct DetailedStatRow: View {
    let label: String
    let value: String
    let theme: EditorTheme
    
    var body: some View {
        Text(label)
            .font(.caption)
            .foregroundColor(theme.secondaryTextColor)
        
        Text(value)
            .font(.caption)
            .foregroundColor(theme.textColor)
            .fontWeight(.medium)
            .monospacedDigit()
    }
}

// MARK: - Preview

#Preview {
    let theme = EditorTheme.system
    
    return VStack(spacing: 0) {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .frame(height: 300)
        
        EditorStatusBar(
            wordCount: 1248,
            characterCount: 6543,
            readingTime: 6,
            lineCount: 42,
            showWordCount: true,
            showReadingTime: true,
            theme: theme
        )
    }
    .frame(width: 800)
}