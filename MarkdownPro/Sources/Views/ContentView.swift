//
//  ContentView.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: MarkdownDocument
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = EditorViewModel()
    @State private var showFindReplace = false
    @State private var showTableEditor = false

    var body: some View {
        ScrollView {
            HSplitView {
            if appState.showSidebar {
                FileBrowserView { url in
                    loadFile(url)
                }
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            }

            VStack(spacing: 0) {
                if showFindReplace {
                    FindReplaceView(viewModel: viewModel)
                    Divider()
                }

                if appState.showPreview {
                    HSplitView {
                        MarkdownEditorView(
                            text: $document.text,
                            selectedRange: $viewModel.selectedRange,
                            theme: appState.currentTheme,
                            focusMode: appState.focusModeEnabled,
                            typewriterMode: appState.typewriterModeEnabled
                        ) { newText in
                            viewModel.text = newText
                            viewModel.updateCounts()
                            viewModel.updateOutline()
                        }

                        PreviewView(
                            markdown: document.text,
                            theme: appState.currentTheme
                        )
                    }
                } else {
                    MarkdownEditorView(
                        text: $document.text,
                        selectedRange: $viewModel.selectedRange,
                        theme: appState.currentTheme,
                        focusMode: appState.focusModeEnabled,
                        typewriterMode: appState.typewriterModeEnabled
                    ) { newText in
                        viewModel.text = newText
                        viewModel.updateCounts()
                        viewModel.updateOutline()
                    }
                }

                Divider()

                HStack {
                    Text("Words: \(viewModel.wordCount)")
                    Text("Characters: \(viewModel.characterCount)")
                    Spacer()
                }
                .font(.caption)
                .padding(4)
                .background(Color(nsColor: .controlBackgroundColor))
            }

            if appState.showOutline {
                OutlineView(items: viewModel.outlineItems) { item in
                    viewModel.selectedRange = item.range
                }
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            }
            }
            .frame(minWidth: 600, minHeight: 600)
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    appState.showSidebar.toggle()
                }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Sidebar")

                Button(action: {
                    appState.showOutline.toggle()
                }) {
                    Image(systemName: "sidebar.right")
                }
                .help("Toggle Outline")

                Divider()

                Button(action: {
                    appState.togglePreview()
                }) {
                    Image(systemName: appState.showPreview ? "doc.text" : "doc.text.viewfinder")
                }
                .help("Toggle Preview")

                Button(action: {
                    appState.toggleFocusMode()
                }) {
                    Image(systemName: "eye")
                }
                .help("Toggle Focus Mode")
                .foregroundColor(appState.focusModeEnabled ? .accentColor : .primary)

                Button(action: {
                    appState.toggleTypewriterMode()
                }) {
                    Image(systemName: "text.aligncenter")
                }
                .help("Toggle Typewriter Mode")
                .foregroundColor(appState.typewriterModeEnabled ? .accentColor : .primary)

                Divider()

                Button(action: {
                    showFindReplace.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                }
                .help("Find & Replace")

                Button(action: {
                    showTableEditor.toggle()
                }) {
                    Image(systemName: "tablecells")
                }
                .help("Insert Table")

                Divider()

                Menu {
                    Button("Export to HTML") {
                        ExportService.exportToHTML(document.text, theme: appState.currentTheme) { url in
                            if let url = url {
                                print("Exported to: \(url.path)")
                            }
                        }
                    }

                    Button("Export to PDF") {
                        ExportService.exportToPDF(document.text, theme: appState.currentTheme) { url in
                            if let url = url {
                                print("Exported to: \(url.path)")
                            }
                        }
                    }

                    Button("Export to DOCX") {
                        ExportService.exportToDOCX(document.text) { url in
                            if let url = url {
                                print("Exported to: \(url.path)")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("Export")
            }
        }
        .sheet(isPresented: $showTableEditor) {
            TableEditorView(isPresented: $showTableEditor) { table in
                insertText(table)
            }
        }
        .onAppear {
            viewModel.text = document.text
            viewModel.updateCounts()
            viewModel.updateOutline()
        }
        .onDrop(of: [.image, .fileURL], isTargeted: nil) { providers in
            handleDrop(providers: providers)
        }
    }

    private func loadFile(_ url: URL) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            document.text = content
            viewModel.text = content
            viewModel.updateCounts()
            viewModel.updateOutline()
        } catch {
            print("Error loading file: \(error)")
        }
    }

    private func insertText(_ text: String) {
        let currentText = document.text
        let insertPosition = viewModel.selectedRange.location

        let before = String(currentText.prefix(insertPosition))
        let after = String(currentText.suffix(currentText.count - insertPosition))

        document.text = before + text + after
        viewModel.text = document.text
        viewModel.updateCounts()
        viewModel.updateOutline()
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            let markdown = "![\(url.lastPathComponent)](\(url.path))"
                            insertText(markdown)
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}
