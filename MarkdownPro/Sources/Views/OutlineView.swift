//
//  OutlineView.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

struct OutlineView: View {
    let items: [OutlineItem]
    var onItemSelect: (OutlineItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Outline")
                    .font(.headline)
                    .padding(8)
                Spacer()
            }
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            if items.isEmpty {
                VStack {
                    Spacer()
                    Text("No headers found")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(items) { item in
                            OutlineItemView(item: item, onSelect: onItemSelect)
                        }
                    }
                    .padding(8)
                }
            }
        }
        .frame(minWidth: 200)
    }
}

struct OutlineItemView: View {
    let item: OutlineItem
    let onSelect: (OutlineItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Button(action: {
                onSelect(item)
            }) {
                HStack {
                    Text(item.title)
                        .font(.system(size: max(14 - CGFloat(item.level - 1), 10)))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.leading, CGFloat(item.level - 1) * 12)
            }
            .buttonStyle(.plain)

            if !item.children.isEmpty {
                ForEach(item.children) { child in
                    OutlineItemView(item: child, onSelect: onSelect)
                }
            }
        }
    }
}
