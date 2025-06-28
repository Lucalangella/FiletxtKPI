//
//  DataAnalysisView.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import SwiftUI

struct DataAnalysisView: View {
    let analysisResult: AnalysisResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("ML Analysis Results")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Processed in \(String(format: "%.2f", analysisResult.processingTime))s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Insights Section
                    if !analysisResult.insights.isEmpty {
                        InsightsSection(insights: analysisResult.insights)
                    }
                    
                    // Statistics Section
                    StatisticsSection(statistics: analysisResult.extractedData.statistics)
                    
                    // Sentiment Section
                    SentimentSection(sentiment: analysisResult.extractedData.sentiment)
                    
                    // Entities Section
                    if !analysisResult.extractedData.entities.isEmpty {
                        EntitiesSection(entities: analysisResult.extractedData.entities)
                    }
                    
                    // Keywords Section
                    if !analysisResult.extractedData.keywords.isEmpty {
                        KeywordsSection(keywords: analysisResult.extractedData.keywords)
                    }
                    
                    // Charts Section
                    if !analysisResult.charts.isEmpty {
                        ChartsSection(charts: analysisResult.charts)
                    }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        // TODO: Implement share functionality
                    }
                    .disabled(true)
                }
            }
        }
    }
}

// MARK: - Insights Section
struct InsightsSection: View {
    let insights: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.yellow)
                Text("Key Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(insights, id: \.self) { insight in
                    HStack(alignment: .top) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text(insight)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Statistics Section
struct StatisticsSection: View {
    let statistics: TextStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.purple)
                Text("Text Statistics")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(title: "Words", value: "\(statistics.wordCount)", icon: "textformat")
                StatCard(title: "Characters", value: "\(statistics.characterCount)", icon: "character")
                StatCard(title: "Sentences", value: "\(statistics.sentenceCount)", icon: "text.quote")
                StatCard(title: "Paragraphs", value: "\(statistics.paragraphCount)", icon: "text.alignleft")
                StatCard(title: "Avg Word Length", value: String(format: "%.1f", statistics.averageWordLength), icon: "ruler")
                StatCard(title: "Reading Time", value: String(format: "%.1f min", statistics.readingTime), icon: "clock")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Sentiment Section
struct SentimentSection: View {
    let sentiment: SentimentAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "face.smiling")
                    .foregroundColor(sentiment.color)
                Text("Sentiment Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sentiment.label)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(sentiment.color)
                    
                    Text("Confidence: \(String(format: "%.1f%%", sentiment.confidence * 100))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Sentiment gauge
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: abs(sentiment.score))
                        .stroke(sentiment.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Text(String(format: "%.2f", sentiment.score))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Entities Section
struct EntitiesSection: View {
    let entities: [Entity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.3")
                    .foregroundColor(.green)
                Text("Extracted Entities")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(entities.prefix(10)) { entity in
                    EntityCard(entity: entity)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Entity Card
struct EntityCard: View {
    let entity: Entity
    
    var body: some View {
        HStack {
            Circle()
                .fill(entity.type.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entity.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(entity.type.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(entity.occurrences)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

// MARK: - Keywords Section
struct KeywordsSection: View {
    let keywords: [Keyword]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "key")
                    .foregroundColor(.orange)
                Text("Top Keywords")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(keywords.prefix(15)) { keyword in
                    Text(keyword.word)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Charts Section
struct ChartsSection: View {
    let charts: [ChartConfiguration]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .foregroundColor(.indigo)
                Text("Data Visualizations")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            ForEach(Array(charts.enumerated()), id: \.offset) { index, chart in
                ChartContainerView(chartConfig: chart)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 