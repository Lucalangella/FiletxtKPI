//
//  MLDataExtractionServiceTests.swift
//  FilotoTXTTests
//
//  Created by Luca Langella 1 on 28/06/25.
//

import XCTest
@testable import FilotoTXT

final class MLDataExtractionServiceTests: XCTestCase {
    var mlService: MLDataExtractionService!
    
    override func setUpWithError() throws {
        mlService = MLDataExtractionService()
    }
    
    override func tearDownWithError() throws {
        mlService = nil
    }
    
    func testExtractDataFromSimpleText() async throws {
        // Given
        let text = "Hello world. This is a test document."
        
        // When
        let extractedData = await mlService.extractData(from: text)
        
        // Then
        XCTAssertEqual(extractedData.text, text)
        XCTAssertEqual(extractedData.statistics.wordCount, 8)
        XCTAssertEqual(extractedData.statistics.sentenceCount, 2)
        XCTAssertEqual(extractedData.statistics.characterCount, text.count)
    }
    
    func testExtractDataFromComplexText() async throws {
        // Given
        let text = """
        John Smith works at Apple Inc. in San Francisco, California. 
        He can be reached at john.smith@apple.com. 
        The company's revenue was $394.3 billion in 2023.
        Visit https://www.apple.com for more information.
        """
        
        // When
        let extractedData = await mlService.extractData(from: text)
        
        // Then
        XCTAssertEqual(extractedData.text, text)
        XCTAssertGreaterThan(extractedData.statistics.wordCount, 20)
        XCTAssertGreaterThan(extractedData.statistics.sentenceCount, 3)
        
        // Check for entities
        XCTAssertFalse(extractedData.entities.isEmpty)
        
        // Check for email
        let emails = extractedData.entities.filter { $0.type == .email }
        XCTAssertFalse(emails.isEmpty)
        
        // Check for URLs
        let urls = extractedData.entities.filter { $0.type == .url }
        XCTAssertFalse(urls.isEmpty)
        
        // Check for numbers
        let numbers = extractedData.entities.filter { $0.type == .number }
        XCTAssertFalse(numbers.isEmpty)
    }
    
    func testSentimentAnalysis() async throws {
        // Given
        let positiveText = "I love this amazing product! It's fantastic and wonderful."
        let negativeText = "I hate this terrible product. It's awful and disappointing."
        let neutralText = "This is a product. It has features."
        
        // When
        let positiveSentiment = await mlService.extractData(from: positiveText).sentiment
        let negativeSentiment = await mlService.extractData(from: negativeText).sentiment
        let neutralSentiment = await mlService.extractData(from: neutralText).sentiment
        
        // Then
        XCTAssertGreaterThan(positiveSentiment.score, 0)
        XCTAssertLessThan(negativeSentiment.score, 0)
        XCTAssertEqual(neutralSentiment.label, "Neutral")
    }
    
    func testKeywordExtraction() async throws {
        // Given
        let text = "Machine learning is a subset of artificial intelligence. Machine learning algorithms learn from data."
        
        // When
        let extractedData = await mlService.extractData(from: text)
        
        // Then
        XCTAssertFalse(extractedData.keywords.isEmpty)
        
        // Check that "machine" and "learning" are among the top keywords
        let keywordWords = extractedData.keywords.map { $0.word }
        XCTAssertTrue(keywordWords.contains("machine") || keywordWords.contains("learning"))
    }
    
    func testEntityExtraction() async throws {
        // Given
        let text = "Apple Inc. is located in Cupertino, California. Tim Cook is the CEO."
        
        // When
        let extractedData = await mlService.extractData(from: text)
        
        // Then
        XCTAssertFalse(extractedData.entities.isEmpty)
        
        // Should extract organization names
        let organizations = extractedData.entities.filter { $0.type == .organization }
        XCTAssertFalse(organizations.isEmpty)
        
        // Should extract location names
        let locations = extractedData.entities.filter { $0.type == .location }
        XCTAssertFalse(locations.isEmpty)
    }
    
    func testEmptyText() async throws {
        // Given
        let text = ""
        
        // When
        let extractedData = await mlService.extractData(from: text)
        
        // Then
        XCTAssertEqual(extractedData.text, text)
        XCTAssertEqual(extractedData.statistics.wordCount, 0)
        XCTAssertEqual(extractedData.statistics.sentenceCount, 0)
        XCTAssertEqual(extractedData.statistics.characterCount, 0)
    }
    
    func testPerformance() async throws {
        // Given
        let longText = String(repeating: "This is a test sentence with multiple words. ", count: 100)
        
        // When & Then
        measure {
            Task {
                _ = await mlService.extractData(from: longText)
            }
        }
    }
} 