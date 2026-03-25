# MarkdownPro

A professional Markdown editor for macOS 14+, built with SwiftUI and AppKit.

## Overview

MarkdownPro is a feature-rich Markdown editor designed for professional writers, developers, and content creators. With its clean interface, powerful editing features, and seamless iCloud integration, MarkdownPro makes writing in Markdown a pleasure.

## Features

### Core Editing
- **Split-Pane Interface**: Edit on the left, preview on the right with toggle support for single-pane mode
- **Syntax Highlighting**: Real-time syntax highlighting for Markdown elements
- **Live Preview**: WebKit-based preview that updates as you type

### Organization
- **File Browser**: Built-in sidebar for managing your `.md` files
- **Document Outline**: Automatically generated table of contents from headers
- **iCloud Sync**: Seamlessly sync your documents across all your Apple devices

### Writing Modes
- **Focus Mode**: Dim everything except the current paragraph for distraction-free writing
- **Typewriter Mode**: Keep your cursor centered vertically for comfortable long-form writing
- **Custom Themes**: Choose from Light, Dark, Solarized Light, Solarized Dark, and Dracula themes

### Productivity Tools
- **Find & Replace**: Powerful search with regex support and case-sensitive options
- **Table Editor**: Visual assistant for creating and editing Markdown tables
- **Word & Character Count**: Real-time statistics displayed in the status bar
- **Image Support**: Drag and drop images directly into your documents

### Export Options
- Export to HTML with theme-aware styling
- Export to PDF with professional formatting
- Export to DOCX for Microsoft Word compatibility

## System Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for development)
- Apple Developer account (for iCloud entitlements)

## Installation

### From Source

1. Clone this repository
2. Open `MarkdownPro.xcodeproj` in Xcode
3. Configure your development team in the project settings
4. Enable iCloud capability and configure your iCloud container
5. Build and run

### App Store

Available on the Mac App Store for $5.99 USD (one-time purchase)

## Architecture

MarkdownPro follows the MVVM (Model-View-ViewModel) architectural pattern:

- **Models**: Data structures for documents, themes, and application state
- **Views**: SwiftUI and AppKit views for the user interface
- **ViewModels**: Business logic and state management
- **Services**: Utilities for Markdown rendering and export functionality

The application uses no external dependencies, relying solely on Apple's native frameworks:
- SwiftUI for modern UI components
- AppKit for advanced text editing capabilities
- WebKit for HTML preview rendering

## Keyboard Shortcuts

### File Operations
- `⌘N` - New Document
- `⌘O` - Open Document
- `⌘⇧O` - Open Folder
- `⌘S` - Save Document

### Formatting
- `⌘B` - Bold
- `⌘I` - Italic
- `⌘K` - Code
- `⌘L` - Insert Link
- `⌘⇧I` - Insert Image

### View Options
- `⌘⇧P` - Toggle Preview
- `⌘⇧F` - Toggle Focus Mode
- `⌘⇧T` - Toggle Typewriter Mode

## Configuration

### iCloud Setup

To enable iCloud document sync:

1. Ensure you have an active Apple Developer account
2. Enable iCloud capability in Xcode
3. Configure the iCloud container: `iCloud.com.lopodragon.markdownpro`
4. The app will automatically use iCloud for document storage if enabled

### Customization

Access preferences via `MarkdownPro > Settings` to customize:
- Default theme
- Font size and line spacing
- Panel visibility defaults
- Editor behavior

## Development

### Project Structure

```
MarkdownPro/
├── Sources/
│   ├── Models/           # Data models
│   ├── ViewModels/       # Business logic
│   ├── Views/            # UI components
│   └── Services/         # Utilities
├── Resources/
│   └── Assets.xcassets/  # App icons and assets
└── Supporting/
    ├── Info.plist        # App configuration
    └── MarkdownPro.entitlements  # Capabilities
```

### Building

```bash
# Open in Xcode
open MarkdownPro.xcodeproj

# Or build from command line
xcodebuild -project MarkdownPro.xcodeproj -scheme MarkdownPro -configuration Release
```

## License

MIT License - see [LICENSE](LICENSE) file for details

## Support

For bug reports and feature requests, please create an issue on the project repository.

## Roadmap

Future enhancements planned:
- Custom CSS for preview
- Markdown extensions support (footnotes, task lists)
- Multi-file search
- Version history
- Custom keyboard shortcuts
- Export templates

## Credits

Developed by LoopDragon
Copyright © 2026 LoopDragon. All rights reserved.

## Bundle Information

- Bundle ID: `com.lopodragon.markdownpro`
- Version: 1.0.0
- Category: Productivity
- Price: $5.99 USD (one-time purchase)
