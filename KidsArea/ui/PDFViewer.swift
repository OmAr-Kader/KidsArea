//
//  PDFViewer.swift
//  Mix
//
//  Created by OmAr Kader on 04/02/2025.
//

import SwiftUI
import PDFKit


struct PDFViewer: View {
    let title: String
    let url: URL? // Local One
    @StateObject private var viewModel = PDFViewModel()
    @State private var searchText: String = ""
    @State private var isSearchEnabled: Bool = false

    init(title: String, url: URL?) {
        self.title = title
        self.url = url
    }
    
    var body: some View {
        let isLoading = viewModel.document == nil || viewModel.searchText.1
        ZStack {
            VStack {
                if let document = viewModel.document {
                    PDFKitView(document: document, searchText: viewModel.searchText.0) {
                        viewModel.searchText = (searchText, false)
                    }.edgesIgnoringSafeArea(.all)
                }
            }.opacity(isLoading ? 0.5 : 1)
            if isLoading {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .red)).frame(width: 20, height: 20).onCenter().controlSize(.large).onCenter()
            } else {
                Spacer(minLength: 0)
            }
        }.toolbar {
            if isSearchEnabled {
                ToolbarItem(placement: .principal) {
                    TextField("Search text...", text: $searchText, onCommit: { viewModel.searchText = (searchText, true) })
                        .foregroundStyle(.text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                }
            } else {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .foregroundStyle(.text)
                        .padding(.leading)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if isSearchEnabled {
                        self.dismissKeyboard()
                        if searchText.isEmpty {
                            viewModel.searchText = (searchText, false)
                        } else {
                            self.dismissKeyboard()
                            viewModel.searchText = (searchText, true)
                        }
                    } else {
                        withAnimation {
                            self.isSearchEnabled = true
                        }
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .padding()
                }
            }
        }.onAppear {
            guard let url else { return }
            viewModel.document = PDFDocument(url: url)
        }.tint(.gray)
    }
}

class PDFViewModel: ObservableObject {
    @Published var document: PDFDocument?
    @Published var searchText: (String , Bool) = ("", false)
    
    func loadPDF(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("Failed to download PDF: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.document = PDFDocument(data: data)
            }
        }.resume()
    }
}
