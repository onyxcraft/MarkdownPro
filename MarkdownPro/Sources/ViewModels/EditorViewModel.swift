//
//  EditorViewModel.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

class EditorViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @Published var wordCount: Int = 0
    @Published var characterCount: Int = 0
    @Published var outlineItems: [OutlineItem] = []
    @Published var findText: String = ""
    @Published var replaceText: String = ""
    @Published var useRegex: Bool = false
    @Published var caseSensitive: Bool = false

    func updateCounts() {
        characterCount = text.count
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        wordCount = words.count
    }

    func updateOutline() {
        var items: [OutlineItem] = []
        let lines = text.components(separatedBy: .newlines)
        var currentPosition = 0

        for line in lines {
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                let title = line.dropFirst(level).trimmingCharacters(in: .whitespaces)

                if !title.isEmpty && level <= 6 {
                    let range = NSRange(location: currentPosition, length: line.count)
                    let item = OutlineItem(level: level, title: title, range: range)
                    items.append(item)
                }
            }
            currentPosition += line.count + 1
        }

        outlineItems = buildHierarchy(items)
    }

    private func buildHierarchy(_ items: [OutlineItem]) -> [OutlineItem] {
        var result: [OutlineItem] = []
        var stack: [(item: OutlineItem, index: Int)] = []

        for item in items {
            while let last = stack.last, last.item.level >= item.level {
                stack.removeLast()
            }

            if let parent = stack.last {
                var updatedParent = parent.item
                updatedParent.children.append(item)
                if parent.index < result.count {
                    result[parent.index] = updatedParent
                }
            } else {
                result.append(item)
                stack.append((item: item, index: result.count - 1))
            }
        }

        return result
    }

    func findNext() {
        guard !findText.isEmpty else { return }

        let searchString = text as NSString
        let searchRange = NSRange(
            location: selectedRange.location + selectedRange.length,
            length: searchString.length - (selectedRange.location + selectedRange.length)
        )

        if useRegex {
            if let regex = try? NSRegularExpression(
                pattern: findText,
                options: caseSensitive ? [] : .caseInsensitive
            ) {
                if let match = regex.firstMatch(in: text, options: [], range: searchRange) {
                    selectedRange = match.range
                }
            }
        } else {
            let options: NSString.CompareOptions = caseSensitive ? [] : .caseInsensitive
            let range = searchString.range(
                of: findText,
                options: options,
                range: searchRange
            )
            if range.location != NSNotFound {
                selectedRange = range
            }
        }
    }

    func replaceNext() {
        guard !findText.isEmpty, selectedRange.length > 0 else { return }

        let nsText = text as NSString
        let selectedText = nsText.substring(with: selectedRange)

        let matches: Bool
        if useRegex {
            if let regex = try? NSRegularExpression(
                pattern: findText,
                options: caseSensitive ? [] : .caseInsensitive
            ) {
                matches = regex.firstMatch(
                    in: selectedText,
                    options: [],
                    range: NSRange(location: 0, length: selectedText.count)
                ) != nil
            } else {
                matches = false
            }
        } else {
            matches = caseSensitive
                ? selectedText == findText
                : selectedText.lowercased() == findText.lowercased()
        }

        if matches {
            text = nsText.replacingCharacters(in: selectedRange, with: replaceText)
            selectedRange = NSRange(location: selectedRange.location, length: replaceText.count)
            findNext()
        }
    }

    func replaceAll() {
        guard !findText.isEmpty else { return }

        if useRegex {
            if let regex = try? NSRegularExpression(
                pattern: findText,
                options: caseSensitive ? [] : .caseInsensitive
            ) {
                text = regex.stringByReplacingMatches(
                    in: text,
                    options: [],
                    range: NSRange(location: 0, length: text.count),
                    withTemplate: replaceText
                )
            }
        } else {
            let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
            text = text.replacingOccurrences(
                of: findText,
                with: replaceText,
                options: options
            )
        }
    }
}
