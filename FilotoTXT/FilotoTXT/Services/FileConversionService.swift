//
//  FileConversionService.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import Foundation
import ZIPFoundation
import PDFKit

protocol FileConversionServiceProtocol {
    func convertFile(_ fileURL: URL) async throws -> String
}

class FileConversionService: FileConversionServiceProtocol {
    
    func convertFile(_ fileURL: URL) async throws -> String {
        print("convertFile called for: \(fileURL.lastPathComponent)")
        
        // Start accessing the security-scoped resource
        let accessed = fileURL.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            print("File data loaded, size: \(data.count) bytes")
            
            // Check if it's a Word document (.docx)
            if fileURL.pathExtension.lowercased() == "docx" {
                print("Detected .docx file, attempting Word document extraction")
                return try extractTextFromWordDocument(data)
            }
            
            // Check if it's a PDF file
            if fileURL.pathExtension.lowercased() == "pdf" {
                print("Detected .pdf file, attempting PDF text extraction")
                return try extractTextFromPDF(data)
            }
            
            // Check if it's a Markdown file
            if fileURL.pathExtension.lowercased() == "md" {
                print("Detected .md file, attempting Markdown text extraction")
                return try extractTextFromMarkdown(data)
            }
            
            print("Not a supported file type, trying text conversion")
            // Try to convert as text first
            if let text = String(data: data, encoding: .utf8) {
                print("Successfully converted as UTF-8 text")
                return text
            }
            
            // Try other encodings
            let encodings: [String.Encoding] = [.ascii, .isoLatin1, .isoLatin2, .windowsCP1252, .macOSRoman]
            
            for encoding in encodings {
                if let text = String(data: data, encoding: encoding) {
                    print("Successfully converted using encoding: \(encoding)")
                    return text
                }
            }
            
            print("All text encodings failed, converting to hex")
            // If all text encodings fail, convert to hex representation
            return data.map { String(format: "%02x", $0) }.joined(separator: " ")
            
        } catch {
            print("Error in convertFile: \(error)")
            throw ConversionError.fileReadError(error.localizedDescription)
        }
    }
    
    private func extractTextFromWordDocument(_ data: Data) throws -> String {
        print("extractTextFromWordDocument called")
        
        do {
            // Write the .docx data to a temporary file
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            let tempFile = tempDir.appendingPathComponent("document.docx")
            try data.write(to: tempFile)
            print("Temporary file created at: \(tempFile.path)")
            
            defer { 
                do {
                    try FileManager.default.removeItem(at: tempDir)
                    print("Temporary directory cleaned up")
                } catch {
                    print("Error cleaning up temp directory: \(error)")
                }
            }
            
            // Open the archive
            guard let archive = Archive(url: tempFile, accessMode: .read) else {
                print("Failed to open archive")
                throw ConversionError.conversionError("Could not open Word document archive")
            }
            print("Archive opened successfully")
            
            // Extract word/document.xml to memory
            guard let entry = archive["word/document.xml"] else {
                print("Could not find word/document.xml in archive")
                throw ConversionError.conversionError("Could not find document.xml in Word document")
            }
            print("Found word/document.xml entry")
            
            var xmlData = Data()
            _ = try archive.extract(entry, consumer: { xmlData.append($0) })
            print("Extracted XML data, size: \(xmlData.count) bytes")
            
            guard let xmlString = String(data: xmlData, encoding: .utf8) else {
                print("Failed to convert XML data to UTF-8 string")
                throw ConversionError.conversionError("Could not read document.xml as UTF-8")
            }
            print("XML string created, length: \(xmlString.count)")
            
            let result = parseWordDocumentXML(xmlString)
            print("XML parsing completed, result length: \(result.count)")
            return result
            
        } catch {
            print("Error in extractTextFromWordDocument: \(error)")
            if error is ConversionError {
                throw error
            }
            throw ConversionError.conversionError(error.localizedDescription)
        }
    }
    
    private func extractTextFromPDF(_ data: Data) throws -> String {
        print("extractTextFromPDF called")
        
        do {
            // Create a temporary file for the PDF
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            let tempFile = tempDir.appendingPathComponent("document.pdf")
            try data.write(to: tempFile)
            print("Temporary PDF file created at: \(tempFile.path)")
            
            defer { 
                do {
                    try FileManager.default.removeItem(at: tempDir)
                    print("Temporary PDF directory cleaned up")
                } catch {
                    print("Error cleaning up temp PDF directory: \(error)")
                }
            }
            
            // Create PDF document
            guard let pdfDocument = PDFDocument(url: tempFile) else {
                print("Failed to create PDF document")
                throw ConversionError.conversionError("Could not open PDF document")
            }
            print("PDF document created successfully")
            
            var extractedText = ""
            let pageCount = pdfDocument.pageCount
            print("PDF has \(pageCount) pages")
            
            // Extract text from each page
            for pageIndex in 0..<pageCount {
                if let page = pdfDocument.page(at: pageIndex) {
                    if let pageText = page.string {
                        extractedText += pageText + "\n\n"
                        print("Extracted text from page \(pageIndex + 1), length: \(pageText.count)")
                    } else {
                        print("No text found on page \(pageIndex + 1)")
                    }
                }
            }
            
            let result = extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
            print("PDF text extraction completed, result length: \(result.count)")
            
            if result.isEmpty {
                return "No text content found in PDF. The PDF might contain only images or scanned content."
            }
            
            return result
            
        } catch {
            print("Error in extractTextFromPDF: \(error)")
            if error is ConversionError {
                throw error
            }
            throw ConversionError.conversionError(error.localizedDescription)
        }
    }
    
    private func extractTextFromMarkdown(_ data: Data) throws -> String {
        print("extractTextFromMarkdown called")
        
        // For Markdown files, we can directly convert to string since they're plain text
        guard let text = String(data: data, encoding: .utf8) else {
            // Try other encodings if UTF-8 fails
            let encodings: [String.Encoding] = [.ascii, .isoLatin1, .isoLatin2, .windowsCP1252, .macOSRoman]
            
            for encoding in encodings {
                if let text = String(data: data, encoding: encoding) {
                    print("Successfully converted Markdown using encoding: \(encoding)")
                    return text
                }
            }
            
            throw ConversionError.encodingError
        }
        
        print("Markdown text extracted successfully, length: \(text.count)")
        return text
    }
    
    private func parseWordDocumentXML(_ xmlString: String) -> String {
        print("parseWordDocumentXML called with XML length: \(xmlString.count)")
        
        // Remove XML namespaces to simplify parsing
        var cleanXML = xmlString
        let namespacePatterns = [
            "xmlns:w=\"[^\"]*\"",
            "xmlns:r=\"[^\"]*\"",
            "xmlns:wp=\"[^\"]*\"",
            "xmlns:a=\"[^\"]*\"",
            "xmlns:pic=\"[^\"]*\"",
            "xmlns:wp14=\"[^\"]*\"",
            "xmlns:w14=\"[^\"]*\"",
            "xmlns:w15=\"[^\"]*\"",
            "xmlns:w16=\"[^\"]*\"",
            "xmlns:w16cex=\"[^\"]*\"",
            "xmlns:w16cid=\"[^\"]*\"",
            "xmlns:w16se=\"[^\"]*\"",
            "xmlns:w16sdtdh=\"[^\"]*\"",
            "xmlns:w16dt=\"[^\"]*\""
        ]
        
        for pattern in namespacePatterns {
            cleanXML = cleanXML.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        
        // Extract text from <w:t> tags (Word text elements)
        var extractedText = ""
        let textPattern = "<w:t[^>]*>([^<]*)</w:t>"
        
        if let regex = try? NSRegularExpression(pattern: textPattern, options: []) {
            let range = NSRange(cleanXML.startIndex..<cleanXML.endIndex, in: cleanXML)
            let matches = regex.matches(in: cleanXML, options: [], range: range)
            
            print("Found \(matches.count) text elements")
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: cleanXML) {
                    let text = String(cleanXML[range])
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        extractedText += text + " "
                    }
                }
            }
        }
        
        // If no text found with <w:t> tags, try alternative patterns
        if extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("No <w:t> tags found, trying alternative patterns")
            
            // Try to find any text content between tags, but exclude image-related content
            let alternativePatterns = [
                ">([^<]{3,})<",  // Text between tags (minimum 3 characters)
                "\"([^\"]{5,})\"",  // Long quoted strings
                "'([^']{5,})'",  // Long single-quoted strings
            ]
            
            for pattern in alternativePatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(cleanXML.startIndex..<cleanXML.endIndex, in: cleanXML)
                    let matches = regex.matches(in: cleanXML, options: [], range: range)
                    
                    for match in matches {
                        if let range = Range(match.range(at: 1), in: cleanXML) {
                            let text = String(cleanXML[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Filter out image-related content and XML artifacts
                            if text.count > 5 && 
                               !text.contains("xmlns") && 
                               !text.contains("<?xml") &&
                               !text.contains("image") &&
                               !text.contains("drawing") &&
                               !text.contains("picture") &&
                               !text.contains("graphic") &&
                               !text.contains("shape") &&
                               !text.contains("chart") &&
                               !text.contains("object") &&
                               !text.contains("embed") &&
                               !text.contains("oleObject") &&
                               !text.contains("binData") &&
                               !text.contains("base64") &&
                               !text.contains("rId") &&
                               !text.contains("http://") &&
                               !text.contains("https://") &&
                               !text.contains(".jpg") &&
                               !text.contains(".jpeg") &&
                               !text.contains(".png") &&
                               !text.contains(".gif") &&
                               !text.contains(".bmp") &&
                               !text.contains(".tiff") &&
                               !text.contains(".svg") {
                                extractedText += text + " "
                            }
                        }
                    }
                }
            }
        }
        
        // Clean up the extracted text
        var result = extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove XML entities
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&apos;", with: "'")
        
        // Remove excessive whitespace
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        print("XML parsing completed, result length: \(result.count)")
        if result.count > 0 {
            let preview = String(result.prefix(200))
            print("First 200 characters: \(preview)")
        }
        
        return result
    }
} 