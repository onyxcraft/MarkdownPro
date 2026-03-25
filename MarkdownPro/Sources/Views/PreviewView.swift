//
//  PreviewView.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI
import WebKit

struct PreviewView: NSViewRepresentable {
    let markdown: String
    let theme: EditorTheme

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let html = MarkdownRenderer.renderHTML(markdown, theme: theme)
        webView.loadHTMLString(html, baseURL: nil)
    }
}
