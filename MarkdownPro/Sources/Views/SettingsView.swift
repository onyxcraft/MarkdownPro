//
//  SettingsView.swift
//  MarkdownPro
//
//  Created on 2026-03-25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            GeneralSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            EditorSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label("Editor", systemImage: "text.alignleft")
                }

            ThemeSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label("Theme", systemImage: "paintbrush")
                }
        }
        .frame(width: 500, height: 300)
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section {
                Toggle("Show Preview by Default", isOn: $appState.showPreview)
                Toggle("Show Sidebar by Default", isOn: $appState.showSidebar)
                Toggle("Show Outline by Default", isOn: $appState.showOutline)
            }
        }
        .padding(20)
    }
}

struct EditorSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Font Size:")
                    Slider(value: $appState.fontSize, in: 10...24, step: 1)
                    Text("\(Int(appState.fontSize))")
                        .frame(width: 30)
                }

                HStack {
                    Text("Line Spacing:")
                    Slider(value: $appState.lineSpacing, in: 1.0...2.5, step: 0.1)
                    Text(String(format: "%.1f", appState.lineSpacing))
                        .frame(width: 30)
                }
            }
        }
        .padding(20)
    }
}

struct ThemeSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Picker("Editor Theme:", selection: $appState.currentTheme) {
                ForEach(EditorTheme.allCases) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .pickerStyle(.radioGroup)
        }
        .padding(20)
    }
}
