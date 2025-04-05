import SwiftUI
import SwiftData

// Ultra-minimal inspector view with no complex SwiftUI components
struct SimplestInspectorView: View {
    var document: Document
    @State private var selectedTab = 0
    @Environment(\.modelContext) private var modelContext
    
    // This creates a new SettingsViewModel when needed for the ChatView
    private var settingsViewModel: SettingsViewModel {
        // Get the AppSettings from the model context
        var fetchDescriptor = FetchDescriptor<AppSettings>()
        fetchDescriptor.fetchLimit = 1
        let settings = (try? modelContext.fetch(fetchDescriptor).first) ?? AppSettings()
        return SettingsViewModel(appSettings: settings)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Manually created tab bar instead of using Picker
            HStack(spacing: 0) {
                Button {
                    selectedTab = 0
                } label: {
                    Text("Info")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == 0 ? Color.accentColor : Color.clear)
                        .foregroundColor(selectedTab == 0 ? .white : .primary)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button {
                    selectedTab = 1
                } label: {
                    Text("Notes")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == 1 ? Color.accentColor : Color.clear)
                        .foregroundColor(selectedTab == 1 ? .white : .primary)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button {
                    selectedTab = 2
                } label: {
                    Text("Status")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == 2 ? Color.accentColor : Color.clear)
                        .foregroundColor(selectedTab == 2 ? .white : .primary)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button {
                    selectedTab = 3
                } label: {
                    Text("AI Chat")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == 3 ? Color.accentColor : Color.clear)
                        .foregroundColor(selectedTab == 3 ? .white : .primary)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .padding(4)
            .background(Color.gray.opacity(0.05))
            
            Divider()
            
            // Content based on selected tab
            switch selectedTab {
            case 0:
                // Info content
                ScrollView {
                    VStack(alignment: .leading) {
                        Group {
                            Text("Document Info")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding([.top, .bottom], 8)
                            
                            Divider()
                            
                            Text("Title: \(document.title)")
                                .padding(.vertical, 4)
                            
                            if let author = document.author, !author.isEmpty {
                                Text("Author: \(author)")
                                    .padding(.vertical, 4)
                            }
                            
                            if let category = document.category, !category.isEmpty {
                                Text("Category: \(category)")
                                    .padding(.vertical, 4)
                            }
                            
                            if !document.tags.isEmpty {
                                Text("Tags: \(document.tags.joined(separator: ", "))")
                                    .padding(.vertical, 4)
                            }
                        }
                        
                        Group {
                            Text("Document Dates")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding([.top, .bottom], 8)
                            
                            Divider()
                            
                            Text("Created: \(document.createdAt.formatted())")
                                .padding(.vertical, 4)
                            
                            Text("Last updated: \(document.updatedAt.formatted())")
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.white)
            case 1:
                // Notes content
                VStack(spacing: 0) {
                    Text("Document Notes")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Divider()
                    
                    TextEditor(text: .constant(document.synopsis ?? "Add synopsis or notes here..."))
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding()
                }
                .background(Color.white)
            case 2:
                // Status content
                ScrollView {
                    VStack(alignment: .leading) {
                        Group {
                            Text("Document Statistics")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding([.top, .bottom], 8)
                            
                            Divider()
                            
                            Text("Word count: \(document.wordCount)")
                                .padding(.vertical, 4)
                            
                            Text("Character count: \(document.characterCount)")
                                .padding(.vertical, 4)
                        }
                        
                        if let targetWords = document.targetWordCount {
                            Group {
                                Text("Writing Goals")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding([.top, .bottom], 8)
                                
                                Divider()
                                
                                Text("Target: \(document.wordCount) of \(targetWords) words")
                                    .padding(.vertical, 4)
                                
                                ProgressView(value: Double(document.wordCount), total: Double(targetWords))
                                    .padding(.vertical, 4)
                                    .accentColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.white)
            case 3:
                // AI chat content
                ChatView(settingsViewModel: settingsViewModel, document: document)
                    .environment(\.modelContext, modelContext)
            default:
                Text("Invalid tab selected")
            }
        }
    }
} 