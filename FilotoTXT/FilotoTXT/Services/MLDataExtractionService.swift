//
//  MLDataExtractionService.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import Foundation
import NaturalLanguage
import CoreML

@MainActor
class MLDataExtractionService: ObservableObject {
    private let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass, .tokenType])
    
    func extractData(from text: String) async -> ExtractedData {
        let startTime = Date()
        
        var extractedData = ExtractedData(text: text)
        
        // Extract entities
        extractedData.entities = await extractEntities(from: text)
        
        // Analyze sentiment
        extractedData.sentiment = await analyzeSentiment(from: text)
        
        // Extract keywords
        extractedData.keywords = await extractKeywords(from: text)
        
        // Extract data points for charts
        extractedData.dataPoints = await extractDataPoints(from: text)
        
        return extractedData
    }
    
    private func extractEntities(from text: String) async -> [Entity] {
        var entities: [Entity] = []
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = text
        
        // Extract named entities
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag = tag {
                let entityName = String(text[tokenRange])
                let entityType = mapNLTagToEntityType(tag)
                let entity = Entity(
                    name: entityName,
                    type: entityType,
                    confidence: 0.8,
                    occurrences: countOccurrences(of: entityName, in: text)
                )
                entities.append(entity)
            }
            return true
        }
        
        // Extract numbers
        let numberEntities = extractNumbers(from: text)
        entities.append(contentsOf: numberEntities)
        
        // Extract emails and URLs
        let emailEntities = extractEmails(from: text)
        let urlEntities = extractURLs(from: text)
        entities.append(contentsOf: emailEntities)
        entities.append(contentsOf: urlEntities)
        
        return entities
    }
    
    private func mapNLTagToEntityType(_ tag: NLTag) -> Entity.EntityType {
        switch tag {
        case .personalName:
            return .person
        case .organizationName:
            return .organization
        case .placeName:
            return .location
        default:
            return .person
        }
    }
    
    private func extractNumbers(from text: String) -> [Entity] {
        let pattern = #"\b\d+(?:\.\d+)?\b"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        var entities: [Entity] = []
        regex?.enumerateMatches(in: text, range: range) { match, _, _ in
            if let match = match,
               let range = Range(match.range, in: text) {
                let number = String(text[range])
                let entity = Entity(
                    name: number,
                    type: .number,
                    confidence: 0.9,
                    occurrences: countOccurrences(of: number, in: text)
                )
                entities.append(entity)
            }
        }
        return entities
    }
    
    private func extractEmails(from text: String) -> [Entity] {
        let pattern = #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        var entities: [Entity] = []
        regex?.enumerateMatches(in: text, range: range) { match, _, _ in
            if let match = match,
               let range = Range(match.range, in: text) {
                let email = String(text[range])
                let entity = Entity(
                    name: email,
                    type: .email,
                    confidence: 0.95,
                    occurrences: countOccurrences(of: email, in: text)
                )
                entities.append(entity)
            }
        }
        return entities
    }
    
    private func extractURLs(from text: String) -> [Entity] {
        let pattern = #"https?://[^\s]+"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        var entities: [Entity] = []
        regex?.enumerateMatches(in: text, range: range) { match, _, _ in
            if let match = match,
               let range = Range(match.range, in: text) {
                let url = String(text[range])
                let entity = Entity(
                    name: url,
                    type: .url,
                    confidence: 0.95,
                    occurrences: countOccurrences(of: url, in: text)
                )
                entities.append(entity)
            }
        }
        return entities
    }
    
    private func analyzeSentiment(from text: String) async -> SentimentAnalysis {
        // Simple sentiment analysis based on positive/negative word lists
        let positiveWords = Set(["good", "great", "excellent", "amazing", "wonderful", "fantastic", "love", "like", "happy", "joy", "success", "win", "best", "perfect", "beautiful", "awesome", "brilliant", "outstanding", "superb", "terrific"])
        let negativeWords = Set(["bad", "terrible", "awful", "horrible", "hate", "dislike", "sad", "angry", "frustrated", "disappointed", "worst", "fail", "failure", "ugly", "terrible", "dreadful", "miserable", "awful", "horrible", "terrible"])
        
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var positiveCount = 0
        var negativeCount = 0
        
        for word in words {
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
            if positiveWords.contains(cleanWord) {
                positiveCount += 1
            } else if negativeWords.contains(cleanWord) {
                negativeCount += 1
            }
        }
        
        let totalSentimentWords = positiveCount + negativeCount
        let score: Double
        
        if totalSentimentWords == 0 {
            score = 0.0
        } else {
            score = Double(positiveCount - negativeCount) / Double(totalSentimentWords)
        }
        
        let label = sentimentLabel(for: score)
        let confidence = min(abs(score) * 2, 1.0) // Scale confidence based on score strength
        
        return SentimentAnalysis(score: score, label: label, confidence: confidence)
    }
    
    private func sentimentLabel(for score: Double) -> String {
        if score > 0.3 {
            return "Positive"
        } else if score < -0.3 {
            return "Negative"
        } else {
            return "Neutral"
        }
    }
    
    private func extractKeywords(from text: String) async -> [Keyword] {
        let words = text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty && $0.count > 2 }
        
        let stopWords = Set(["the", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "is", "are", "was", "were", "be", "been", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should", "may", "might", "can", "this", "that", "these", "those", "a", "an", "as", "from", "it", "its", "if", "then", "else", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than", "too", "very", "you", "your", "yours", "yourself", "yourselves", "i", "me", "my", "myself", "we", "our", "ours", "ourselves", "what", "which", "who", "whom", "whose", "he", "him", "his", "himself", "she", "her", "hers", "herself", "it", "its", "itself", "they", "them", "their", "theirs", "themselves"])
        
        var wordFrequency: [String: Int] = [:]
        
        for word in words {
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
            if !stopWords.contains(cleanWord) && cleanWord.count > 2 {
                wordFrequency[cleanWord, default: 0] += 1
            }
        }
        
        let sortedWords = wordFrequency.sorted { $0.value > $1.value }
        let topKeywords = Array(sortedWords.prefix(20))
        
        return topKeywords.map { word, frequency in
            let importance = Double(frequency) / Double(sortedWords.first?.value ?? 1)
            return Keyword(word: word, frequency: frequency, importance: importance)
        }
    }
    
    private func extractDataPoints(from text: String) async -> [DataPoint] {
        var dataPoints: [DataPoint] = []
        
        // Extract word frequency data points
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let wordFrequency = Dictionary(grouping: words, by: { $0.lowercased() })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(10)
        
        for (index, (word, frequency)) in wordFrequency.enumerated() {
            let dataPoint = DataPoint(
                label: word,
                value: Double(frequency),
                category: "Word Frequency"
            )
            dataPoints.append(dataPoint)
        }
        
        // Extract sentence length data points
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        let sentenceLengths = sentences.map { $0.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count }
        
        for (index, length) in sentenceLengths.prefix(10).enumerated() {
            let dataPoint = DataPoint(
                label: "Sentence \(index + 1)",
                value: Double(length),
                category: "Sentence Length"
            )
            dataPoints.append(dataPoint)
        }
        
        return dataPoints
    }
    
    private func countOccurrences(of substring: String, in text: String) -> Int {
        let pattern = NSRegularExpression.escapedPattern(for: substring)
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex?.numberOfMatches(in: text, range: range) ?? 0
    }
    
    // MARK: - Business Document Analysis
    
    func analyzeBusinessDocument(from text: String) async -> BusinessDocumentAnalysis {
        var analysis = BusinessDocumentAnalysis()
        
        // Classify document type
        analysis.documentType = await classifyDocumentType(from: text)
        
        // Extract business-specific data based on document type
        switch analysis.documentType {
        case .financialReport, .invoice, .receipt:
            analysis.financialData = await extractFinancialData(from: text)
        case .contract, .legalDocument:
            analysis.contractTerms = await extractContractTerms(from: text)
        default:
            break
        }
        
        // Extract business metrics
        analysis.businessMetrics = await extractBusinessMetrics(from: text)
        
        // Identify risks
        analysis.riskIndicators = await identifyRisks(from: text)
        
        // Check compliance
        analysis.complianceChecks = await checkCompliance(from: text)
        
        // Extract action items
        analysis.actionItems = await extractActionItems(from: text)
        
        return analysis
    }
    
    private func classifyDocumentType(from text: String) async -> DocumentType {
        let lowercasedText = text.lowercased()
        
        // Financial indicators
        let financialKeywords = ["revenue", "profit", "loss", "income", "expense", "balance sheet", "cash flow", "financial statement", "quarterly report", "annual report", "earnings", "margin", "roi", "ebitda"]
        let financialScore = financialKeywords.filter { lowercasedText.contains($0) }.count
        
        // Contract indicators
        let contractKeywords = ["agreement", "contract", "terms", "conditions", "party", "obligation", "liability", "indemnification", "termination", "breach", "clause", "section", "whereas", "hereby"]
        let contractScore = contractKeywords.filter { lowercasedText.contains($0) }.count
        
        // Invoice indicators
        let invoiceKeywords = ["invoice", "bill", "amount due", "payment terms", "due date", "tax", "subtotal", "total", "item", "quantity", "unit price", "invoice number"]
        let invoiceScore = invoiceKeywords.filter { lowercasedText.contains($0) }.count
        
        // Business plan indicators
        let businessPlanKeywords = ["business plan", "strategy", "market", "competition", "target", "goal", "objective", "mission", "vision", "executive summary", "market analysis", "financial projection"]
        let businessPlanScore = businessPlanKeywords.filter { lowercasedText.contains($0) }.count
        
        // Meeting minutes indicators
        let meetingKeywords = ["meeting", "minutes", "attendees", "agenda", "action items", "decisions", "discussion", "next steps", "date", "time", "location", "participants"]
        let meetingScore = meetingKeywords.filter { lowercasedText.contains($0) }.count
        
        // Legal document indicators
        let legalKeywords = ["legal", "law", "statute", "regulation", "compliance", "legal counsel", "attorney", "lawyer", "jurisdiction", "governing law", "legal notice"]
        let legalScore = legalKeywords.filter { lowercasedText.contains($0) }.count
        
        // Find the highest scoring category
        let scores = [
            (DocumentType.financialReport, financialScore),
            (DocumentType.contract, contractScore),
            (DocumentType.invoice, invoiceScore),
            (DocumentType.businessPlan, businessPlanScore),
            (DocumentType.meetingMinutes, meetingScore),
            (DocumentType.legalDocument, legalScore)
        ]
        
        let maxScore = scores.max { $0.1 < $1.1 }
        return maxScore?.0 ?? .unknown
    }
    
    private func extractFinancialData(from text: String) async -> FinancialData? {
        var amounts: [FinancialData.FinancialAmount] = []
        var currencies: Set<String> = []
        
        // Extract currency amounts with patterns
        let currencyPatterns = [
            #"\$[\d,]+(?:\.\d{2})?"#, // USD
            #"€[\d,]+(?:\.\d{2})?"#, // EUR
            #"£[\d,]+(?:\.\d{2})?"#, // GBP
            #"¥[\d,]+(?:\.\d{2})?"#, // JPY
            #"[\d,]+(?:\.\d{2})?\s*(?:USD|EUR|GBP|JPY|CAD|AUD)"# // Amount with currency code
        ]
        
        for pattern in currencyPatterns {
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            
            regex?.enumerateMatches(in: text, range: range) { match, _, _ in
                if let match = match,
                   let range = Range(match.range, in: text) {
                    let amountString = String(text[range])
                    if let amount = parseFinancialAmount(amountString) {
                        amounts.append(amount)
                        currencies.insert(amount.currency)
                    }
                }
            }
        }
        
        // Calculate financial metrics
        let totalRevenue = amounts.filter { $0.category == .revenue }.reduce(0) { $0 + $1.value }
        let totalExpenses = amounts.filter { $0.category == .expense }.reduce(0) { $0 + $1.value }
        let profitMargin = totalRevenue > 0 ? ((totalRevenue - totalExpenses) / totalRevenue) * 100 : nil
        
        // Generate financial ratios
        let ratios = generateFinancialRatios(revenue: totalRevenue, expenses: totalExpenses)
        
        return FinancialData(
            amounts: amounts,
            currencies: Array(currencies),
            totalRevenue: totalRevenue > 0 ? totalRevenue : nil,
            totalExpenses: totalExpenses > 0 ? totalExpenses : nil,
            profitMargin: profitMargin,
            cashFlow: totalRevenue - totalExpenses,
            keyFinancialRatios: ratios
        )
    }
    
    private func parseFinancialAmount(_ amountString: String) -> FinancialData.FinancialAmount? {
        // Remove currency symbols and parse
        let cleanString = amountString.replacingOccurrences(of: "[$,€£¥]", with: "", options: .regularExpression)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let number = numberFormatter.number(from: cleanString) else { return nil }
        
        // Determine currency
        let currency: String
        if amountString.hasPrefix("$") { currency = "USD" }
        else if amountString.hasPrefix("€") { currency = "EUR" }
        else if amountString.hasPrefix("£") { currency = "GBP" }
        else if amountString.hasPrefix("¥") { currency = "JPY" }
        else { currency = "USD" } // Default
        
        // Determine category based on context (simplified)
        let category: FinancialData.FinancialAmount.FinancialCategory = .other
        
        return FinancialData.FinancialAmount(
            value: number.doubleValue,
            currency: currency,
            description: "Extracted amount",
            category: category,
            date: nil
        )
    }
    
    private func generateFinancialRatios(revenue: Double, expenses: Double) -> [FinancialData.FinancialRatio] {
        var ratios: [FinancialData.FinancialRatio] = []
        
        if revenue > 0 {
            let profitMargin = ((revenue - expenses) / revenue) * 100
            ratios.append(FinancialData.FinancialRatio(
                name: "Profit Margin",
                value: profitMargin,
                benchmark: 15.0, // Industry average
                status: profitMargin > 20 ? .excellent : profitMargin > 10 ? .good : .average
            ))
        }
        
        return ratios
    }
    
    private func extractContractTerms(from text: String) async -> ContractTerms? {
        var parties: [String] = []
        var keyTerms: [ContractTerms.ContractTerm] = []
        var obligations: [ContractTerms.Obligation] = []
        var penalties: [ContractTerms.Penalty] = []
        
        // Extract parties (simplified - look for common patterns)
        let partyPatterns = [
            #"between\s+([A-Z][a-z]+\s+[A-Z][a-z]+(?:\s+Inc\.|\s+LLC|\s+Ltd\.)?)"#,
            #"party\s+([A-Z][a-z]+\s+[A-Z][a-z]+(?:\s+Inc\.|\s+LLC|\s+Ltd\.)?)"#
        ]
        
        for pattern in partyPatterns {
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            
            regex?.enumerateMatches(in: text, range: range) { match, _, _ in
                if let match = match,
                   let range = Range(match.range(at: 1), in: text) {
                    let party = String(text[range])
                    if !parties.contains(party) {
                        parties.append(party)
                    }
                }
            }
        }
        
        // Extract key terms
        let termKeywords = ["confidentiality", "non-compete", "termination", "liability", "indemnification", "governing law", "dispute resolution", "force majeure"]
        for keyword in termKeywords {
            if text.lowercased().contains(keyword.lowercased()) {
                keyTerms.append(ContractTerms.ContractTerm(
                    term: keyword.capitalized,
                    description: "Found in contract",
                    importance: .important
                ))
            }
        }
        
        return ContractTerms(
            parties: parties,
            startDate: nil,
            endDate: nil,
            contractValue: nil,
            currency: nil,
            keyTerms: keyTerms,
            obligations: obligations,
            penalties: penalties
        )
    }
    
    private func extractBusinessMetrics(from text: String) async -> BusinessMetrics {
        var kpis: [BusinessMetrics.KPI] = []
        var trends: [BusinessMetrics.Trend] = []
        var benchmarks: [BusinessMetrics.Benchmark] = []
        
        // Extract KPIs (simplified)
        let kpiPatterns = [
            ("Revenue Growth", #"revenue\s+growth\s+(\d+(?:\.\d+)?)%"#),
            ("Customer Satisfaction", #"satisfaction\s+(\d+(?:\.\d+)?)%"#),
            ("Employee Retention", #"retention\s+(\d+(?:\.\d+)?)%"#)
        ]
        
        for (name, pattern) in kpiPatterns {
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            
            regex?.enumerateMatches(in: text, range: range) { match, _, _ in
                if let match = match,
                   let range = Range(match.range(at: 1), in: text) {
                    let value = Double(text[range]) ?? 0
                    kpis.append(BusinessMetrics.KPI(
                        name: name,
                        value: value,
                        target: nil,
                        unit: "%",
                        status: value > 80 ? .onTrack : value > 60 ? .behind : .critical
                    ))
                }
            }
        }
        
        return BusinessMetrics(kpis: kpis, trends: trends, benchmarks: benchmarks)
    }
    
    private func identifyRisks(from text: String) async -> [RiskIndicator] {
        var risks: [RiskIndicator] = []
        
        // Risk keywords by category
        let riskKeywords: [RiskIndicator.RiskType: [String]] = [
            .financial: ["debt", "loss", "bankruptcy", "insolvency", "liquidity", "cash flow"],
            .legal: ["litigation", "lawsuit", "breach", "violation", "penalty", "fine"],
            .operational: ["downtime", "failure", "outage", "disruption", "shortage"],
            .market: ["competition", "decline", "recession", "volatility", "uncertainty"],
            .compliance: ["regulation", "audit", "violation", "non-compliance", "regulatory"],
            .reputational: ["scandal", "negative", "publicity", "reputation", "brand damage"]
        ]
        
        for (riskType, keywords) in riskKeywords {
            for keyword in keywords {
                if text.lowercased().contains(keyword.lowercased()) {
                    risks.append(RiskIndicator(
                        riskType: riskType,
                        description: "Identified \(keyword) risk",
                        severity: .medium,
                        probability: 0.5,
                        impact: "Potential business impact",
                        mitigation: "Review and address"
                    ))
                }
            }
        }
        
        return risks
    }
    
    private func checkCompliance(from text: String) async -> [ComplianceCheck] {
        var checks: [ComplianceCheck] = []
        
        // Common compliance areas
        let complianceAreas = [
            ("GDPR", ["data protection", "privacy"]),
            ("SOX", ["financial reporting", "internal controls"]),
            ("HIPAA", ["health information", "patient data"]),
            ("PCI DSS", ["payment card", "credit card"])
        ]
        
        for (regulation, keywords) in complianceAreas {
            let hasKeywords = keywords.contains { text.lowercased().contains($0.lowercased()) }
            if hasKeywords {
                checks.append(ComplianceCheck(
                    regulation: regulation,
                    requirement: "Review compliance requirements",
                    status: .pending,
                    deadline: nil,
                    notes: "Document contains relevant keywords"
                ))
            }
        }
        
        return checks
    }
    
    private func extractActionItems(from text: String) async -> [ActionItem] {
        var actionItems: [ActionItem] = []
        
        // Look for action item patterns
        let actionPatterns = [
            #"action\s+item[:\s]+([^.\n]+)"#,
            #"todo[:\s]+([^.\n]+)"#,
            #"next\s+step[:\s]+([^.\n]+)"#,
            #"follow\s+up[:\s]+([^.\n]+)"#
        ]
        
        for pattern in actionPatterns {
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            
            regex?.enumerateMatches(in: text, range: range) { match, _, _ in
                if let match = match,
                   let range = Range(match.range(at: 1), in: text) {
                    let description = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                    actionItems.append(ActionItem(
                        title: "Action Item",
                        description: description,
                        priority: .medium,
                        assignee: nil,
                        deadline: nil,
                        status: .pending
                    ))
                }
            }
        }
        
        return actionItems
    }
} 