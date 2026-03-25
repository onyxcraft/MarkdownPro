//
//  ExportService.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import AppKit
import WebKit

class ExportService {
    static func exportToHTML(_ markdown: String, theme: EditorTheme, completion: @escaping (URL?) -> Void) {
        let html = MarkdownRenderer.renderHTML(markdown, theme: theme)

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.html]
        savePanel.nameFieldStringValue = "document.html"

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else {
                completion(nil)
                return
            }

            do {
                try html.write(to: url, atomically: true, encoding: .utf8)
                completion(url)
            } catch {
                print("Error exporting HTML: \(error)")
                completion(nil)
            }
        }
    }

    static func exportToPDF(_ markdown: String, theme: EditorTheme, completion: @escaping (URL?) -> Void) {
        let html = MarkdownRenderer.renderHTML(markdown, theme: theme)

        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 800, height: 1000))
        webView.loadHTMLString(html, baseURL: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let pdfConfiguration = WKPDFConfiguration()
            pdfConfiguration.rect = .zero

            webView.createPDF(configuration: pdfConfiguration) { result in
                switch result {
                case .success(let data):
                    let savePanel = NSSavePanel()
                    savePanel.allowedContentTypes = [.pdf]
                    savePanel.nameFieldStringValue = "document.pdf"

                    savePanel.begin { response in
                        guard response == .OK, let url = savePanel.url else {
                            completion(nil)
                            return
                        }

                        do {
                            try data.write(to: url)
                            completion(url)
                        } catch {
                            print("Error saving PDF: \(error)")
                            completion(nil)
                        }
                    }

                case .failure(let error):
                    print("Error creating PDF: \(error)")
                    completion(nil)
                }
            }
        }
    }

    static func exportToDOCX(_ markdown: String, completion: @escaping (URL?) -> Void) {
        let html = MarkdownRenderer.renderHTML(markdown, theme: .light)

        let attributedString = try? NSAttributedString(
            data: html.data(using: .utf8) ?? Data(),
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )

        guard let attrString = attributedString else {
            completion(nil)
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.init(filenameExtension: "docx")].compactMap { $0 }
        savePanel.nameFieldStringValue = "document.docx"

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else {
                completion(nil)
                return
            }

            do {
                let rtfData = try attrString.data(
                    from: NSRange(location: 0, length: attrString.length),
                    documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
                )

                try rtfData.write(to: url)
                completion(url)
            } catch {
                print("Error exporting DOCX: \(error)")
                completion(nil)
            }
        }
    }
}
