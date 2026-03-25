//
//  Theme.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

enum EditorTheme: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case solarizedLight = "Solarized Light"
    case solarizedDark = "Solarized Dark"
    case dracula = "Dracula"

    var id: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .light:
            return Color(nsColor: .textBackgroundColor)
        case .dark:
            return Color(red: 0.16, green: 0.17, blue: 0.21)
        case .solarizedLight:
            return Color(red: 0.99, green: 0.96, blue: 0.89)
        case .solarizedDark:
            return Color(red: 0.0, green: 0.17, blue: 0.21)
        case .dracula:
            return Color(red: 0.16, green: 0.16, blue: 0.22)
        }
    }

    var textColor: Color {
        switch self {
        case .light:
            return Color(nsColor: .textColor)
        case .dark:
            return Color(red: 0.83, green: 0.84, blue: 0.86)
        case .solarizedLight:
            return Color(red: 0.40, green: 0.48, blue: 0.51)
        case .solarizedDark:
            return Color(red: 0.51, green: 0.58, blue: 0.59)
        case .dracula:
            return Color(red: 0.95, green: 0.95, blue: 0.95)
        }
    }

    var accentColor: Color {
        switch self {
        case .light:
            return .blue
        case .dark:
            return Color(red: 0.40, green: 0.62, blue: 1.0)
        case .solarizedLight, .solarizedDark:
            return Color(red: 0.15, green: 0.55, blue: 0.82)
        case .dracula:
            return Color(red: 0.74, green: 0.58, blue: 0.98)
        }
    }

    var syntaxColors: SyntaxColors {
        switch self {
        case .light:
            return SyntaxColors(
                heading: Color(red: 0.0, green: 0.0, blue: 0.8),
                bold: Color(red: 0.2, green: 0.2, blue: 0.2),
                italic: Color(red: 0.3, green: 0.3, blue: 0.3),
                code: Color(red: 0.8, green: 0.2, blue: 0.2),
                link: Color(red: 0.0, green: 0.5, blue: 0.8),
                quote: Color(red: 0.5, green: 0.5, blue: 0.5)
            )
        case .dark:
            return SyntaxColors(
                heading: Color(red: 0.4, green: 0.76, blue: 0.95),
                bold: Color(red: 0.98, green: 0.84, blue: 0.65),
                italic: Color(red: 0.90, green: 0.80, blue: 0.70),
                code: Color(red: 0.95, green: 0.61, blue: 0.73),
                link: Color(red: 0.52, green: 0.77, blue: 0.98),
                quote: Color(red: 0.60, green: 0.65, blue: 0.70)
            )
        case .solarizedLight:
            return SyntaxColors(
                heading: Color(red: 0.15, green: 0.55, blue: 0.82),
                bold: Color(red: 0.71, green: 0.54, blue: 0.0),
                italic: Color(red: 0.52, green: 0.60, blue: 0.0),
                code: Color(red: 0.86, green: 0.20, blue: 0.18),
                link: Color(red: 0.16, green: 0.63, blue: 0.60),
                quote: Color(red: 0.58, green: 0.63, blue: 0.63)
            )
        case .solarizedDark:
            return SyntaxColors(
                heading: Color(red: 0.15, green: 0.55, blue: 0.82),
                bold: Color(red: 0.71, green: 0.54, blue: 0.0),
                italic: Color(red: 0.52, green: 0.60, blue: 0.0),
                code: Color(red: 0.86, green: 0.20, blue: 0.18),
                link: Color(red: 0.16, green: 0.63, blue: 0.60),
                quote: Color(red: 0.58, green: 0.63, blue: 0.63)
            )
        case .dracula:
            return SyntaxColors(
                heading: Color(red: 0.74, green: 0.58, blue: 0.98),
                bold: Color(red: 1.0, green: 0.47, blue: 0.78),
                italic: Color(red: 0.95, green: 0.98, blue: 0.45),
                code: Color(red: 1.0, green: 0.33, blue: 0.33),
                link: Color(red: 0.55, green: 0.91, blue: 0.99),
                quote: Color(red: 0.62, green: 0.62, blue: 0.71)
            )
        }
    }
}

struct SyntaxColors {
    let heading: Color
    let bold: Color
    let italic: Color
    let code: Color
    let link: Color
    let quote: Color
}
