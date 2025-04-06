import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    var settingsViewModel: SettingsViewModel
    var document: Document?
    
    @State private var message: String = ""
    @State private var showAPIKeySetup: Bool = false
    @State private var messages: [ChatMessage] = []
    @State private var isProcessing: Bool = false
    @State private var conversationId: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack {
                Text(document?.title ?? "AI Chat")
                    .font(.headline)
                Spacer()
                
                if let provider = settingsViewModel.selectedAIProvider {
                    Text("Using: \(displayProviderName(provider))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button("Setup AI") {
                    showAPIKeySetup = true
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            Divider()
            
            // Message area
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                            .padding(.horizontal)
                    }
                    
                    if isProcessing {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                    
                    if messages.isEmpty && !isProcessing {
                        VStack(spacing: 12) {
                            Text("AI Chat Assistant")
                                .font(.headline)
                                .padding(.top)
                            
                            Text("Ask questions about your writing, get suggestions, or request ideas.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 300)
                            
                            if let doc = document {
                                Button("Summarize Document") {
                                    summarizeDocument(doc)
                                }
                                .buttonStyle(.bordered)
                                .padding(.top)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            
            Divider()
            
            // Input area
            HStack {
                TextField("Type your message...", text: $message)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isProcessing)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
                .buttonStyle(.bordered)
                .disabled(message.isEmpty || isProcessing)
            }
            .padding()
        }
        .sheet(isPresented: $showAPIKeySetup) {
            APIKeySetupView()
        }
        .onAppear {
            loadExistingConversation()
        }
    }
    
    private func loadExistingConversation() {
        // Try to load existing messages for the current document
        let descriptor = FetchDescriptor<ChatMessage>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        if let fetchedMessages = try? modelContext.fetch(descriptor) {
            // Filter for messages related to this document
            let docTitle = document?.title
            let relevantMessages = fetchedMessages.filter { msg in
                return msg.documentTitle == docTitle
            }
            
            if !relevantMessages.isEmpty {
                messages = relevantMessages
                // Get the conversation ID from the first message
                conversationId = relevantMessages.first?.conversationId
            }
        }
    }
    
    private func sendMessage() {
        guard !message.isEmpty else { return }
        
        // Get the message text before clearing
        let messageText = message
        message = ""
        isProcessing = true
        
        // Create a user message
        let userMsg = ChatMessage(
            role: .user, 
            content: messageText,
            documentTitle: document?.title
        )
        
        // Use existing conversation ID or from the message
        if let existing = conversationId {
            userMsg.conversationId = existing
        } else {
            conversationId = userMsg.conversationId
        }
        
        // Set conversation title
        userMsg.conversationTitle = document?.title ?? "AI Chat"
        
        // Save to database
        modelContext.insert(userMsg)
        
        // Add to UI
        messages.append(userMsg)
        
        // Create AI response with a short delay to simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            generateAIResponse(to: userMsg)
        }
    }
    
    private func generateAIResponse(to userMessage: ChatMessage) {
        // In a real implementation, this would call an actual AI API
        // For now, we'll generate a simulated response
        
        let selectedModel = settingsViewModel.selectedAIProvider ?? "openai"
        let responseText = simulateAIResponse(to: userMessage.content, provider: selectedModel)
        
        let aiMsg = ChatMessage(
            role: .assistant, 
            content: responseText,
            documentTitle: document?.title,
            inReplyToId: userMessage.id
        )
        
        // Link to same conversation
        aiMsg.conversationId = conversationId
        aiMsg.conversationTitle = document?.title ?? "AI Chat"
        
        // Add AI metadata
        aiMsg.setAIMetadata(
            model: selectedModel,
            metadata: ["type": "simulated"]
        )
        
        // Save to database
        modelContext.insert(aiMsg)
        
        // Update UI
        messages.append(aiMsg)
        isProcessing = false
    }
    
    private func summarizeDocument(_ document: Document) {
        // Create a request to summarize the document
        isProcessing = true
        
        let content = document.isHierarchical ? 
            (document.rootSection?.combinedContent ?? document.content) : 
            document.content
            
        let messageText = "Please summarize this document for me: \"\(content.prefix(1000))...\""
        
        // Create a system message
        let systemMsg = ChatMessage(
            role: .system,
            content: "The user is asking for a summary of their document titled '\(document.title)'.",
            documentTitle: document.title
        )
        
        // Create a user message
        let userMsg = ChatMessage(
            role: .user, 
            content: messageText,
            documentTitle: document.title
        )
        
        // Generate a new conversation ID
        let newConversationId = UUID().uuidString
        conversationId = newConversationId
        
        systemMsg.conversationId = newConversationId
        userMsg.conversationId = newConversationId
        
        // Set conversation title
        systemMsg.conversationTitle = "Summary: \(document.title)"
        userMsg.conversationTitle = "Summary: \(document.title)"
        
        // Save to database
        modelContext.insert(systemMsg)
        modelContext.insert(userMsg)
        
        // Show only the user message in UI
        messages = [userMsg]
        
        // Create AI response with a short delay to simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            generateAIResponse(to: userMsg)
        }
    }
    
    private func simulateAIResponse(to message: String, provider: String) -> String {
        // Simple response generation logic for demonstration purposes
        if message.lowercased().contains("summarize") {
            return "Here's a summary of your document:\n\n- The document appears to be about a creative writing project\n- It contains several key themes including personal growth\n- There are approximately \(document?.wordCount ?? 0) words\n\nWould you like me to analyze any specific aspect of the document?"
        } else if message.lowercased().contains("hello") || message.lowercased().contains("hi") {
            return "Hello! I'm your writing assistant. How can I help you with your document today?"
        } else if message.lowercased().contains("idea") || message.lowercased().contains("suggestion") {
            return "Here are some ideas for your writing:\n\n1. Consider adding a scene that reveals more about your protagonist's motivation\n2. You could explore the theme of transformation more deeply\n3. Try incorporating more sensory details to make the setting more vivid"
        } else {
            return "I've analyzed your message: \"\(message)\"\n\nAs your writing assistant, I can help you develop your ideas, improve your prose, or provide feedback on your document. What specific aspect would you like me to address?"
        }
    }
    
    private func displayProviderName(_ provider: String) -> String {
        switch provider {
        case "openai":
            return "OpenAI"
        case "anthropic":
            return "Anthropic"
        case "gemini":
            return "Google Gemini"
        default:
            return provider.capitalized
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top) {
            if message.role != .user {
                Image(systemName: "brain")
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 2) {
                if message.role == .system {
                    Text("System")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(message.content)
                    .padding()
                    .background(backgroundColor)
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if let model = message.aiModel, message.role == .assistant {
                    Text("Generated by \(model)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                }
            }
            
            if message.role == .user {
                Image(systemName: "person.circle")
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
        }
    }
    
    private var backgroundColor: Color {
        switch message.role {
        case .user:
            return .blue
        case .assistant:
            return Color.gray.opacity(0.2)
        case .system:
            return Color.blue.opacity(0.1)
        }
    }
}

// MARK: - Preview
#Preview {
    let container = try! ModelContainer(
        for: Document.self, Project.self, AppSettings.self, ChatMessage.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let appSettings = AppSettings()
    container.mainContext.insert(appSettings)
    
    return ChatView(
        settingsViewModel: SettingsViewModel(appSettings: appSettings), 
        document: nil
    )
    .modelContainer(container)
} 