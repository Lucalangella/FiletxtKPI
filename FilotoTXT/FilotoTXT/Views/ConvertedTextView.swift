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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Converted Text")
                    .font(.headline)
                Spacer()
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
        onExport: {}
    )
} 