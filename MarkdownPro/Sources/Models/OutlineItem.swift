//
//  OutlineItem.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import Foundation

struct OutlineItem: Identifiable, Hashable {
    let id = UUID()
    let level: Int
    let title: String
    let range: NSRange
    var children: [OutlineItem] = []

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: OutlineItem, rhs: OutlineItem) -> Bool {
        lhs.id == rhs.id
    }
}
