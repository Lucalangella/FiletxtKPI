//
//  DataModel.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import Foundation
import SwiftUI

// MARK: - Extracted Data Models
struct ExtractedData {
    let text: String
    var dataPoints: [DataPoint]
    let statistics: TextStatistics
    var entities: [Entity]
    var sentiment: SentimentAnalysis
    var keywords: [Keyword]
    
    init(text: String) {
        self.text = text
        self.dataPoints = []
        self.statistics = TextStatistics(text: text)
        self.entities = []
        self.sentiment = SentimentAnalysis()
        self.keywords = []
    }
}

struct DataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let category: String?
    let timestamp: Date?
    
    init(label: String, value: Double, category: String? = nil, timestamp: Date? = nil) {
        self.label = label
        self.value = value
        self.category = category
        self.timestamp = timestamp
    }
}

struct TextStatistics {
    let wordCount: Int
    let characterCount: Int
    let sentenceCount: Int
    let paragraphCount: Int
    let averageWordLength: Double
    let readingTime: Double // in minutes
    
    init(text: String) {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        let paragraphs = text.components(separatedBy: "\n\n")
        
        self.wordCount = words.count
        self.characterCount = text.count
        self.sentenceCount = sentences.count
        self.paragraphCount = paragraphs.count
        self.averageWordLength = words.isEmpty ? 0 : Double(text.count) / Double(words.count)
        self.readingTime = Double(words.count) / 200.0 // Average reading speed
    }
}

struct Entity: Identifiable {
    let id = UUID()
    let name: String
    let type: EntityType
    let confidence: Double
    let occurrences: Int
    
    enum EntityType: String, CaseIterable {
        case person = "Person"
        case organization = "Organization"
        case location = "Location"
        case date = "Date"
        case number = "Number"
        case email = "Email"
        case url = "URL"
        
        var color: Color {
            switch self {
            case .person: return .blue
            case .organization: return .green
            case .location: return .orange
            case .date: return .purple
            case .number: return .red
            case .email: return .cyan
            case .url: return .indigo
            }
        }
    }
}

struct SentimentAnalysis {
    let score: Double // -1.0 to 1.0
    let label: String
    let confidence: Double
    
    init(score: Double = 0.0, label: String = "Neutral", confidence: Double = 0.0) {
        self.score = score
        self.label = label
        self.confidence = confidence
    }
    
    var color: Color {
        if score > 0.1 {
            return .green
        } else if score < -0.1 {
            return .red
        } else {
            return .gray
        }
    }
}

struct Keyword: Identifiable {
    let id = UUID()
    let word: String
    let frequency: Int
    let importance: Double
    
    init(word: String, frequency: Int, importance: Double = 0.0) {
        self.word = word
        self.frequency = frequency
        self.importance = importance
    }
}

// MARK: - Chart Models
enum ChartType: String, CaseIterable {
    case bar = "Bar Chart"
    case line = "Line Chart"
    case pie = "Pie Chart"
    case scatter = "Scatter Plot"
    case wordCloud = "Word Cloud"
    
    var icon: String {
        switch self {
        case .bar: return "chart.bar"
        case .line: return "chart.line.uptrend.xyaxis"
        case .pie: return "chart.pie"
        case .scatter: return "chart.xyaxis.line"
        case .wordCloud: return "textformat.abc"
        }
    }
}

enum ChartColorScheme: String, CaseIterable {
    case blue = "Blue"
    case green = "Green"
    case red = "Red"
    case purple = "Purple"
    case orange = "Orange"
    case mixed = "Mixed"
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .red: return .red
        case .purple: return .purple
        case .orange: return .orange
        case .mixed: return .blue
        }
    }
}

struct ChartConfiguration {
    let type: ChartType
    let title: String
    let dataPoints: [DataPoint]
    let colorScheme: ChartColorScheme
    let showLegend: Bool
    let showGrid: Bool
    
    init(type: ChartType, title: String, dataPoints: [DataPoint], colorScheme: ChartColorScheme = .blue, showLegend: Bool = true, showGrid: Bool = true) {
        self.type = type
        self.title = title
        self.dataPoints = dataPoints
        self.colorScheme = colorScheme
        self.showLegend = showLegend
        self.showGrid = showGrid
    }
}

// MARK: - Analysis Results
struct AnalysisResult {
    let extractedData: ExtractedData
    let charts: [ChartConfiguration]
    let insights: [String]
    let processingTime: TimeInterval
    
    init(extractedData: ExtractedData, charts: [ChartConfiguration] = [], insights: [String] = [], processingTime: TimeInterval = 0.0) {
        self.extractedData = extractedData
        self.charts = charts
        self.insights = insights
        self.processingTime = processingTime
    }
}

// MARK: - Business Document Models
struct BusinessDocumentAnalysis {
    var documentType: DocumentType
    var financialData: FinancialData?
    var contractTerms: ContractTerms?
    var businessMetrics: BusinessMetrics
    var riskIndicators: [RiskIndicator]
    var complianceChecks: [ComplianceCheck]
    var actionItems: [ActionItem]
    
    init(documentType: DocumentType = .unknown) {
        self.documentType = documentType
        self.financialData = nil
        self.contractTerms = nil
        self.businessMetrics = BusinessMetrics(kpis: [], trends: [], benchmarks: [])
        self.riskIndicators = []
        self.complianceChecks = []
        self.actionItems = []
    }
}

enum DocumentType: String, CaseIterable {
    case financialReport = "Financial Report"
    case contract = "Contract"
    case invoice = "Invoice"
    case businessPlan = "Business Plan"
    case proposal = "Proposal"
    case meetingMinutes = "Meeting Minutes"
    case marketResearch = "Market Research"
    case legalDocument = "Legal Document"
    case receipt = "Receipt"
    case unknown = "Unknown"
    
    var icon: String {
        switch self {
        case .financialReport: return "chart.line.uptrend.xyaxis"
        case .contract: return "doc.text"
        case .invoice: return "creditcard"
        case .businessPlan: return "building.2"
        case .proposal: return "doc.plaintext"
        case .meetingMinutes: return "person.3"
        case .marketResearch: return "chart.bar.doc.horizontal"
        case .legalDocument: return "scale.3d"
        case .receipt: return "receipt"
        case .unknown: return "questionmark.doc"
        }
    }
    
    var color: Color {
        switch self {
        case .financialReport: return .green
        case .contract: return .blue
        case .invoice: return .orange
        case .businessPlan: return .purple
        case .proposal: return .indigo
        case .meetingMinutes: return .cyan
        case .marketResearch: return .mint
        case .legalDocument: return .red
        case .receipt: return .yellow
        case .unknown: return .gray
        }
    }
}

struct FinancialData {
    let amounts: [FinancialAmount]
    let currencies: [String]
    let totalRevenue: Double?
    let totalExpenses: Double?
    let profitMargin: Double?
    let cashFlow: Double?
    let keyFinancialRatios: [FinancialRatio]
    
    struct FinancialAmount {
        let value: Double
        let currency: String
        let description: String
        let category: FinancialCategory
        let date: Date?
        
        enum FinancialCategory: String, CaseIterable {
            case revenue = "Revenue"
            case expense = "Expense"
            case profit = "Profit"
            case loss = "Loss"
            case investment = "Investment"
            case tax = "Tax"
            case other = "Other"
        }
    }
    
    struct FinancialRatio {
        let name: String
        let value: Double
        let benchmark: Double?
        let status: RatioStatus
        
        enum RatioStatus: String {
            case excellent = "Excellent"
            case good = "Good"
            case average = "Average"
            case poor = "Poor"
            case critical = "Critical"
        }
    }
}

struct ContractTerms {
    let parties: [String]
    let startDate: Date?
    let endDate: Date?
    let contractValue: Double?
    let currency: String?
    let keyTerms: [ContractTerm]
    let obligations: [Obligation]
    let penalties: [Penalty]
    
    struct ContractTerm {
        let term: String
        let description: String
        let importance: TermImportance
        
        enum TermImportance: String {
            case critical = "Critical"
            case important = "Important"
            case standard = "Standard"
            case minor = "Minor"
        }
    }
    
    struct Obligation {
        let party: String
        let obligation: String
        let deadline: Date?
        let status: ObligationStatus
        
        enum ObligationStatus: String {
            case pending = "Pending"
            case completed = "Completed"
            case overdue = "Overdue"
            case waived = "Waived"
        }
    }
    
    struct Penalty {
        let description: String
        let amount: Double?
        let trigger: String
        let severity: PenaltySeverity
        
        enum PenaltySeverity: String {
            case minor = "Minor"
            case moderate = "Moderate"
            case severe = "Severe"
            case critical = "Critical"
        }
    }
}

struct BusinessMetrics {
    let kpis: [KPI]
    let trends: [Trend]
    let benchmarks: [Benchmark]
    
    struct KPI {
        let name: String
        let value: Double
        let target: Double?
        let unit: String
        let status: KPIStatus
        
        enum KPIStatus: String {
            case onTrack = "On Track"
            case behind = "Behind"
            case ahead = "Ahead"
            case critical = "Critical"
        }
    }
    
    struct Trend {
        let metric: String
        let direction: TrendDirection
        let magnitude: Double
        let period: String
        
        enum TrendDirection: String {
            case increasing = "Increasing"
            case decreasing = "Decreasing"
            case stable = "Stable"
            case fluctuating = "Fluctuating"
        }
    }
    
    struct Benchmark {
        let metric: String
        let industryAverage: Double
        let companyValue: Double
        let performance: BenchmarkPerformance
        
        enum BenchmarkPerformance: String {
            case aboveAverage = "Above Average"
            case average = "Average"
            case belowAverage = "Below Average"
            case topPerformer = "Top Performer"
        }
    }
}

struct RiskIndicator {
    let riskType: RiskType
    let description: String
    let severity: RiskSeverity
    let probability: Double
    let impact: String
    let mitigation: String?
    
    enum RiskType: String, CaseIterable {
        case financial = "Financial"
        case legal = "Legal"
        case operational = "Operational"
        case market = "Market"
        case compliance = "Compliance"
        case reputational = "Reputational"
    }
    
    enum RiskSeverity: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
    }
}

struct ComplianceCheck {
    let regulation: String
    let requirement: String
    let status: ComplianceStatus
    let deadline: Date?
    let notes: String?
    
    enum ComplianceStatus: String {
        case compliant = "Compliant"
        case nonCompliant = "Non-Compliant"
        case pending = "Pending"
        case exempt = "Exempt"
    }
}

struct ActionItem {
    let title: String
    let description: String
    let priority: ActionPriority
    let assignee: String?
    let deadline: Date?
    let status: ActionStatus
    
    enum ActionPriority: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
    }
    
    enum ActionStatus: String {
        case pending = "Pending"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
}

// MARK: - Enhanced Analysis Results
struct BusinessAnalysisResult {
    let basicAnalysis: AnalysisResult
    let businessAnalysis: BusinessDocumentAnalysis
    let insights: [BusinessInsight]
    let recommendations: [Recommendation]
    let executiveSummary: ExecutiveSummary
    
    struct BusinessInsight {
        let category: InsightCategory
        let title: String
        let description: String
        let impact: InsightImpact
        let confidence: Double
        
        enum InsightCategory: String {
            case financial = "Financial"
            case operational = "Operational"
            case strategic = "Strategic"
            case risk = "Risk"
            case compliance = "Compliance"
        }
        
        enum InsightImpact: String {
            case positive = "Positive"
            case negative = "Negative"
            case neutral = "Neutral"
            case opportunity = "Opportunity"
        }
    }
    
    struct Recommendation {
        let title: String
        let description: String
        let priority: RecommendationPriority
        let effort: EffortLevel
        let expectedOutcome: String
        
        enum RecommendationPriority: String {
            case immediate = "Immediate"
            case shortTerm = "Short Term"
            case mediumTerm = "Medium Term"
            case longTerm = "Long Term"
        }
        
        enum EffortLevel: String {
            case low = "Low"
            case medium = "Medium"
            case high = "High"
        }
    }
    
    struct ExecutiveSummary {
        let keyFindings: [String]
        let criticalIssues: [String]
        let opportunities: [String]
        let nextSteps: [String]
        let overallAssessment: Assessment
        
        enum Assessment: String {
            case excellent = "Excellent"
            case good = "Good"
            case fair = "Fair"
            case poor = "Poor"
            case critical = "Critical"
        }
    }
} 