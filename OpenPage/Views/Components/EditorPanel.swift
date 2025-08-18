import SwiftUI
import SwiftData

struct EditorPanel: View {
    @ObservedObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor toolbar
            EditorPanelToolbar(appState: appState)
            
            // Editor content
            EditorContent(appState: appState)
        }
        .frame(minWidth: 450, idealWidth: 600, maxHeight: .infinity)
    }
}

private struct EditorPanelToolbar: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        HStack {
            // Binder toggle button
            Button(action: appState.toggleBinder) {
                Image(systemName: "sidebar.leading")
                    .foregroundColor(appState.showBinder ? .accentColor : .primary)
            }
            .buttonStyle(.borderless)
            .help(appState.showBinder ? "Hide Binder" : "Show Binder")
            
            Spacer()
            
            // Editor context title
            if let document = appState.selectedDocument {
                Text(document.title)
                    .font(.headline)
            } else {
                Text("No Document Selected")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Inspector toggle button
            Button(action: appState.toggleInspector) {
                Image(systemName: "sidebar.trailing")
                    .foregroundColor(appState.showInspector ? .accentColor : .primary)
            }
            .buttonStyle(.borderless)
            .help(appState.showInspector ? "Hide Inspector" : "Show Inspector")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
}

private struct EditorContent: View {
    @ObservedObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .white)
                .edgesIgnoringSafeArea(.all)
            
            if let document = appState.selectedDocument {
                DocumentEditor(document: document, documentService: appState.documentService, appState: appState)
            } else {
                WelcomeView(appState: appState)
            }
        }
        .layoutPriority(1)
    }
}

private struct DocumentEditor: View {
    let document: Document
    let documentService: DocumentService
    @ObservedObject var appState: AppState
    
    var body: some View {
        EditorView(document: document)
            .environmentObject(appState)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .padding()
    }
}

private struct WelcomeView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Welcome to Vibe Writing")
                .font(.largeTitle)
            
            Text("Select a document from the binder or create a new one")
                .foregroundColor(.secondary)
            
            Button(action: appState.createNewDocument) {
                Label("Create New Document", systemImage: "doc.badge.plus")
                    .font(.headline)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EditorPanel(appState: AppState.preview)
        .modelContainer(AppState.preview.documentService.container)
}