# Changelog

All notable changes to MarkdownPro will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-25

### Added
- Initial release of MarkdownPro
- Split-pane editor with live preview
- Syntax highlighting for Markdown
- File browser sidebar for .md file management
- Document outline panel showing header hierarchy
- Focus mode for distraction-free writing
- Typewriter mode with centered cursor
- Word and character count in status bar
- Find & replace with regex support
- Five custom themes: Light, Dark, Solarized Light, Solarized Dark, and Dracula
- Table editor assistant for easy table creation
- Image drag & drop support
- Export to HTML with theme-aware styling
- Export to PDF with professional formatting
- Export to DOCX for Microsoft Word compatibility
- iCloud document synchronization
- Comprehensive keyboard shortcuts
- Preferences panel for customization
- macOS 14+ support
- App Store ready with bundle ID: com.lopodragon.markdownpro

### Technical Details
- Built with SwiftUI and AppKit
- MVVM architecture
- No external dependencies
- WebKit-based preview rendering
- Native markdown parser and renderer
- Sandboxed application with proper entitlements

### Known Limitations
- DOCX export uses RTF conversion (limited formatting)
- Custom CSS not yet supported for preview
- No markdown extensions support (coming in future versions)

## [Unreleased]

### Planned Features
- Custom CSS for preview
- Markdown extensions (footnotes, task lists, etc.)
- Multi-file search across folders
- Version history
- Customizable keyboard shortcuts
- Export templates
- Statistics dashboard
- Code block language syntax highlighting
- Mermaid diagram support
- LaTeX math equation support
