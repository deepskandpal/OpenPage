import SwiftUI
import SwiftData

struct BinderPanel: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Binder header
            HStack {
                Text("Binder")
                    .font(.headline)
                
                Spacer()
                
                Button(action: appState.createNewProject) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 12))
                }
                .buttonStyle(.borderless)
                .help("New Project")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
            
            // Binder content
            SidebarView(
                selectedDocument: .init(
                    get: { appState.selectedDocument },
                    set: { appState.selectDocument($0) }
                ),
                selectedProject: .init(
                    get: { appState.selectedProject },
                    set: { appState.selectProject($0) }
                )
            )
            .layoutPriority(1)
        }
        .frame(minWidth: 220, idealWidth: 250, maxWidth: 300, maxHeight: .infinity, alignment: .top)
        .background(Color.adaptiveBackground)
    }
}

#Preview {
    BinderPanel(appState: AppState.preview)
        .modelContainer(AppState.preview.documentService.container)
}