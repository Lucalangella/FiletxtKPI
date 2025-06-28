# File to TXT Converter

A SwiftUI iOS app that converts any file to plain text format. This app can handle various file types and attempts to extract readable text content from them.

## Features

- **Universal File Support**: Convert any file type to text
- **Multiple Encoding Support**: Automatically tries different text encodings (UTF-8, ASCII, ISO Latin, Windows CP1252, macOS Roman)
- **Hex Fallback**: For binary files, converts to hexadecimal representation
- **File Size Display**: Shows the size of selected files
- **Export Functionality**: Share converted text as TXT files
- **Modern UI**: Clean, intuitive interface with SwiftUI

## How It Works

1. **File Selection**: Tap "Select File to Convert" to choose any file from your device
2. **Conversion**: The app reads the file data and attempts to convert it to text using various encodings
3. **Display**: The converted text is displayed in a scrollable, monospaced font
4. **Export**: Tap "Export" to share the converted text as a TXT file

## Supported File Types

The app can handle any file type, including:
- Text files (TXT, RTF, HTML, XML, JSON, etc.)
- Document files (PDF, DOC, DOCX, etc.)
- Code files (Swift, Python, JavaScript, etc.)
- Configuration files (INI, YAML, etc.)
- Binary files (converted to hex representation)

## Technical Details

### Conversion Process
1. Reads file data as binary
2. Attempts UTF-8 encoding first
3. Falls back to other common encodings if UTF-8 fails
4. For completely binary files, converts to hexadecimal representation

### Permissions
The app requires:
- File access permissions to read selected files
- Document sharing capabilities to export TXT files

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 5.0+

## Installation

1. Open the project in Xcode
2. Select your development team in the project settings
3. Build and run on a device or simulator

## Usage

1. Launch the app
2. Tap "Select File to Convert"
3. Choose any file from your device
4. Tap "Convert to TXT"
5. View the converted text
6. Tap "Export" to share as a TXT file

## Architecture

The app is built using:
- **SwiftUI** for the user interface
- **UniformTypeIdentifiers** for file type handling
- **FileManager** for file operations
- **UIActivityViewController** for sharing functionality

## File Structure

```
FilotoTXT/
├── FilotoTXTApp.swift          # Main app entry point
├── ContentView.swift           # Main UI and conversion logic
├── Info.plist                  # App permissions and configurations
└── Assets.xcassets/           # App icons and colors
```

## License

This project is created for educational purposes. 