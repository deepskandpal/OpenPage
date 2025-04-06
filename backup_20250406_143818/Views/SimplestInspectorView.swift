import SwiftUI
import SwiftData

enum InspectorTab {
    case properties
    case notes
    case research
    case chat
}

// Ultra-minimal inspector view with no complex SwiftUI components
struct SimplestInspectorView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @Query private var appSettings: [AppSettings]
    
    @State private var selectedTab: InspectorTab = .properties
    
    var document: Document?
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom tab bar at the top
            HStack(spacing: 0) {
                tabButton(title: "Properties", tab: .properties, systemImage: "info.circle")
                tabButton(title: "Notes", tab: .notes, systemImage: "note.text")
                tabButton(title: "Research", tab: .research, systemImage: "magnifyingglass")
                tabButton(title: "Chat", tab: .chat, systemImage: "message")
            }
            .padding(.top, 8)
            
            // Tab content
            VStack {
                switch selectedTab {
                case .properties:
                    propertiesTab
                case .notes:
                    notesTab
                case .research:
                    researchTab
                case .chat:
                    chatTab
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .background(Color.gray.opacity(0.05))
    }
    
    // MARK: - Tab Button
    private func tabButton(title: String, tab: InspectorTab, systemImage: String) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(selectedTab == tab ? Color.gray.opacity(0.2) : Color.clear)
            .foregroundColor(selectedTab == tab ? .primary : .secondary)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Properties Tab
    private var propertiesTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let document = document {
                // Document title section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Title", text: Binding(
                        get: { document.title },
                        set: { document.title = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
                
                // Document status section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Status", selection: Binding(
                        get: { document.status ?? "draft" },
                        set: { document.status = $0 }
                    )) {
                        Text("Draft").tag("draft")
                        Text("In Progress").tag("in progress")
                        Text("Complete").tag("complete")
                        Text("Archived").tag("archived")
                    }
                    .pickerStyle(.segmented)
                }
                
                // Word count goals
                VStack(alignment: .leading, spacing: 4) {
                    Text("Word Count Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Target", value: Binding(
                            get: { document.targetWordCount ?? 0 },
                            set: { document.targetWordCount = $0 }
                        ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        
                        Text("Current: \(document.wordCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let target = document.targetWordCount, target > 0 {
                        ProgressView(value: Double(document.wordCount), total: Double(target))
                            .progressViewStyle(.linear)
                    }
                }
                
                // Synopsis section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Synopsis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: Binding(
                        get: { document.synopsis ?? "" },
                        set: { document.synopsis = $0 }
                    ))
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                }
                
                Spacer()
            } else {
                Text("No document selected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - Notes Tab
    private var notesTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let document = document {
                // Document notes
                VStack(alignment: .leading, spacing: 4) {
                    Text("Document Notes")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    // In a real app, notes would be a property of the document
                    TextEditor(text: .constant("Sample notes for this document. In a real implementation, this would be stored in the document model."))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                }
            } else {
                Text("No document selected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - Research Tab
    private var researchTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Research Items")
                .font(.headline)
            
            // Research would be implemented in a real app
            Text("Research items related to this document would appear here.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Chat Tab
    private var chatTab: some View {
        ChatView(viewModel: settingsViewModel)
    }
} 