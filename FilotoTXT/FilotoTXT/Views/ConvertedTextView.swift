//
//  ConvertedTextView.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import SwiftUI

struct ConvertedTextView: View {
    let text: String
    let onExport: () -> Void
    let onAnalyze: () -> Void
    let canAnalyze: Bool
    let analysisButtonTitle: String
    let analysisButtonIcon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Converted Text")
                    .font(.headline)
                Spacer()
                
                // Analysis Button
                Button(action: onAnalyze) {
                    HStack(spacing: 4) {
                        Image(systemName: analysisButtonIcon)
                        Text(analysisButtonTitle)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(!canAnalyze)
                
                // Export Button
                Button("Export") {
                    onExport()
                }
                .buttonStyle(.borderedProminent)
            }
            
            ScrollView {
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 300)
        }
    }
}

#Preview {
    ConvertedTextView(
        text: "This is sample converted text that would appear after file conversion.",
        onExport: {},
        onAnalyze: {},
        canAnalyze: true,
        analysisButtonTitle: "Analyze with ML",
        analysisButtonIcon: "brain"
    )
} 