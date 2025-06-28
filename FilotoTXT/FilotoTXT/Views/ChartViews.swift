//
//  ChartViews.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import SwiftUI
import Charts

// MARK: - Bar Chart View
struct BarChartView: View {
    let dataPoints: [DataPoint]
    let title: String
    let colorScheme: ChartColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart(dataPoints) { dataPoint in
                BarMark(
                    x: .value("Category", dataPoint.label),
                    y: .value("Value", dataPoint.value)
                )
                .foregroundStyle(colorScheme.color)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Line Chart View
struct LineChartView: View {
    let dataPoints: [DataPoint]
    let title: String
    let colorScheme: ChartColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart(dataPoints) { dataPoint in
                LineMark(
                    x: .value("Category", dataPoint.label),
                    y: .value("Value", dataPoint.value)
                )
                .foregroundStyle(colorScheme.color)
                .symbol(Circle())
                .symbolSize(50)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Pie Chart View
struct PieChartView: View {
    let dataPoints: [DataPoint]
    let title: String
    
    private let colors: [Color] = [.blue, .green, .orange, .red, .purple, .cyan, .indigo, .pink, .yellow, .mint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                // Pie Chart
                ZStack {
                    ForEach(Array(dataPoints.enumerated()), id: \.element.id) { index, dataPoint in
                        PieSlice(
                            startAngle: startAngle(for: index),
                            endAngle: endAngle(for: index),
                            color: colors[index % colors.count]
                        )
                    }
                }
                .frame(width: 150, height: 150)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(dataPoints.enumerated()), id: \.element.id) { index, dataPoint in
                        HStack {
                            Circle()
                                .fill(colors[index % colors.count])
                                .frame(width: 12, height: 12)
                            Text(dataPoint.label)
                                .font(.caption)
                            Spacer()
                            Text("\(Int(dataPoint.value))")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(.leading, 16)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func startAngle(for index: Int) -> Angle {
        let total = dataPoints.reduce(0) { $0 + $1.value }
        let previousValues = dataPoints.prefix(index).reduce(0) { $0 + $1.value }
        return Angle(degrees: (previousValues / total) * 360)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let total = dataPoints.reduce(0) { $0 + $1.value }
        let currentAndPreviousValues = dataPoints.prefix(index + 1).reduce(0) { $0 + $1.value }
        return Angle(degrees: (currentAndPreviousValues / total) * 360)
    }
}

// MARK: - Pie Slice Shape
struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Word Cloud View
struct WordCloudView: View {
    let keywords: [Keyword]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(keywords.prefix(15)) { keyword in
                    Text(keyword.word)
                        .font(.system(size: fontSize(for: keyword)))
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
    
    private func fontSize(for keyword: Keyword) -> CGFloat {
        let maxFrequency = keywords.first?.frequency ?? 1
        let ratio = Double(keyword.frequency) / Double(maxFrequency)
        return 12 + (ratio * 16) // Font size between 12 and 28
    }
}

// MARK: - Chart Container View
struct ChartContainerView: View {
    let chartConfig: ChartConfiguration
    
    var body: some View {
        switch chartConfig.type {
        case .bar:
            BarChartView(
                dataPoints: chartConfig.dataPoints,
                title: chartConfig.title,
                colorScheme: chartConfig.colorScheme
            )
        case .line:
            LineChartView(
                dataPoints: chartConfig.dataPoints,
                title: chartConfig.title,
                colorScheme: chartConfig.colorScheme
            )
        case .pie:
            PieChartView(
                dataPoints: chartConfig.dataPoints,
                title: chartConfig.title
            )
        case .scatter:
            // For now, use line chart for scatter
            LineChartView(
                dataPoints: chartConfig.dataPoints,
                title: chartConfig.title,
                colorScheme: chartConfig.colorScheme
            )
        case .wordCloud:
            // This would need the keywords array, so we'll handle it separately
            Text("Word Cloud: \(chartConfig.title)")
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
    }
} 