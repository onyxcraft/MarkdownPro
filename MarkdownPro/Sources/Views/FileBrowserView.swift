//
//  FileBrowserView.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

struct FileBrowserView: View {
    @EnvironmentObject var appState: AppState
    @State private var files: [URL] = []
    var onFileSelect: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Files")
                    .font(.headline)
                    .padding(8)
                Spacer()
                Button(action: {
                    appState.openFolder()
                    refreshFiles()
                }) {
                    Image(systemName: "folder")
                }
                .buttonStyle(.plain)
                .padding(8)
            }
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            if let folderURL = appState.folderURL {
                List(files, id: \.self) { file in
                    FileRowView(file: file, onSelect: onFileSelect)
                }
                .listStyle(.sidebar)
                .onAppear {
                    refreshFiles()
                }
            } else {
                VStack {
                    Spacer()
                    Text("No folder selected")
                        .foregroundColor(.secondary)
                    Button("Open Folder") {
                        appState.openFolder()
                        refreshFiles()
                    }
                    .padding()
                    Spacer()
                }
            }
        }
        .frame(minWidth: 200)
        .onChange(of: appState.folderURL) { _ in
            refreshFiles()
        }
    }

    private func refreshFiles() {
        guard let folderURL = appState.folderURL else {
            files = []
            return
        }

        do {
            let fileManager = FileManager.default
            let items = try fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )

            files = items.filter { url in
                url.pathExtension == "md" || url.pathExtension == "markdown"
            }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        } catch {
            print("Error reading directory: \(error)")
            files = []
        }
    }
}

struct FileRowView: View {
    let file: URL
    let onSelect: (URL) -> Void

    var body: some View {
        Button(action: {
            onSelect(file)
        }) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
                Text(file.lastPathComponent)
                    .lineLimit(1)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
