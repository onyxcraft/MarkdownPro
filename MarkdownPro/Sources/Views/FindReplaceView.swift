//
//  FindReplaceView.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

struct FindReplaceView: View {
    @ObservedObject var viewModel: EditorViewModel
    @State private var showReplace = false

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Find", text: $viewModel.findText)
                    .textFieldStyle(.roundedBorder)

                Button(action: {
                    viewModel.findNext()
                }) {
                    Image(systemName: "chevron.down")
                }
                .buttonStyle(.borderless)

                Toggle("", isOn: $showReplace)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .help("Show Replace")
            }

            if showReplace {
                HStack {
                    Image(systemName: "arrow.turn.down.left")
                        .foregroundColor(.secondary)
                    TextField("Replace", text: $viewModel.replaceText)
                        .textFieldStyle(.roundedBorder)

                    Button("Replace") {
                        viewModel.replaceNext()
                    }
                    .buttonStyle(.borderless)

                    Button("All") {
                        viewModel.replaceAll()
                    }
                    .buttonStyle(.borderless)
                }
            }

            HStack {
                Toggle("Regex", isOn: $viewModel.useRegex)
                    .toggleStyle(.checkbox)
                Toggle("Case Sensitive", isOn: $viewModel.caseSensitive)
                    .toggleStyle(.checkbox)
                Spacer()
            }
            .font(.caption)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}
