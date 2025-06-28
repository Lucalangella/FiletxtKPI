//
//  DataAnalysisViewModel.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import Foundation
import SwiftUI

@MainActor
class DataAnalysisViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisResult: AnalysisResult?
    @Published var showAnalysisView = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var analysisProgress: Double = 0.0
    
    private let mlService = MLDataExtractionService()
    private let chartService = ChartGenerationService()
    
    // MARK: - Business Analysis Properties
    @Published var businessAnalysis: BusinessDocumentAnalysis?
    @Published var businessInsights: [BusinessAnalysisResult.BusinessInsight] = []
    @Published var recommendations: [BusinessAnalysisResult.Recommendation] = []
    @Published var executiveSummary: BusinessAnalysisResult.ExecutiveSummary?
    
    func analyzeText(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await showError("No text to analyze")
            return
        }
        
        isAnalyzing = true
        errorMessage = nil
        
        let startTime = Date()
        
        // Extract data using ML
        let extractedData = await mlService.extractData(from: text)
        
        // Generate charts
        let charts = chartService.generateCharts(from: extractedData)
        
        // Generate insights
        let insights = chartService.generateInsights(from: extractedData)
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        // Create analysis result
        let result = AnalysisResult(
            extractedData: extractedData,
            charts: charts,
            insights: insights,
            processingTime: processingTime
        )
        
        analysisResult = result
        showAnalysisView = true
        
        isAnalyzing = false
    }
    
    private func showError(_ message: String) async {
        errorMessage = message
        showError = true
    }
    
    func dismissError() {
        showError = false
        errorMessage = nil
    }
    
    func resetAnalysis() {
        analysisResult = nil
        showAnalysisView = false
        errorMessage = nil
        showError = false
    }
    
    // MARK: - Computed Properties
    var hasAnalysisResult: Bool {
        analysisResult != nil
    }
    
    var analysisStatusText: String {
        if isAnalyzing {
            return "Analyzing text with ML..."
        } else if hasAnalysisResult {
            return "Analysis complete"
        } else {
            return "Ready to analyze"
        }
    }
    
    var analysisButtonTitle: String {
        if isAnalyzing {
            return "Analyzing..."
        } else {
            return "Analyze with ML"
        }
    }
    
    var analysisButtonIcon: String {
        if isAnalyzing {
            return "brain.head.profile"
        } else {
            return "brain"
        }
    }
    
    // MARK: - Business Analysis Methods
    
    func analyzeBusinessDocument(from text: String) async {
        await MainActor.run {
            isAnalyzing = true
            analysisProgress = 0.0
        }
        
        // Perform business document analysis
        let businessAnalysis = await mlService.analyzeBusinessDocument(from: text)
        
        await MainActor.run {
            self.businessAnalysis = businessAnalysis
            analysisProgress = 0.5
        }
        
        // Generate business insights
        let insights = await generateBusinessInsights(from: businessAnalysis, text: text)
        
        await MainActor.run {
            self.businessInsights = insights
            analysisProgress = 0.7
        }
        
        // Generate recommendations
        let recommendations = await generateRecommendations(from: businessAnalysis, insights: insights)
        
        await MainActor.run {
            self.recommendations = recommendations
            analysisProgress = 0.9
        }
        
        // Create executive summary
        let executiveSummary = await createExecutiveSummary(
            businessAnalysis: businessAnalysis,
            insights: insights,
            recommendations: recommendations
        )
        
        await MainActor.run {
            self.executiveSummary = executiveSummary
            analysisProgress = 1.0
            isAnalyzing = false
        }
    }
    
    private func generateBusinessInsights(from analysis: BusinessDocumentAnalysis, text: String) async -> [BusinessAnalysisResult.BusinessInsight] {
        var insights: [BusinessAnalysisResult.BusinessInsight] = []
        
        // Document type insights
        insights.append(BusinessAnalysisResult.BusinessInsight(
            category: .strategic,
            title: "Document Classification",
            description: "This document has been classified as a \(analysis.documentType.rawValue) based on content analysis.",
            impact: .neutral,
            confidence: 0.85
        ))
        
        // Financial insights
        if let financialData = analysis.financialData {
            if let revenue = financialData.totalRevenue, revenue > 0 {
                insights.append(BusinessAnalysisResult.BusinessInsight(
                    category: .financial,
                    title: "Revenue Analysis",
                    description: "Total revenue identified: \(formatCurrency(revenue, currency: financialData.currencies.first ?? "USD")).",
                    impact: .positive,
                    confidence: 0.9
                ))
            }
            
            if let profitMargin = financialData.profitMargin {
                let impact: BusinessAnalysisResult.BusinessInsight.InsightImpact = profitMargin > 15 ? .positive : profitMargin > 5 ? .neutral : .negative
                insights.append(BusinessAnalysisResult.BusinessInsight(
                    category: .financial,
                    title: "Profitability",
                    description: "Profit margin: \(String(format: "%.1f", profitMargin))%",
                    impact: impact,
                    confidence: 0.8
                ))
            }
        }
        
        // Risk insights
        if !analysis.riskIndicators.isEmpty {
            let highRiskCount = analysis.riskIndicators.filter { $0.severity == .high || $0.severity == .critical }.count
            insights.append(BusinessAnalysisResult.BusinessInsight(
                category: .risk,
                title: "Risk Assessment",
                description: "Identified \(analysis.riskIndicators.count) risk indicators, including \(highRiskCount) high-priority risks.",
                impact: highRiskCount > 0 ? .negative : .neutral,
                confidence: 0.75
            ))
        }
        
        // Compliance insights
        if !analysis.complianceChecks.isEmpty {
            insights.append(BusinessAnalysisResult.BusinessInsight(
                category: .compliance,
                title: "Compliance Review",
                description: "Document contains content related to \(analysis.complianceChecks.count) compliance areas requiring review.",
                impact: .neutral,
                confidence: 0.7
            ))
        }
        
        // Action items insights
        if !analysis.actionItems.isEmpty {
            insights.append(BusinessAnalysisResult.BusinessInsight(
                category: .operational,
                title: "Action Items",
                description: "Found \(analysis.actionItems.count) action items that require attention.",
                impact: .opportunity,
                confidence: 0.8
            ))
        }
        
        return insights
    }
    
    private func generateRecommendations(from analysis: BusinessDocumentAnalysis, insights: [BusinessAnalysisResult.BusinessInsight]) async -> [BusinessAnalysisResult.Recommendation] {
        var recommendations: [BusinessAnalysisResult.Recommendation] = []
        
        // Document type specific recommendations
        switch analysis.documentType {
        case .financialReport:
            recommendations.append(BusinessAnalysisResult.Recommendation(
                title: "Financial Review",
                description: "Schedule a detailed financial review with stakeholders to discuss key metrics and trends.",
                priority: .shortTerm,
                effort: .medium,
                expectedOutcome: "Better financial oversight and decision-making"
            ))
            
        case .contract:
            recommendations.append(BusinessAnalysisResult.Recommendation(
                title: "Legal Review",
                description: "Have legal counsel review the contract terms and identify potential risks or issues.",
                priority: .immediate,
                effort: .high,
                expectedOutcome: "Risk mitigation and compliance assurance"
            ))
            
        case .invoice:
            recommendations.append(BusinessAnalysisResult.Recommendation(
                title: "Payment Processing",
                description: "Verify payment terms and ensure timely processing to maintain good vendor relationships.",
                priority: .immediate,
                effort: .low,
                expectedOutcome: "Improved cash flow management"
            ))
            
        default:
            break
        }
        
        // Risk-based recommendations
        let highRisks = analysis.riskIndicators.filter { $0.severity == .high || $0.severity == .critical }
        if !highRisks.isEmpty {
            recommendations.append(BusinessAnalysisResult.Recommendation(
                title: "Risk Mitigation",
                description: "Develop mitigation strategies for identified high-priority risks.",
                priority: .immediate,
                effort: .high,
                expectedOutcome: "Reduced exposure to business risks"
            ))
        }
        
        // Compliance recommendations
        if !analysis.complianceChecks.isEmpty {
            recommendations.append(BusinessAnalysisResult.Recommendation(
                title: "Compliance Audit",
                description: "Conduct a comprehensive compliance audit to ensure all requirements are met.",
                priority: .shortTerm,
                effort: .medium,
                expectedOutcome: "Regulatory compliance and risk reduction"
            ))
        }
        
        return recommendations
    }
    
    private func createExecutiveSummary(
        businessAnalysis: BusinessDocumentAnalysis,
        insights: [BusinessAnalysisResult.BusinessInsight],
        recommendations: [BusinessAnalysisResult.Recommendation]
    ) async -> BusinessAnalysisResult.ExecutiveSummary {
        
        var keyFindings: [String] = []
        var criticalIssues: [String] = []
        var opportunities: [String] = []
        var nextSteps: [String] = []
        
        // Key findings
        keyFindings.append("Document classified as: \(businessAnalysis.documentType.rawValue)")
        
        if let financialData = businessAnalysis.financialData {
            if let revenue = financialData.totalRevenue {
                keyFindings.append("Total revenue: \(formatCurrency(revenue, currency: financialData.currencies.first ?? "USD"))")
            }
            if let profitMargin = financialData.profitMargin {
                keyFindings.append("Profit margin: \(String(format: "%.1f", profitMargin))%")
            }
        }
        
        keyFindings.append("Identified \(businessAnalysis.riskIndicators.count) risk indicators")
        keyFindings.append("Found \(businessAnalysis.actionItems.count) action items")
        
        // Critical issues
        let highRisks = businessAnalysis.riskIndicators.filter { $0.severity == .high || $0.severity == .critical }
        if !highRisks.isEmpty {
            criticalIssues.append("\(highRisks.count) high-priority risks identified")
        }
        
        let nonCompliant = businessAnalysis.complianceChecks.filter { $0.status == .nonCompliant }
        if !nonCompliant.isEmpty {
            criticalIssues.append("\(nonCompliant.count) compliance issues found")
        }
        
        // Opportunities
        let positiveInsights = insights.filter { $0.impact == .positive || $0.impact == .opportunity }
        if !positiveInsights.isEmpty {
            opportunities.append("\(positiveInsights.count) positive insights identified")
        }
        
        if let financialData = businessAnalysis.financialData, let profitMargin = financialData.profitMargin, profitMargin > 15 {
            opportunities.append("Strong profitability performance")
        }
        
        // Next steps
        let immediateRecs = recommendations.filter { $0.priority == .immediate }
        if !immediateRecs.isEmpty {
            nextSteps.append("Address \(immediateRecs.count) immediate recommendations")
        }
        
        nextSteps.append("Review all identified risks and compliance requirements")
        nextSteps.append("Follow up on action items")
        
        // Overall assessment
        let assessment: BusinessAnalysisResult.ExecutiveSummary.Assessment
        if !criticalIssues.isEmpty {
            assessment = .critical
        } else if highRisks.count > 2 {
            assessment = .poor
        } else if highRisks.count > 0 {
            assessment = .fair
        } else if !opportunities.isEmpty {
            assessment = .good
        } else {
            assessment = .excellent
        }
        
        return BusinessAnalysisResult.ExecutiveSummary(
            keyFindings: keyFindings,
            criticalIssues: criticalIssues,
            opportunities: opportunities,
            nextSteps: nextSteps,
            overallAssessment: assessment
        )
    }
    
    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }
} 