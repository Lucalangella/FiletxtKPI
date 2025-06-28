//
//  FileConverterViewModelTests.swift
//  FilotoTXTTests
//
//  Created by Luca Langella 1 on 28/06/25.
//

import XCTest
@testable import FilotoTXT

// Mock service for testing
class MockFileConversionService: FileConversionServiceProtocol {
    var shouldSucceed = true
    var mockText = "Mock converted text"
    var mockError: Error?
    
    func convertFile(_ fileURL: URL) async throws -> String {
        if shouldSucceed {
            return mockText
        } else {
            throw mockError ?? ConversionError.conversionError("Mock error")
        }
    }
}

class FileConverterViewModelTests: XCTestCase {
    
    var viewModel: FileConverterViewModel!
    var mockService: MockFileConversionService!
    
    override func setUp() {
        super.setUp()
        mockService = MockFileConversionService()
        viewModel = FileConverterViewModel(conversionService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.selectedFile)
        XCTAssertTrue(viewModel.convertedText.isEmpty)
        XCTAssertFalse(viewModel.isConverting)
        XCTAssertFalse(viewModel.showFilePicker)
        XCTAssertFalse(viewModel.showExportSheet)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertMessage.isEmpty)
        XCTAssertTrue(viewModel.fileName.isEmpty)
    }
    
    func testCanConvert_WhenNoFileSelected_ReturnsFalse() {
        XCTAssertFalse(viewModel.canConvert)
    }
    
    func testCanConvert_WhenFileSelectedAndNotConverting_ReturnsTrue() {
        // Given
        let testURL = URL(fileURLWithPath: "/test/file.docx")
        viewModel.selectedFile = FileModel(url: testURL)
        
        // Then
        XCTAssertTrue(viewModel.canConvert)
    }
    
    func testCanConvert_WhenConverting_ReturnsFalse() {
        // Given
        let testURL = URL(fileURLWithPath: "/test/file.docx")
        viewModel.selectedFile = FileModel(url: testURL)
        viewModel.isConverting = true
        
        // Then
        XCTAssertFalse(viewModel.canConvert)
    }
    
    func testHasConvertedText_WhenTextEmpty_ReturnsFalse() {
        XCTAssertFalse(viewModel.hasConvertedText)
    }
    
    func testHasConvertedText_WhenTextNotEmpty_ReturnsTrue() {
        // Given
        viewModel.convertedText = "Some converted text"
        
        // Then
        XCTAssertTrue(viewModel.hasConvertedText)
    }
    
    func testConvertButtonTitle_WhenNotConverting_ReturnsConvertText() {
        XCTAssertEqual(viewModel.convertButtonTitle, "Convert to TXT")
    }
    
    func testConvertButtonTitle_WhenConverting_ReturnsConvertingText() {
        // Given
        viewModel.isConverting = true
        
        // Then
        XCTAssertEqual(viewModel.convertButtonTitle, "Converting...")
    }
    
    func testConvertButtonIcon_WhenNotConverting_ReturnsArrowIcon() {
        XCTAssertEqual(viewModel.convertButtonIcon, "arrow.right.circle")
    }
    
    func testConvertButtonIcon_WhenConverting_ReturnsEmptyString() {
        // Given
        viewModel.isConverting = true
        
        // Then
        XCTAssertEqual(viewModel.convertButtonIcon, "")
    }
    
    func testHandleFileSelection_WithSupportedFile_SetsSelectedFile() {
        // Given
        let testURL = URL(fileURLWithPath: "/test/file.docx")
        
        // When
        viewModel.handleFileSelection([testURL])
        
        // Then
        XCTAssertNotNil(viewModel.selectedFile)
        XCTAssertEqual(viewModel.selectedFile?.name, "file.docx")
        XCTAssertEqual(viewModel.fileName, "file")
        XCTAssertTrue(viewModel.convertedText.isEmpty)
    }
    
    func testHandleFileSelection_WithUnsupportedFile_ShowsAlert() {
        // Given
        let testURL = URL(fileURLWithPath: "/test/file.xyz")
        
        // When
        viewModel.handleFileSelection([testURL])
        
        // Then
        XCTAssertNil(viewModel.selectedFile)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertMessage, ConversionError.unsupportedFileType.localizedDescription)
    }
    
    func testHandleFileSelectionError_SetsAlertMessage() {
        // Given
        let testError = NSError(domain: "TestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // When
        viewModel.handleFileSelectionError(testError)
        
        // Then
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertMessage.contains("Test error"))
    }
    
    func testDismissAlert_ClearsAlertState() {
        // Given
        viewModel.showAlert = true
        viewModel.alertMessage = "Test message"
        
        // When
        viewModel.dismissAlert()
        
        // Then
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertTrue(viewModel.alertMessage.isEmpty)
    }
    
    func testExportFile_ShowsExportSheet() {
        // When
        viewModel.exportFile()
        
        // Then
        XCTAssertTrue(viewModel.showExportSheet)
    }
    
    func testDismissExportSheet_HidesExportSheet() {
        // Given
        viewModel.showExportSheet = true
        
        // When
        viewModel.dismissExportSheet()
        
        // Then
        XCTAssertFalse(viewModel.showExportSheet)
    }
} 