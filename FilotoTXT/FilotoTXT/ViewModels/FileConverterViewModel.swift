//
//  FileConverterViewModel.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class FileConverterViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedFile: FileModel?
    @Published var convertedText: String = ""
    @Published var isConverting: Bool = false
    @Published var showFilePicker: Bool = false
    @Published var showExportSheet: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var fileName: String = ""
    
    // MARK: - Dependencies
    private let conversionService: FileConversionServiceProtocol
    
    // MARK: - Initialization
    init(conversionService: FileConversionServiceProtocol = FileConversionService()) {
        self.conversionService = conversionService
    }
    
    // MARK: - Public Methods
    func selectFile() {
        showFilePicker = true
    }
    
    func handleFileSelection(_ files: [URL]) {
        guard let fileURL = files.first else { return }
        
        print("File selected: \(fileURL.lastPathComponent)")
        
        // Check if file type is supported
        let supportedExtensions = FileType.allCases.map { $0.rawValue }
        let fileExtension = fileURL.pathExtension.lowercased()
        
        if supportedExtensions.contains(fileExtension) {
            selectedFile = FileModel(url: fileURL)
            convertedText = ""
            fileName = fileURL.deletingPathExtension().lastPathComponent
        } else {
            alertMessage = ConversionError.unsupportedFileType.localizedDescription
            showAlert = true
        }
    }
    
    func handleFileSelectionError(_ error: Error) {
        print("File picker error: \(error)")
        print("Error domain: \(error as NSError).domain")
        print("Error code: \((error as NSError).code)")
        print("Error user info: \((error as NSError).userInfo)")
        alertMessage = "Error selecting file: \(error.localizedDescription)"
        showAlert = true
    }
    
    func convertFile() {
        guard let fileModel = selectedFile else { return }
        
        isConverting = true
        
        Task {
            do {
                print("Starting file conversion for: \(fileModel.name)")
                let text = try await conversionService.convertFile(fileModel.url)
                print("File conversion completed successfully")
                
                convertedText = text
            } catch {
                print("Error converting file: \(error)")
                print("Error details: \(error.localizedDescription)")
                
                if let conversionError = error as? ConversionError {
                    alertMessage = conversionError.localizedDescription
                } else {
                    alertMessage = "Error converting file: \(error.localizedDescription)"
                }
                showAlert = true
            }
            
            isConverting = false
        }
    }
    
    func exportFile() {
        showExportSheet = true
    }
    
    func dismissAlert() {
        showAlert = false
        alertMessage = ""
    }
    
    func dismissExportSheet() {
        showExportSheet = false
    }
    
    // MARK: - Computed Properties
    var canConvert: Bool {
        selectedFile != nil && !isConverting
    }
    
    var hasConvertedText: Bool {
        !convertedText.isEmpty
    }
    
    var convertButtonTitle: String {
        isConverting ? "Converting..." : "Convert to TXT"
    }
    
    var convertButtonIcon: String {
        isConverting ? "" : "arrow.right.circle"
    }
} 