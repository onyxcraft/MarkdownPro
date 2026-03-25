//
//  MarkdownProApp.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

@main
struct MarkdownProApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        DocumentGroup(newDocument: { MarkdownDocument() }) { file in
            ContentView(document: file.$document)
                .environmentObject(appState)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open Folder...") {
                    appState.openFolder()
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }

            CommandGroup(replacing: .textFormatting) {
                Menu("Format") {
                    Button("Bold") {
                        appState.insertMarkdown("**", "**")
                    }
                    .keyboardShortcut("b", modifiers: .command)

                    Button("Italic") {
                        appState.insertMarkdown("*", "*")
                    }
                    .keyboardShortcut("i", modifiers: .command)

                    Button("Code") {
                        appState.insertMarkdown("`", "`")
                    }
                    .keyboardShortcut("k", modifiers: .command)

                    Divider()

                    Button("Insert Link") {
                        appState.insertMarkdown("[", "](url)")
                    }
                    .keyboardShortcut("l", modifiers: .command)

                    Button("Insert Image") {
                        appState.insertMarkdown("![", "](url)")
                    }
                    .keyboardShortcut("i", modifiers: [.command, .shift])
                }
            }

            CommandGroup(after: .toolbar) {
                Button("Toggle Preview") {
                    appState.togglePreview()
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])

                Button("Toggle Focus Mode") {
                    appState.toggleFocusMode()
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])

                Button("Toggle Typewriter Mode") {
                    appState.toggleTypewriterMode()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
