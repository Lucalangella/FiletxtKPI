//
//  ChartGenerationService.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import Foundation
import SwiftUI
import Charts

@MainActor
class ChartGenerationService: ObservableObject {
    
    func generateCharts(from extractedData: ExtractedData) -> [ChartConfiguration] {
        var charts: [ChartConfiguration] = []
        
        // Word Frequency Bar Chart
        if !extractedData.keywords.isEmpty {
            let wordFrequencyData = extractedData.keywords.prefix(10).map { keyword in
                DataPoint(label: keyword.word, value: Double(keyword.frequency), category: "Word Frequency")
            }
            let wordFrequencyChart = ChartConfiguration(
                type: .bar,
                title: "Top Keywords Frequency",
                dataPoints: wordFrequencyData,
                colorScheme: .blue
            )
            charts.append(wordFrequencyChart)
        }
        
        // Entity Distribution Pie Chart
        if !extractedData.entities.isEmpty {
            let entityTypes = Dictionary(grouping: extractedData.entities, by: { $0.type })
            let entityData = entityTypes.map { entityType, entities in
                DataPoint(
                    label: entityType.rawValue,
                    value: Double(entities.count),
                    category: "Entity Types"
                )
            }
            let entityChart = ChartConfiguration(
                type: .pie,
                title: "Entity Distribution",
                dataPoints: entityData,
                colorScheme: .mixed
            )
            charts.append(entityChart)
        }
        
        // Sentiment Analysis Chart
        let sentimentData = [
            DataPoint(label: "Sentiment Score", value: extractedData.sentiment.score, category: "Sentiment")
        ]
        let sentimentChart = ChartConfiguration(
            type: .bar,
            title: "Sentiment Analysis",
            dataPoints: sentimentData,
            colorScheme: extractedData.sentiment.score > 0 ? .green : .red
        )
        charts.append(sentimentChart)
        
        // Text Statistics Chart
        let statisticsData = [
            DataPoint(label: "Words", value: Double(extractedData.statistics.wordCount), category: "Statistics"),
            DataPoint(label: "Characters", value: Double(extractedData.statistics.characterCount), category: "Statistics"),
            DataPoint(label: "Sentences", value: Double(extractedData.statistics.sentenceCount), category: "Statistics"),
            DataPoint(label: "Paragraphs", value: Double(extractedData.statistics.paragraphCount), category: "Statistics")
        ]
        let statisticsChart = ChartConfiguration(
            type: .bar,
            title: "Text Statistics",
            dataPoints: statisticsData,
            colorScheme: .purple
        )
        charts.append(statisticsChart)
        
        // Sentence Length Line Chart
        if !extractedData.dataPoints.isEmpty {
            let sentenceLengthData = extractedData.dataPoints.filter { $0.category == "Sentence Length" }
            if !sentenceLengthData.isEmpty {
                let sentenceChart = ChartConfiguration(
                    type: .line,
                    title: "Sentence Length Distribution",
                    dataPoints: sentenceLengthData,
                    colorScheme: .orange
                )
                charts.append(sentenceChart)
            }
        }
        
        return charts
    }
    
    func generateInsights(from extractedData: ExtractedData) -> [String] {
        var insights: [String] = []
        
        // Text length insights
        if extractedData.statistics.wordCount > 1000 {
            insights.append("📝 Long document detected (\(extractedData.statistics.wordCount) words)")
        } else if extractedData.statistics.wordCount < 100 {
            insights.append("📝 Short document detected (\(extractedData.statistics.wordCount) words)")
        }
        
        // Reading time insights
        insights.append("⏱️ Estimated reading time: \(String(format: "%.1f", extractedData.statistics.readingTime)) minutes")
        
        // Sentiment insights
        if extractedData.sentiment.score > 0.5 {
            insights.append("😊 Document has a positive sentiment")
        } else if extractedData.sentiment.score < -0.5 {
            insights.append("😔 Document has a negative sentiment")
        } else {
            insights.append("😐 Document has a neutral sentiment")
        }
        
        // Entity insights
        if !extractedData.entities.isEmpty {
            let personCount = extractedData.entities.filter { $0.type == .person }.count
            let orgCount = extractedData.entities.filter { $0.type == .organization }.count
            let locationCount = extractedData.entities.filter { $0.type == .location }.count
            
            if personCount > 0 {
                insights.append("👥 \(personCount) person(s) mentioned")
            }
            if orgCount > 0 {
                insights.append("🏢 \(orgCount) organization(s) mentioned")
            }
            if locationCount > 0 {
                insights.append("📍 \(locationCount) location(s) mentioned")
            }
        }
        
        // Keyword insights
        if !extractedData.keywords.isEmpty {
            let topKeyword = extractedData.keywords.first
            insights.append("🔑 Most frequent keyword: '\(topKeyword?.word ?? "N/A")' (\(topKeyword?.frequency ?? 0) times)")
        }
        
        // Complexity insights
        if extractedData.statistics.averageWordLength > 6 {
            insights.append("📚 Document uses complex vocabulary (avg. word length: \(String(format: "%.1f", extractedData.statistics.averageWordLength)) characters)")
        }
        
        return insights
    }
} 