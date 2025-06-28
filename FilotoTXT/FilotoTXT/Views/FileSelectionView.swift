//
//  FileSelectionView.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import SwiftUI

struct FileSelectionView: View {
    let selectedFile: FileModel?
    let onSelectFile: () -> Void
    let onChangeFile: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            if let selectedFile = selectedFile {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "doc")
                            .foregroundColor(.blue)
                        Text(selectedFile.name)
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Size: \(selectedFile.size)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Change File") {
                            onChangeFile()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            } else {
                Button(action: onSelectFile) {
                    VStack(spacing: 10) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text("Select File to Convert")
                            .font(.headline)
                        Text("Tap to choose any file")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    FileSelectionView(
        selectedFile: nil,
        onSelectFile: {},
        onChangeFile: {}
    )
} 