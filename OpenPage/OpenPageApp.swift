//
//  OpenPageApp.swift
//  OpenPage
//
//  Created by DKAdmin on 29/03/25.
//

import SwiftUI
import SwiftData
import Foundation

@main
struct OpenPageApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Document.self,
            Project.self,
            AppSettings.self,
            DocumentSection.self,
            SectionMetadata.self,
            DocumentVersion.self,
            ChatMessage.self,
            Conversation.self
        ])
        
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var showNewDocumentSheet = false

    var body: some Scene {
        WindowGroup {
            MainView(modelContext: sharedModelContainer.mainContext)
                .modelContainer(sharedModelContainer)
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .ignoresSafeArea(.all)
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    NotificationCenter.default.post(
                        name: Notification.Name("CreateNewDocument"),
                        object: nil
                    )
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("New Project") {
                    NotificationCenter.default.post(
                        name: Notification.Name("CreateNewProject"),
                        object: nil
                    )
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
            
            CommandMenu("Format") {
                Button("Bold") {
                    // In a real implementation, we would handle formatting here
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
                    NotificationCenter.default.post(
                        name: Notification.Name("CreateNewChat"),
                        object: nil
                    )
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])
                
                Button("Show Chat Assistant") {
                    NotificationCenter.default.post(
                        name: Notification.Name("ToggleChatAssistant"),
                        object: nil
                    )
                }
                .keyboardShortcut("a", modifiers: .command)
                
                Divider()
                
                Button("AI Settings") {
                    NotificationCenter.default.post(
                        name: Notification.Name("ShowAISettings"),
                        object: nil
                    )
                }
            }
        }
    }
}
