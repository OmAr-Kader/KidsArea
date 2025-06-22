//
//  HomeViewModel.swift
//  TestCoreML
//
//  Created by OmAr Kader on 20/06/2025.
//

import SwiftUI
import QuickLookThumbnailing
import Foundation

@MainActor
final class HomeViewModel : ObservableObject, Sendable {
    
    @Published var items: [PDFItem] = []
    
    @MainActor
    func downloadPDF(pdfId: String) {
        guard let index = items.firstIndex(where: { $0.pdfId == pdfId }), let item = items[safe: index], let remotePDFURL = item.remotePDFURL else {
            return
        }
      
        let fileManager = FileManager.default
        let fileName = remotePDFURL.lastPathComponent
        let localURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)

        if fileManager.fileExists(atPath: localURL.path) {
            generateThumbnail(for: localURL, pdfId: pdfId)
            return
        }

        URLSession.shared.downloadTask(with: remotePDFURL) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else {
                return
            }
            do {
                try FileManager.default.moveItem(at: tempURL, to: localURL)
                DispatchQueue.main.async {
                    self.generateThumbnail(for: localURL, pdfId: pdfId)
                }
            } catch {
            }
        }.resume()
    }
    
    
    // MARK: HINT => REPLACE GETTING THUMBAIL FROM DOWNLOADED PDF TO => Your custom Thumbail
    private func generateThumbnail(for url: URL, pdfId: String) {
        let size = CGSize(width: 100, height: 140)
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: UIScreen.main.scale, representationTypes: .all)

        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
            if let thumbnail = thumbnail {
                DispatchQueue.main.async {
                    guard let index = self.items.firstIndex(where: { $0.pdfId == pdfId }), let item = self.items[safe: index] else {
                        return
                    }
                    self.items[index] = PDFItem(pdf: item, localPDFURL: url, thumbnailImage: thumbnail.uiImage)
                }
            } else if let error = error {
                print("Thumbnail generation failed: \(error.localizedDescription)")
            }
        }
    }
}
