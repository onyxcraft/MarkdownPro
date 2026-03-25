//
//  TableEditorView.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

struct TableEditorView: View {
    @State private var rows = 3
    @State private var columns = 3
    @State private var alignment: TableAlignment = .left
    @Binding var isPresented: Bool
    var onInsert: (String) -> Void

    enum TableAlignment: String, CaseIterable {
        case left = "Left"
        case center = "Center"
        case right = "Right"

        var markdown: String {
            switch self {
            case .left: return ":---"
            case .center: return ":---:"
            case .right: return "---:"
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Insert Table")
                .font(.headline)

            HStack {
                Text("Rows:")
                Stepper("\(rows)", value: $rows, in: 1...20)
                    .frame(width: 120)
            }

            HStack {
                Text("Columns:")
                Stepper("\(columns)", value: $columns, in: 1...10)
                    .frame(width: 120)
            }

            Picker("Alignment:", selection: $alignment) {
                ForEach(TableAlignment.allCases, id: \.self) { align in
                    Text(align.rawValue).tag(align)
                }
            }
            .pickerStyle(.radioGroup)

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Button("Insert") {
                    insertTable()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 300)
    }

    private func insertTable() {
        var table = ""

        let headerRow = (0..<columns).map { "Header \($0 + 1)" }
        table += "| " + headerRow.joined(separator: " | ") + " |\n"

        let separatorRow = (0..<columns).map { _ in alignment.markdown }
        table += "| " + separatorRow.joined(separator: " | ") + " |\n"

        for row in 0..<rows {
            let cells = (0..<columns).map { "Cell \(row + 1),\($0 + 1)" }
            table += "| " + cells.joined(separator: " | ") + " |\n"
        }

        onInsert(table)
        isPresented = false
    }
}
