import SwiftUI

/// Manages all menu commands for the app
/// Replaces NotificationCenter with direct AppState actions
struct AppMenuCommands: Commands {
    @ObservedObject var appState: AppState
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Document") {
                appState.createNewDocument()
            }
            .keyboardShortcut("n", modifiers: .command)
            
            Button("New Project") {
                appState.createNewProject()
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
        }
        
        CommandMenu("Format") {
            Button("Bold") {
                // TODO: Implement formatting through AppState
                print("Bold")
            }
            .keyboardShortcut("b", modifiers: .command)
            
            Button("Italic") {
                print("Italic")
            }
            .keyboardShortcut("i", modifiers: .command)
            
            Divider()
            
            Button("Heading 1") {
                print("Heading 1")
            }
            .keyboardShortcut("1", modifiers: [.command, .shift])
            
            Button("Heading 2") {
                print("Heading 2")
            }
            .keyboardShortcut("2", modifiers: [.command, .shift])
            
            Button("Heading 3") {
                print("Heading 3")
            }
            .keyboardShortcut("3", modifiers: [.command, .shift])
        }
        
        CommandMenu("View") {
            Button("Toggle Preview") {
                // TODO: Implement preview toggle through AppState
                print("Toggle Preview")
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
            
            Button("Focus Mode") {
                print("Focus Mode")
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Command Palette") {
                print("Command Palette")
            }
            .keyboardShortcut("p", modifiers: .command)
        }
        
        CommandMenu("AI") {
            Button("New Chat") {
                appState.createNewChat()
            }
            .keyboardShortcut("a", modifiers: [.command, .shift])
            
            Button("Show Chat Assistant") {
                appState.toggleChatAssistant()
            }
            .keyboardShortcut("a", modifiers: .command)
            
            Divider()
            
            Button("AI Settings") {
                appState.showAISettings()
            }
        }
    }
}