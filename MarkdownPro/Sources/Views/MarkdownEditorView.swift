//
//  MarkdownEditorView.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI
import AppKit

struct MarkdownEditorView: NSViewRepresentable {
    @Binding var text: String
    @Binding var selectedRange: NSRange
    @EnvironmentObject var appState: AppState
    var theme: EditorTheme
    var focusMode: Bool
    var typewriterMode: Bool
    var onTextChange: ((String) -> Void)?

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = NSFont.monospacedSystemFont(ofSize: appState.fontSize, weight: .regular)
        textView.textColor = NSColor(theme.textColor)
        textView.backgroundColor = NSColor(theme.backgroundColor)
        textView.insertionPointColor = NSColor(theme.accentColor)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.allowsUndo = true

        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        appState.markdownInsertCallback = { prefix, suffix in
            context.coordinator.insertMarkdown(prefix: prefix, suffix: suffix, in: textView)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        if textView.string != text {
            textView.string = text
            applySyntaxHighlighting(to: textView)
        }

        textView.font = NSFont.monospacedSystemFont(ofSize: appState.fontSize, weight: .regular)
        textView.textColor = NSColor(theme.textColor)
        textView.backgroundColor = NSColor(theme.backgroundColor)
        textView.insertionPointColor = NSColor(theme.accentColor)

        if typewriterMode {
            centerCursorVertically(in: textView, scrollView: scrollView)
        }

        if focusMode {
            applyFocusMode(to: textView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownEditorView

        init(_ parent: MarkdownEditorView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.applySyntaxHighlighting(to: textView)
            parent.onTextChange?(textView.string)
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.selectedRange = textView.selectedRange()
        }

        func insertMarkdown(prefix: String, suffix: String, in textView: NSTextView) {
            let selectedRange = textView.selectedRange()
            let text = textView.string as NSString
            let selectedText = text.substring(with: selectedRange)

            let newText = "\(prefix)\(selectedText)\(suffix)"
            textView.insertText(newText, replacementRange: selectedRange)

            let newPosition = selectedRange.location + prefix.count
            let newLength = selectedText.count
            textView.setSelectedRange(NSRange(location: newPosition, length: newLength))
        }
    }

    private func applySyntaxHighlighting(to textView: NSTextView) {
        let text = textView.string
        let fullRange = NSRange(location: 0, length: text.count)

        let storage = textView.textStorage!
        storage.beginEditing()

        storage.removeAttribute(.foregroundColor, range: fullRange)

        let baseColor = NSColor(theme.textColor)
        storage.addAttribute(.foregroundColor, value: baseColor, range: fullRange)

        highlightHeaders(in: storage, text: text)
        highlightCodeBlocks(in: storage, text: text)
        highlightInlineCode(in: storage, text: text)
        highlightBold(in: storage, text: text)
        highlightItalic(in: storage, text: text)
        highlightLinks(in: storage, text: text)
        highlightBlockquotes(in: storage, text: text)

        storage.endEditing()
    }

    private func highlightHeaders(in storage: NSTextStorage, text: String) {
        let pattern = "^#{1,6}\\s+.+$"
        highlightPattern(pattern, in: storage, text: text, color: theme.syntaxColors.heading, options: .anchorsMatchLines)
    }

    private func highlightCodeBlocks(in storage: NSTextStorage, text: String) {
        let pattern = "```[\\s\\S]*?```"
        highlightPattern(pattern, in: storage, text: text, color: theme.syntaxColors.code)
    }

    private func highlightInlineCode(in storage: NSTextStorage, text: String) {
        let pattern = "`[^`]+`"
        highlightPattern(pattern, in: storage, text: text, color: theme.syntaxColors.code)
    }

    private func highlightBold(in storage: NSTextStorage, text: String) {
        highlightPattern("\\*\\*[^*]+\\*\\*", in: storage, text: text, color: theme.syntaxColors.bold)
        highlightPattern("__[^_]+__", in: storage, text: text, color: theme.syntaxColors.bold)
    }

    private func highlightItalic(in storage: NSTextStorage, text: String) {
        highlightPattern("\\*[^*]+\\*", in: storage, text: text, color: theme.syntaxColors.italic)
        highlightPattern("_[^_]+_", in: storage, text: text, color: theme.syntaxColors.italic)
    }

    private func highlightLinks(in storage: NSTextStorage, text: String) {
        let pattern = "\\[([^\\]]+)\\]\\(([^)]+)\\)"
        highlightPattern(pattern, in: storage, text: text, color: theme.syntaxColors.link)
    }

    private func highlightBlockquotes(in storage: NSTextStorage, text: String) {
        let pattern = "^>\\s+.+$"
        highlightPattern(pattern, in: storage, text: text, color: theme.syntaxColors.quote, options: .anchorsMatchLines)
    }

    private func highlightPattern(_ pattern: String, in storage: NSTextStorage, text: String, color: Color, options: NSRegularExpression.Options = []) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }

        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        for match in matches {
            storage.addAttribute(.foregroundColor, value: NSColor(color), range: match.range)
        }
    }

    private func centerCursorVertically(in textView: NSTextView, scrollView: NSScrollView) {
        let selectedRange = textView.selectedRange()
        guard let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }

        let glyphRange = layoutManager.glyphRange(forCharacterRange: selectedRange, actualCharacterRange: nil)
        let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        let visibleRect = scrollView.documentVisibleRect
        let offset = rect.midY - visibleRect.height / 2

        if offset > 0 {
            scrollView.contentView.scroll(to: NSPoint(x: 0, y: offset))
        }
    }

    private func applyFocusMode(to textView: NSTextView) {
        guard let layoutManager = textView.layoutManager else { return }

        let text = textView.string as NSString
        let selectedRange = textView.selectedRange()

        let paragraphRange = text.paragraphRange(for: selectedRange)

        let storage = textView.textStorage!
        storage.beginEditing()

        let fullRange = NSRange(location: 0, length: text.length)
        storage.addAttribute(.foregroundColor, value: NSColor(theme.textColor).withAlphaComponent(0.3), range: fullRange)

        storage.addAttribute(.foregroundColor, value: NSColor(theme.textColor), range: paragraphRange)

        storage.endEditing()
    }
}
