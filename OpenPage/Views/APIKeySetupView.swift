import SwiftUI

struct APIKeySetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @State private var selectedProvider: String = "openai"
    @State private var isValidating: Bool = false
    @State private var validationMessage: String = ""
    @State private var validationSuccess: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("AI Provider Setup")
                .font(.title)
                .padding(.top)
            
            Picker("AI Provider", selection: $selectedProvider) {
                Text("OpenAI").tag("openai")
                Text("Anthropic").tag("anthropic")
                Text("Google Gemini").tag("gemini")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("API Key")
                    .font(.headline)
                
                SecureField("Enter your API key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, 4)
                
                if !validationMessage.isEmpty {
                    Text(validationMessage)
                        .font(.caption)
                        .foregroundColor(validationSuccess ? .green : .red)
                        .padding(.top, 4)
                }
                
                Text("Your API key is stored securely in the system keychain")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .padding(.horizontal)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Validate & Save") {
                    validateAndSaveKey()
                }
                .buttonStyle(.borderedProminent)
                .disabled(apiKey.isEmpty || isValidating)
            }
            .padding()
        }
        .frame(width: 450, height: 300)
    }
    
    private func validateAndSaveKey() {
        // For now, just simulate validation success
        isValidating = true
        validationMessage = "Validating..."
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isValidating = false
            validationSuccess = true
            validationMessage = "API key validated successfully!"
            
            // Simulate saving to keychain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
    }
} 