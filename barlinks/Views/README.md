# barlinks

A lightweight macOS menu bar app for managing links and text snippets.

## Features

- 📎 **Save Links** - Store URLs with optional titles
- 📝 **Save Text** - Save text snippets for quick access
- 📋 **Quick Copy** - Click on text snippets to copy them instantly
- 🌐 **Quick Open** - Click on links to open them in your browser
- ✏️ **Edit Entries** - Modify saved links and text snippets
- 🗂️ **Organize** - Group entries into custom lists
- 🔍 **Search** - Quickly find links and text across all lists
- 💾 **Import/Export** - Backup and restore your data as JSON

## Installation

1. Clone this repository
2. Open `barlinks.xcodeproj` in Xcode
3. Build and run the project (⌘R)

## Setup

### Getting Logo.dev API Token (Optional)

The app displays favicons for links using logo.dev. To enable this feature:

1. Visit [logo.dev](https://logo.dev) and create a free account
2. Get your API token from the dashboard
3. Open `LinkRowView.swift` in the project
4. Find the `logoURL` function (around line 107)
5. Replace `[INSERT_YOUR_TOKEN_HERE]` with your actual token:

```swift
private func logoURL(for urlString: String) -> URL? {
    guard let host = URL(string: urlString)?.host, !host.isEmpty else { return nil }
    return URL(string: "https://img.logo.dev/\(host)?token=YOUR_TOKEN_HERE")
}
```

> **Note:** The app works without a logo.dev token - you'll just see placeholder icons instead of website favicons.

## Usage

### Adding Items

1. Click the **+** button in the menu bar popover
2. Choose between **Link** or **Text**
3. Enter the URL or text content
4. Add an optional title
5. Select a list to save it to

### Managing Lists

- Click **+ New List** to create a new list
- Click on a list name to expand/collapse it
- All entries are organized under lists

### Editing & Deleting

- Hover over any entry to reveal action buttons
- **Copy** (📄) - Copy the content to clipboard
- **Edit** (✏️) - Modify the entry
- **Delete** (❌) - Remove the entry

### Import/Export

- **Export** - Save all your data as a JSON file
- **Import** - Restore data from a JSON backup

## Screenshots

<!-- Add your screenshots here -->

## Data Storage

barlinks stores all data locally in `~/.barlinks/data.json`. Your data never leaves your device.

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later (for building)

## License

This project is open source and available under the MIT License.
