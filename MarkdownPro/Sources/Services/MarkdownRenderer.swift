//
//  MarkdownRenderer.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import Foundation

class MarkdownRenderer {
    static func renderHTML(_ markdown: String, theme: EditorTheme = .light) -> String {
        let html = convertMarkdownToHTML(markdown)
        return wrapInHTMLTemplate(html, theme: theme)
    }

    private static func convertMarkdownToHTML(_ markdown: String) -> String {
        var html = markdown

        html = processCodeBlocks(html)
        html = processInlineCode(html)
        html = processHeaders(html)
        html = processBold(html)
        html = processItalic(html)
        html = processLinks(html)
        html = processImages(html)
        html = processBlockquotes(html)
        html = processLists(html)
        html = processTables(html)
        html = processHorizontalRules(html)
        html = processParagraphs(html)

        return html
    }

    private static func processCodeBlocks(_ text: String) -> String {
        let pattern = "```([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }

        let nsText = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))

        var result = text
        for match in matches.reversed() {
            let codeContent = nsText.substring(with: match.range(at: 1))
            let escapedCode = escapeHTML(codeContent.trimmingCharacters(in: .newlines))
            let replacement = "<pre><code>\(escapedCode)</code></pre>"
            result = (result as NSString).replacingCharacters(in: match.range, with: replacement)
        }

        return result
    }

    private static func processInlineCode(_ text: String) -> String {
        let pattern = "`([^`]+)`"
        return replacePattern(pattern, in: text) { match in
            "<code>\(escapeHTML(match))</code>"
        }
    }

    private static func processHeaders(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                if level <= 6 {
                    let content = line.dropFirst(level).trimmingCharacters(in: .whitespaces)
                    result.append("<h\(level)>\(content)</h\(level)>")
                    continue
                }
            }
            result.append(line)
        }

        return result.joined(separator: "\n")
    }

    private static func processBold(_ text: String) -> String {
        var result = text
        result = replacePattern("\\*\\*(.+?)\\*\\*", in: result) { "<strong>\($0)</strong>" }
        result = replacePattern("__(.+?)__", in: result) { "<strong>\($0)</strong>" }
        return result
    }

    private static func processItalic(_ text: String) -> String {
        var result = text
        result = replacePattern("\\*(.+?)\\*", in: result) { "<em>\($0)</em>" }
        result = replacePattern("_(.+?)_", in: result) { "<em>\($0)</em>" }
        return result
    }

    private static func processLinks(_ text: String) -> String {
        let pattern = "\\[([^\\]]+)\\]\\(([^)]+)\\)"
        return replacePattern(pattern, in: text, groups: 2) { groups in
            "<a href=\"\(groups[1])\">\(groups[0])</a>"
        }
    }

    private static func processImages(_ text: String) -> String {
        let pattern = "!\\[([^\\]]*)\\]\\(([^)]+)\\)"
        return replacePattern(pattern, in: text, groups: 2) { groups in
            "<img src=\"\(groups[1])\" alt=\"\(groups[0])\" />"
        }
    }

    private static func processBlockquotes(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        var result: [String] = []
        var inBlockquote = false
        var blockquoteContent: [String] = []

        for line in lines {
            if line.hasPrefix(">") {
                if !inBlockquote {
                    inBlockquote = true
                }
                blockquoteContent.append(line.dropFirst().trimmingCharacters(in: .whitespaces))
            } else {
                if inBlockquote {
                    result.append("<blockquote>\(blockquoteContent.joined(separator: "<br>"))</blockquote>")
                    blockquoteContent = []
                    inBlockquote = false
                }
                result.append(line)
            }
        }

        if inBlockquote {
            result.append("<blockquote>\(blockquoteContent.joined(separator: "<br>"))</blockquote>")
        }

        return result.joined(separator: "\n")
    }

    private static func processLists(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        var result: [String] = []
        var inList = false
        var listItems: [String] = []
        var listType = ""

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
                if !inList || listType != "ul" {
                    if inList {
                        result.append(closeList(listType, items: listItems))
                        listItems = []
                    }
                    inList = true
                    listType = "ul"
                }
                listItems.append(String(trimmed.dropFirst(2)))
            } else if let match = trimmed.range(of: "^\\d+\\. ", options: .regularExpression) {
                if !inList || listType != "ol" {
                    if inList {
                        result.append(closeList(listType, items: listItems))
                        listItems = []
                    }
                    inList = true
                    listType = "ol"
                }
                listItems.append(String(trimmed[match.upperBound...]))
            } else {
                if inList {
                    result.append(closeList(listType, items: listItems))
                    listItems = []
                    inList = false
                }
                result.append(line)
            }
        }

        if inList {
            result.append(closeList(listType, items: listItems))
        }

        return result.joined(separator: "\n")
    }

    private static func closeList(_ type: String, items: [String]) -> String {
        let listItems = items.map { "<li>\($0)</li>" }.joined(separator: "\n")
        return "<\(type)>\n\(listItems)\n</\(type)>"
    }

    private static func processTables(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        var result: [String] = []
        var i = 0

        while i < lines.count {
            let line = lines[i]
            if line.contains("|") && i + 1 < lines.count {
                let nextLine = lines[i + 1]
                if nextLine.contains("|") && nextLine.contains("-") {
                    var tableLines: [String] = [line]
                    i += 2

                    while i < lines.count && lines[i].contains("|") {
                        tableLines.append(lines[i])
                        i += 1
                    }

                    result.append(buildTable(tableLines))
                    continue
                }
            }
            result.append(line)
            i += 1
        }

        return result.joined(separator: "\n")
    }

    private static func buildTable(_ lines: [String]) -> String {
        guard !lines.isEmpty else { return "" }

        let headers = lines[0].split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        let rows = lines.dropFirst().map { line in
            line.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        }

        var html = "<table>\n<thead>\n<tr>"
        for header in headers where !header.isEmpty {
            html += "<th>\(header)</th>"
        }
        html += "</tr>\n</thead>\n<tbody>\n"

        for row in rows {
            html += "<tr>"
            for cell in row where !cell.isEmpty && !cell.contains("-") {
                html += "<td>\(cell)</td>"
            }
            html += "</tr>\n"
        }

        html += "</tbody>\n</table>"
        return html
    }

    private static func processHorizontalRules(_ text: String) -> String {
        var result = text
        result = replacePattern("^---$", in: result) { _ in "<hr>" }
        result = replacePattern("^\\*\\*\\*$", in: result) { _ in "<hr>" }
        return result
    }

    private static func processParagraphs(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        var result: [String] = []
        var paragraph: [String] = []

        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !paragraph.isEmpty {
                    let p = paragraph.joined(separator: " ")
                    if !p.hasPrefix("<") {
                        result.append("<p>\(p)</p>")
                    } else {
                        result.append(p)
                    }
                    paragraph = []
                }
                result.append("")
            } else if line.hasPrefix("<") {
                if !paragraph.isEmpty {
                    result.append("<p>\(paragraph.joined(separator: " "))</p>")
                    paragraph = []
                }
                result.append(line)
            } else {
                paragraph.append(line)
            }
        }

        if !paragraph.isEmpty {
            result.append("<p>\(paragraph.joined(separator: " "))</p>")
        }

        return result.joined(separator: "\n")
    }

    private static func wrapInHTMLTemplate(_ html: String, theme: EditorTheme) -> String {
        let backgroundColor = theme.backgroundColor.toHex()
        let textColor = theme.textColor.toHex()
        let accentColor = theme.accentColor.toHex()

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: \(textColor);
                    background-color: \(backgroundColor);
                    padding: 20px;
                    max-width: 800px;
                    margin: 0 auto;
                }
                h1, h2, h3, h4, h5, h6 { margin-top: 24px; margin-bottom: 16px; font-weight: 600; line-height: 1.25; }
                h1 { font-size: 2em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
                h2 { font-size: 1.5em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
                code { background-color: rgba(175, 184, 193, 0.2); padding: 0.2em 0.4em; border-radius: 3px; font-family: 'SF Mono', Monaco, monospace; font-size: 0.9em; }
                pre { background-color: rgba(175, 184, 193, 0.2); padding: 16px; border-radius: 6px; overflow: auto; }
                pre code { background-color: transparent; padding: 0; }
                blockquote { margin: 0; padding: 0 1em; color: #6a737d; border-left: 0.25em solid #dfe2e5; }
                a { color: \(accentColor); text-decoration: none; }
                a:hover { text-decoration: underline; }
                img { max-width: 100%; height: auto; }
                table { border-collapse: collapse; width: 100%; margin: 16px 0; }
                table th, table td { padding: 6px 13px; border: 1px solid #dfe2e5; }
                table th { font-weight: 600; background-color: rgba(175, 184, 193, 0.1); }
                table tr:nth-child(even) { background-color: rgba(175, 184, 193, 0.05); }
                hr { height: 0.25em; padding: 0; margin: 24px 0; background-color: #e1e4e8; border: 0; }
                ul, ol { padding-left: 2em; }
            </style>
        </head>
        <body>
        \(html)
        </body>
        </html>
        """
    }

    private static func replacePattern(_ pattern: String, in text: String, handler: (String) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }

        let nsText = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))

        var result = text
        for match in matches.reversed() {
            if match.numberOfRanges > 1 {
                let captured = nsText.substring(with: match.range(at: 1))
                let replacement = handler(captured)
                result = (result as NSString).replacingCharacters(in: match.range, with: replacement)
            }
        }

        return result
    }

    private static func replacePattern(_ pattern: String, in text: String, groups: Int, handler: ([String]) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }

        let nsText = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))

        var result = text
        for match in matches.reversed() {
            var capturedGroups: [String] = []
            for i in 1...groups {
                if match.numberOfRanges > i {
                    capturedGroups.append(nsText.substring(with: match.range(at: i)))
                }
            }
            let replacement = handler(capturedGroups)
            result = (result as NSString).replacingCharacters(in: match.range, with: replacement)
        }

        return result
    }

    private static func escapeHTML(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

extension Color {
    func toHex() -> String {
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            return "#000000"
        }

        let r = Int(rgbColor.redComponent * 255)
        let g = Int(rgbColor.greenComponent * 255)
        let b = Int(rgbColor.blueComponent * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
