# FilotoTXT - MVVM Architecture

This document describes the MVVM (Model-View-ViewModel) architecture implementation for the FilotoTXT app.

## Architecture Overview

The app has been refactored to follow the MVVM pattern, which provides better separation of concerns, testability, and maintainability.

### Directory Structure

```
FilotoTXT/
├── Models/
│   └── FileModel.swift              # Data models and enums
├── ViewModels/
│   └── FileConverterViewModel.swift # Business logic and state management
├── Views/
│   ├── FileSelectionView.swift      # File selection UI component
│   ├── ConvertedTextView.swift      # Converted text display component
│   └── ExportView.swift             # Export functionality UI
├── Services/
│   └── FileConversionService.swift  # File conversion business logic
├── ContentView.swift                # Main view (orchestrates other views)
└── README_MVVM.md                   # Architecture documentation

FilotoTXTTests/                      # Test target (separate from main app)
└── FileConverterViewModelTests.swift # Unit tests for ViewModel
```

## Components

### Models (`Models/`)

**FileModel.swift**
- `FileModel`: Represents a file with URL, name, and size
- `FileType`: Enum for supported file types (docx, pdf, md)
- `ConversionError`: Custom error types for conversion failures

### ViewModels (`ViewModels/`)

**FileConverterViewModel.swift**
- Manages the application state using `@Published` properties
- Handles user interactions and business logic
- Coordinates between the UI and services
- Uses `@MainActor` for UI updates

Key responsibilities:
- File selection handling
- Conversion state management
- Error handling and user feedback
- Navigation state (sheets, alerts)

### Views (`Views/`)

**FileSelectionView.swift**
- Reusable component for file selection UI
- Displays selected file information or selection button
- Pure UI component with no business logic

**ConvertedTextView.swift**
- Displays converted text with export functionality
- Scrollable text area with monospaced font
- Export button integration

**ExportView.swift**
- Handles file export and sharing
- Creates temporary TXT files
- Integrates with system share sheet

### Services (`Services/`)

**FileConversionService.swift**
- Contains all file conversion logic
- Implements `FileConversionServiceProtocol` for testability
- Handles different file types (DOCX, PDF, Markdown)
- Uses dependency injection pattern

## Key MVVM Benefits

### 1. Separation of Concerns
- **Models**: Pure data structures
- **Views**: UI components only
- **ViewModels**: Business logic and state management
- **Services**: Reusable business logic

### 2. Testability
- ViewModels can be unit tested independently
- Services can be mocked for testing
- UI components can be tested in isolation
- Test target properly configured with XCTest

### 3. Maintainability
- Clear responsibility boundaries
- Easy to modify individual components
- Reduced coupling between layers

### 4. Reusability
- ViewModels can be reused across different views
- Services can be shared between different ViewModels
- UI components can be reused in different contexts

## Usage Example

```swift
// In ContentView
@StateObject private var viewModel = FileConverterViewModel()

// ViewModel handles all business logic
Button("Convert") {
    viewModel.convertFile()
}

// UI automatically updates based on ViewModel state
if viewModel.isConverting {
    ProgressView()
}
```

## Testing Strategy

The MVVM architecture enables comprehensive testing:

1. **Unit Tests**: Test ViewModels and Services (`FilotoTXTTests/`)
2. **UI Tests**: Test View components
3. **Integration Tests**: Test ViewModel-Service interactions

### Setting Up Tests

1. Add a **Unit Testing Bundle** target named `FilotoTXTTests`
2. Add `FileConverterViewModelTests.swift` to the test target
3. Run tests with ⌘+U

### Test Coverage

The test suite includes:
- ✅ Initial state validation
- ✅ File selection logic
- ✅ Conversion state management
- ✅ Error handling
- ✅ UI state updates
- ✅ Button state logic

## Future Enhancements

- Add unit tests for all ViewModels and Services
- Implement dependency injection container
- Add more file type support
- Create preview providers for SwiftUI previews
- Add UI tests for view components 