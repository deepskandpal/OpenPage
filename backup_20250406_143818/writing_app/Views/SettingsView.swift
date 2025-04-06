import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = "general"
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // General Settings
                Form {
                    // Theme settings
                    Section(header: Text("Theme")) {
                        Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
                        
                        Picker("Accent Color", selection: $viewModel.accentColor) {
                            ForEach(viewModel.availableColors, id: \.self) { color in
                                Text(color).tag(color)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Font settings
                    Section(header: Text("Font")) {
                        Picker("Font Family", selection: $viewModel.fontName) {
                            ForEach(viewModel.availableFonts, id: \.self) { font in
                                Text(font).tag(font)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        HStack {
                            Text("Font Size")
                            Spacer()
                            Text("\(Int(viewModel.fontSize))pt")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $viewModel.fontSize, in: 8...32, step: 1) {
                            Text("Font Size")
                        }
                    }
                    
                    Section {
                        Button("Reset to Defaults") {
                            viewModel.resetToDefaults()
                        }
                        .foregroundColor(.red)
                    }
                }
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag("general")
                
                // Editor Settings
                Form {
                    // Editor preferences
                    Section(header: Text("Editor")) {
                        Toggle("Show Line Numbers", isOn: $viewModel.showLineNumbers)
                        Toggle("Use Spell Check", isOn: $viewModel.useSpellCheck)
                        Toggle("Use Hierarchical Editing", isOn: $viewModel.useHierarchicalEditing)
                        
                        Picker("Default View Mode", selection: $viewModel.defaultView) {
                            ForEach(viewModel.viewOptions, id: \.self) { option in
                                Text(option.capitalized).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Auto-save settings
                    Section(header: Text("Auto-Save")) {
                        Toggle("Enable Auto-Save", isOn: $viewModel.autoSaveEnabled)
                        
                        if viewModel.autoSaveEnabled {
                            HStack {
                                Text("Auto-Save Interval")
                                Spacer()
                                Text("\(viewModel.autoSaveInterval) seconds")
                                    .foregroundColor(.secondary)
                            }
                            
                            Slider(value: Binding<Double>(
                                get: { Double(viewModel.autoSaveInterval) },
                                set: { viewModel.autoSaveInterval = Int($0) }
                            ), in: 5...120, step: 5) {
                                Text("Auto-Save Interval")
                            }
                        }
                    }
                    
                    // Display settings
                    Section(header: Text("Display")) {
                        Toggle("Show Word Count", isOn: $viewModel.showWordCount)
                        Toggle("Show Character Count", isOn: $viewModel.showCharacterCount)
                    }
                }
                .tabItem {
                    Label("Editor", systemImage: "doc.text")
                }
                .tag("editor")
                
                // AI Settings
                AISettingsView()
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("AI", systemImage: "brain")
                    }
                    .tag("ai")
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.saveSettings()
                        dismiss()
                    }
                }
            }
            .frame(minWidth: 450, minHeight: 500)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(appSettings: AppSettings()))
    }
} 