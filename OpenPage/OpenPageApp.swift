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
    
    // Use shared app state manager for menu commands

    var body: some Scene {
        WindowGroup {
            MainView(modelContext: sharedModelContainer.mainContext)
                .modelContainer(sharedModelContainer)
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .ignoresSafeArea(.all)
                .preferredColorScheme(nil)
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    AppStateManager.shared.requestCreateDocument()
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("New Project") {
                    AppStateManager.shared.requestCreateProject()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
            
            CommandMenu("AI") {
                Button("New Chat") {
                    AppStateManager.shared.requestCreateChat()
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])
                
                Button("Show Chat Assistant") {
                    AppStateManager.shared.requestToggleChat()
                }
                .keyboardShortcut("a", modifiers: .command)
                
                Divider()
                
                Button("AI Settings") {
                    AppStateManager.shared.requestShowAISettings()
                }
            }
        }
    }
}
