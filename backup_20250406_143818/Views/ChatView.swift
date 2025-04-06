import SwiftUI
import SwiftData

/// A view for displaying and interacting with the AI chat assistant
struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: SettingsViewModel
    
    // State variables
    @State private var inputText = ""
    @State private var conversation: Conversation?
    @State private var isProcessing = false
    @State private var showingAPIKeyAlert = false
    @State private var showingAPIKeySetup = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            ChatHeaderView(
                onNewConversation: { createNewConversation() },
                onClearConversation: { clearConversation() },
                onShowSettings: {
                    NotificationCenter.default.post(
                        name: Notification.Name("ShowAISettings"),
                        object: nil
                    )
                }
            )
            
            // Message list
            if let conversation = conversation {
                MessageListView(messages: conversation.messages)
                    .onChange(of: conversation.messages.count) { _, _ in
                        scrollToLatestMessage()
                    }
            } else {
                EmptyChatView()
            }
            
            // Input area
            ChatInputView(
                text: $inputText,
                isProcessing: isProcessing,
                onSendMessage: {
                    if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        sendMessage()
                    }
                }
            )
        }
        .onAppear {
            checkForAPIKey()
            loadOrCreateConversation()
        }
        .alert("API Key Required", isPresented: $showingAPIKeyAlert) {
            Button("Configure Now") {
                showingAPIKeySetup = true
            }
            Button("Later", role: .cancel) { }
        } message: {
            Text("You need to configure an API key to use the AI Assistant.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") {
                errorMessage = nil
                showingErrorAlert = false
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            } else {
                Text("An unknown error occurred")
            }
        }
        .sheet(isPresented: $showingAPIKeySetup) {
            AIAPIKeySetupView()
                .onDisappear {
                    checkForAPIKey()
                }
        }
    }
    
    // MARK: - Helper Methods
    
    private func scrollToLatestMessage() {
        // Implement scrolling logic if needed
        // This avoids cycles by not directly referencing view state
    }
    
    // MARK: - Message Sending
    
    private func sendMessage() {
        guard let provider = APIKeyManager.APIProvider(rawValue: viewModel.preferredAIProvider ?? "claude") else {
            showingAPIKeyAlert = true
            return
        }
        
        if !APIKeyManager.shared.hasAPIKey(for: provider) {
            showingAPIKeyAlert = true
            return
        }
        
        guard let conversation = conversation else {
            createNewConversation()
            return
        }
        
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // Add user message to conversation
        conversation.addUserMessage(userMessage)
        
        // Clear input
        inputText = ""
        
        // Set processing state
        isProcessing = true
        
        // Send message to Claude
        Task {
            do {
                let systemPrompt = conversation.messages.first { $0.role == .system }?.content
                let response = try await LLMService.shared.sendMessage(userMessage, systemPrompt: systemPrompt)
                
                await MainActor.run {
                    conversation.addAssistantMessage(response)
                    isProcessing = false
                }
            } catch let error as LLMError {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                    if case .invalidAPIKey = error {
                        showingAPIKeyAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
    
    // MARK: - Conversation Management
    
    private func createNewConversation() {
        let newConversation = Conversation(title: "New Conversation")
        
        // Add system message if a custom prompt is configured
        if let customPrompt = viewModel.customSystemPrompt, !customPrompt.isEmpty {
            newConversation.addSystemMessage(customPrompt)
        } else {
            // Default system message
            newConversation.addSystemMessage("I'm your writing assistant. How can I help you today?")
        }
        
        modelContext.insert(newConversation)
        conversation = newConversation
    }
    
    private func clearConversation() {
        guard let conversation = conversation else { return }
        
        // Keep only the system message if it exists
        let systemMessages = conversation.messages.filter { $0.role == .system }
        conversation.messages.removeAll()
        
        // Re-add system messages
        for message in systemMessages {
            conversation.addMessage(message)
        }
    }
    
    private func loadOrCreateConversation() {
        if conversation == nil {
            createNewConversation()
        }
    }
    
    private func checkForAPIKey() {
        guard let provider = APIKeyManager.APIProvider(rawValue: viewModel.preferredAIProvider ?? "claude") else {
            showingAPIKeyAlert = true
            return
        }
        
        // Explicitly check the keychain for the API key
        let apiKey = APIKeyManager.shared.getAPIKey(for: provider)
        if apiKey == nil || apiKey?.isEmpty == true {
            showingAPIKeyAlert = true
        }
    }
}

// MARK: - Supporting Views

struct ChatHeaderView: View {
    let onNewConversation: () -> Void
    let onClearConversation: () -> Void
    let onShowSettings: () -> Void
    
    var body: some View {
        HStack {
            Text("AI Assistant")
                .font(.headline)
            
            Spacer()
            
            Menu {
                Button("New Conversation", action: onNewConversation)
                Button("Clear Conversation", action: onClearConversation)
                Divider()
                Button("AI Settings", action: onShowSettings)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 16))
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
}

struct MessageListView: View {
    let messages: [ChatMessage]
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                if !messages.isEmpty {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                } else {
                    EmptyChatView()
                }
            }
            .background(Color.white)
        }
    }
}

struct EmptyChatView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "brain")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("AI Assistant")
                .font(.title2)
            
            Text("Ask a question or request writing assistance")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct ChatInputView: View {
    @Binding var text: String
    let isProcessing: Bool
    let onSendMessage: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom) {
                TextField("Type your message...", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .frame(minHeight: 36)
                    .disabled(isProcessing)
                
                Button(action: onSendMessage) {
                    if isProcessing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.accentColor)
                    }
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.white)
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    private var bubbleColor: Color {
        message.role == .user ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1)
    }
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 2) {
                Text(message.content)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(bubbleColor)
                    )
                    .foregroundColor(.primary)
                    .multilineTextAlignment(message.role == .user ? .trailing : .leading)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 300, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(
            for: ChatMessage.self, Conversation.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        ChatView(viewModel: SettingsViewModel(appSettings: AppSettings()))
            .modelContainer(container)
            .frame(width: 300, height: 500)
    }
} 