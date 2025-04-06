import SwiftUI

struct AISettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var clerkHasKey: [String: Bool] = [:]
    @State private var showingAPIKeySetup = false
    
    var body: some View {
        Form {
            Section(header: Text("AI Features")) {
                Toggle("Enable AI Assistance", isOn: $settingsViewModel.aiAssistEnabled)
                    .onChange(of: settingsViewModel.aiAssistEnabled) { newValue in
                        if newValue && !hasAnyAPIKey() {
                            showingAPIKeySetup = true
                        }
                    }
                
                if settingsViewModel.aiAssistEnabled {
                    Toggle("Enable Grammar Check", isOn: $settingsViewModel.grammarCheckEnabled)
                    Toggle("Enable Style Suggestions", isOn: $settingsViewModel.styleSuggestionsEnabled)
                }
            }
            
            Section(header: Text("AI Provider")) {
                ForEach(settingsViewModel.availableAIProviders, id: \.self) { provider in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(settingsViewModel.displayNameForProvider(provider))
                                .font(.headline)
                            if let providerEnum = APIKeyManager.APIProvider(rawValue: provider) {
                                Text(providerEnum.keyFormatDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // API key status indicator
                        if let hasKey = clerkHasKey[provider], hasKey {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Text("No API Key")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // Selected provider indicator
                        if settingsViewModel.selectedAIProvider == provider {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let hasKey = clerkHasKey[provider], hasKey {
                            settingsViewModel.selectedAIProvider = provider
                        } else {
                            showingAPIKeySetup = true
                        }
                    }
                }
                
                Button("Setup API Keys") {
                    showingAPIKeySetup = true
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            checkAPIKeys()
        }
        .sheet(isPresented: $showingAPIKeySetup) {
            APIKeySetupView()
                .onDisappear {
                    checkAPIKeys()
                    
                    // If we now have an API key but no provider selected, select the first available one
                    if hasAnyAPIKey() && settingsViewModel.selectedAIProvider == nil {
                        if let firstProviderWithKey = settingsViewModel.availableAIProviders.first(where: { clerkHasKey[$0, default: false] }) {
                            settingsViewModel.selectedAIProvider = firstProviderWithKey
                        }
                    }
                }
        }
    }
    
    private func checkAPIKeys() {
        for provider in settingsViewModel.availableAIProviders {
            if let apiProvider = APIKeyManager.APIProvider(rawValue: provider) {
                clerkHasKey[provider] = APIKeyManager.shared.hasAPIKey(for: apiProvider)
            }
        }
    }
    
    private func hasAnyAPIKey() -> Bool {
        return clerkHasKey.values.contains(true)
    }
}

#Preview {
    AISettingsView()
        .environmentObject(SettingsViewModel(appSettings: AppSettings()))
} 