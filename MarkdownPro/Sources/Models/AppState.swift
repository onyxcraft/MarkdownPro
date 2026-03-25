//
//  AppState.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var currentTheme: EditorTheme = .light
    @Published var showPreview: Bool = true
    @Published var showSidebar: Bool = true
    @Published var showOutline: Bool = true
    @Published var focusModeEnabled: Bool = false
    @Published var typewriterModeEnabled: Bool = false
    @Published var fontSize: CGFloat = 14
    @Published var lineSpacing: CGFloat = 1.5
    @Published var folderURL: URL?
    @Published var markdownInsertCallback: ((String, String) -> Void)?

    func togglePreview() {
        showPreview.toggle()
    }

    func toggleFocusMode() {
        focusModeEnabled.toggle()
    }

    func toggleTypewriterMode() {
        typewriterModeEnabled.toggle()
    }

    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            folderURL = panel.url
        }
    }

    func insertMarkdown(_ prefix: String, _ suffix: String) {
        markdownInsertCallback?(prefix, suffix)
    }
}
