import SwiftUI

/// View for setting up API keys for AI providers
struct AIAPIKeySetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProvider: APIKeyManager.APIProvider = .claude
    @State private var apiKey = ""
    @State private var isValidating = false
    @State private var validationMessage: String?
    @State private var validationSuccess = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("AI Provider Setup")
                .font(.largeTitle)
                .padding(.top)
            
            Text("Please enter your API key for Claude.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("API Key")
                    .font(.headline)
                
                SecureField("Enter API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textContentType(.password)
                    .disabled(isValidating)
                
                Text("API keys typically start with sk-ant-")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("Save") {
                    saveAPIKey()
                }
                .keyboardShortcut(.return)
                .disabled(apiKey.isEmpty || isValidating)
            }
            .padding(.top)
        }
        .frame(width: 400)
        .padding()
    }
    
    private func saveAPIKey() {
        isValidating = true
        
        Task {
            do {
                try APIKeyManager.shared.saveAPIKey(apiKey, for: selectedProvider)
                validationSuccess = true
                dismiss()
            } catch {
                validationMessage = error.localizedDescription
            }
            isValidating = false
        }
    }
}

#Preview {
    AIAPIKeySetupView()
} 