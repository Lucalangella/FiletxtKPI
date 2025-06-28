//
//  ContentView.swift
//  FilotoTXT
//
//  Created by Luca Langella 1 on 28/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = FileConverterViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("File to TXT Converter")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Convert any file to plain text format")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // File Selection Area
                FileSelectionView(
                    selectedFile: viewModel.selectedFile,
                    onSelectFile: viewModel.selectFile,
                    onChangeFile: viewModel.selectFile
                )
                
                // Convert Button
                if viewModel.selectedFile != nil {
                    Button(action: viewModel.convertFile) {
                        HStack {
                            if viewModel.isConverting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: viewModel.convertButtonIcon)
                            }
                            Text(viewModel.convertButtonTitle)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!viewModel.canConvert)
                }
                
                // Converted Text Area
                if viewModel.hasConvertedText {
                    ConvertedTextView(
                        text: viewModel.convertedText,
                        onExport: viewModel.exportFile
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .fileImporter(
            isPresented: $viewModel.showFilePicker,
            allowedContentTypes: [
                .text,
                .plainText,
                .data,
                .item,
                UTType(filenameExtension: "docx")!,
                UTType(filenameExtension: "pdf")!,
                UTType(filenameExtension: "md")!
            ],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                viewModel.handleFileSelection(files)
            case .failure(let error):
                viewModel.handleFileSelectionError(error)
            }
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ExportView(text: viewModel.convertedText, fileName: viewModel.fileName)
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") {
                viewModel.dismissAlert()
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    ContentView()
}
