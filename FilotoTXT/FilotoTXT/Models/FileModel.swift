//
//  FileModel.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import Foundation

struct FileModel {
    let url: URL
    let name: String
    let size: String
    
    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.size = FileModel.formatFileSize(url)
    }
    
    private static func formatFileSize(_ fileURL: URL) -> String {
        let accessed = fileURL.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? Int64 {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useKB, .useMB, .useGB]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: fileSize)
            }
        } catch {
            // Don't log error to user, just return Unknown
        }
        return "Unknown"
    }
}

enum FileType: String, CaseIterable {
    case docx = "docx"
    case pdf = "pdf"
    case markdown = "md"
    
    var displayName: String {
        switch self {
        case .docx:
            return "Word Document"
        case .pdf:
            return "PDF Document"
        case .markdown:
            return "Markdown File"
        }
    }
    
    var icon: String {
        switch self {
        case .docx:
            return "doc.text"
        case .pdf:
            return "doc.richtext"
        case .markdown:
            return "doc.plaintext"
        }
    }
}

enum ConversionError: LocalizedError {
    case unsupportedFileType
    case fileReadError(String)
    case conversionError(String)
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFileType:
            return "File type not supported. Please select a .docx, .pdf, or .md file."
        case .fileReadError(let message):
            return "Error reading file: \(message)"
        case .conversionError(let message):
            return "Error converting file: \(message)"
        case .encodingError:
            return "Could not read file with any supported encoding"
        }
    }
} 