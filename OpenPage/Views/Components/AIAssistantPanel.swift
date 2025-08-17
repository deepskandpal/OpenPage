import SwiftUI
import SwiftData

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let prompt: String
    let description: String
}

struct AIAssistantPanel: View {
    @ObservedObject var appState: AppState
    @State private var messageText: String = ""
    @State private var isExpanded: Bool = true
    @FocusState private var isMessageFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Panel header
            AIAssistantHeader(
                appState: appState,
                isExpanded: $isExpanded
            )
            
            if isExpanded {
                Divider()
                
                // Main content
                VStack(spacing: 0) {
                    // Writing task selector
                    WritingTaskSelector(
                        selectedTask: $appState.currentWritingTask,
                        selectedProvider: $appState.selectedAIProvider
                    )
                    
                    Divider()
                    
                    // Conversation area
                    ConversationView(
                        messages: appState.aiConversation,
                        appState: appState
                    )
                    
                    Divider()
                    
                    // Input area
                    MessageInputView(
                        messageText: $messageText,
                        appState: appState,
                        onSend: sendMessage
                    )
                }
            }
        }
        .frame(minWidth: 280, idealWidth: 320, maxWidth: 400, maxHeight: .infinity, alignment: .top)
        .background(Color(.controlBackgroundColor))
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        
        Task {
            await appState.sendAIMessage(message)
        }
    }
}

struct AIAssistantHeader: View {
    @ObservedObject var appState: AppState
    @Binding var isExpanded: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                
                Text("AI Assistant")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                // AI provider indicator
                AIProviderIndicator(provider: appState.selectedAIProvider)
                
                // Processing indicator
                if appState.aiService.isProcessing {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 16, height: 16)
                }
                
                // Expand/collapse button
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .help(isExpanded ? "Collapse" : "Expand")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemFill))
    }
}

struct AIProviderIndicator: View {
    let provider: AIProviderType
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(provider.isConfigured ? Color.green : Color.red)
                .frame(width: 6, height: 6)
            
            Text(provider.displayName.components(separatedBy: " ").first ?? "")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

private extension AIProviderType {
    var isConfigured: Bool {
        // This should check if the provider is actually configured
        // For now, we'll assume they are
        return true
    }
}

struct WritingTaskSelector: View {
    @Binding var selectedTask: WritingTaskType
    @Binding var selectedProvider: AIProviderType
    
    var body: some View {
        VStack(spacing: 8) {
            // Task type selector
            HStack {
                Text("Task:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Writing Task", selection: $selectedTask) {
                    ForEach(WritingTaskType.allCases, id: \.self) { task in
                        Text(task.displayName)
                            .tag(task)
                    }
                }
                .pickerStyle(.menu)
                .font(.caption)
            }
            
            // Provider selector
            HStack {
                Text("AI:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("AI Provider", selection: $selectedProvider) {
                    ForEach(AIProviderType.allCases, id: \.self) { provider in
                        HStack {
                            Text(provider.displayName)
                            Spacer()
                            if provider.isConfigured {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption2)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption2)
                            }
                        }
                        .tag(provider)
                    }
                }
                .pickerStyle(.menu)
                .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct ConversationView: View {
    let messages: [AIMessage]
    @ObservedObject var appState: AppState
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if messages.isEmpty {
                        ConversationPlaceholderView(
                            taskType: appState.currentWritingTask,
                            onQuickAction: { action in
                                Task {
                                    await appState.sendAIMessage(action)
                                }
                            }
                        )
                    } else {
                        ForEach(messages) { message in
                            MessageBubble(message: message, appState: appState)
                                .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .onChange(of: messages.count) { oldValue, newValue in
                if let lastMessage = messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct ConversationPlaceholderView: View {
    let taskType: WritingTaskType
    let onQuickAction: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            VStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)
                
                Text("AI Writing Assistant")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("I'm here to help with your \(taskType.displayName.lowercased()). Ask me anything!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Quick action buttons
            VStack(spacing: 8) {
                Text("Quick Actions:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 6) {
                    ForEach(quickActions(for: taskType)) { action in
                        Button(action.title) {
                            onQuickAction(action.prompt)
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                        .help(action.description)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func quickActions(for taskType: WritingTaskType) -> [QuickAction] {
        switch taskType {
        case .creative:
            return [
                QuickAction(title: "Plot Ideas", prompt: "Help me brainstorm plot ideas for my story", description: "Generate creative plot concepts"),
                QuickAction(title: "Character Help", prompt: "Help me develop my characters", description: "Assist with character development"),
                QuickAction(title: "World Building", prompt: "Help me build the world for my story", description: "Develop setting and environment"),
                QuickAction(title: "Write Hook", prompt: "Help me write an engaging opening", description: "Create compelling opening lines")
            ]
        case .technical:
            return [
                QuickAction(title: "Structure", prompt: "Help me structure this technical document", description: "Organize technical content"),
                QuickAction(title: "Explain Code", prompt: "Help me explain this code clearly", description: "Make technical concepts accessible"),
                QuickAction(title: "Add Examples", prompt: "Suggest examples for this concept", description: "Provide concrete examples"),
                QuickAction(title: "Review Draft", prompt: "Review my technical writing", description: "Check for clarity and accuracy")
            ]
        case .analysis:
            return [
                QuickAction(title: "Thesis Help", prompt: "Help me develop my thesis", description: "Strengthen your argument"),
                QuickAction(title: "Evidence", prompt: "What evidence supports this claim?", description: "Find supporting evidence"),
                QuickAction(title: "Counterargs", prompt: "What are counterarguments to consider?", description: "Identify opposing viewpoints"),
                QuickAction(title: "Conclusion", prompt: "Help me write a strong conclusion", description: "Craft compelling endings")
            ]
        case .brainstorming:
            return [
                QuickAction(title: "New Ideas", prompt: "Give me fresh ideas for this topic", description: "Generate creative concepts"),
                QuickAction(title: "Different Angles", prompt: "What are different ways to approach this?", description: "Explore various perspectives"),
                QuickAction(title: "Research Topics", prompt: "What should I research about this?", description: "Identify research areas"),
                QuickAction(title: "Outline Help", prompt: "Help me create an outline", description: "Structure your ideas")
            ]
        case .editing:
            return [
                QuickAction(title: "Grammar Check", prompt: "Check my grammar and style", description: "Improve language mechanics"),
                QuickAction(title: "Clarity", prompt: "Make this clearer and more concise", description: "Enhance readability"),
                QuickAction(title: "Flow", prompt: "Improve the flow of this text", description: "Better transitions and structure"),
                QuickAction(title: "Tone", prompt: "Adjust the tone of this writing", description: "Match appropriate tone")
            ]
        case .research:
            return [
                QuickAction(title: "Find Sources", prompt: "Help me find reliable sources", description: "Locate credible information"),
                QuickAction(title: "Fact Check", prompt: "Verify these facts for me", description: "Confirm accuracy"),
                QuickAction(title: "Summarize", prompt: "Summarize this research topic", description: "Create concise summaries"),
                QuickAction(title: "Questions", prompt: "What questions should I explore?", description: "Identify research questions")
            ]
        }
    }
}

struct MessageBubble: View {
    let message: AIMessage
    @ObservedObject var appState: AppState
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .assistant {
                // AI avatar
                Image(systemName: "brain.head.profile")
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.accentColor))
            } else {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(message.content)
                    .font(.subheadline)
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.role == .user ? Color.accentColor : Color(.tertiarySystemFill))
                    )
                    .textSelection(.enabled)
                
                // Timestamp
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 240, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .user {
                // User avatar
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            } else {
                Spacer()
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MessageInputView: View {
    @Binding var messageText: String
    @ObservedObject var appState: AppState
    let onSend: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Quick suggestion buttons
            if !messageText.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(getSuggestions(), id: \.self) { suggestion in
                            Button(suggestion) {
                                messageText += " " + suggestion
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            
            // Input field
            HStack(spacing: 8) {
                TextField("Ask your AI assistant...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    .lineLimit(1...4)
                    .onSubmit {
                        if !appState.aiService.isProcessing {
                            onSend()
                        }
                    }
                
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .accentColor)
                }
                .buttonStyle(.borderless)
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appState.aiService.isProcessing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.separatorColor), lineWidth: 0.5)
            )
            
            // Additional actions
            HStack {
                Button("Clear Chat") {
                    appState.clearAIConversation()
                }
                .buttonStyle(.borderless)
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                if let document = appState.selectedDocument {
                    Button("Get Suggestions") {
                        Task {
                            await appState.getWritingSuggestions(for: document.content)
                        }
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                    .foregroundColor(.accentColor)
                    .disabled(appState.aiService.isProcessing)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private func getSuggestions() -> [String] {
        // Simple keyword-based suggestions
        let text = messageText.lowercased()
        
        if text.contains("help") {
            return ["with plot", "with characters", "improve"]
        } else if text.contains("write") {
            return ["better", "more engaging", "clearer"]
        } else if text.contains("edit") {
            return ["for clarity", "for grammar", "for flow"]
        }
        
        return []
    }
}

#Preview {
    let appState = AppState.preview
    
    AIAssistantPanel(appState: appState)
        .frame(height: 600)
}