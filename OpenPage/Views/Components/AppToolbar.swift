import SwiftUI
import SwiftData

struct AppToolbar: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        HStack {
            Text("Vibe Writing")
                .font(.headline)
            
            Spacer()
            
            // Document controls
            Button(action: appState.createNewDocument) {
                Label("New Document", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            
            Button(action: appState.showSettings) {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    AppToolbar(appState: AppState.preview)
}