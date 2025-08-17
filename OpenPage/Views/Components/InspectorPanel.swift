import SwiftUI
import SwiftData

struct InspectorPanel: View {
    @ObservedObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Inspector header
            HStack {
                Text("Inspector")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
            
            // Inspector content
            if let document = appState.selectedDocument {
                SimplestInspectorView(document: document)
                    .layoutPriority(1)
            } else {
                ContentUnavailableView {
                    Label("No Document Selected", systemImage: "doc.text.magnifyingglass")
                } description: {
                    Text("Select a document to see its properties")
                }
                .layoutPriority(1)
            }
        }
        .frame(minWidth: 220, idealWidth: 250, maxWidth: 300, maxHeight: .infinity, alignment: .top)
        .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
    }
}

#Preview {
    InspectorPanel(appState: AppState.preview)
        .modelContainer(AppState.preview.documentService.container)
}