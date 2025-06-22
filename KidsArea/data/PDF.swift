//
//  PDF.swift
//  TestCoreML
//
//  Created by OmAr Kader on 20/06/2025.
//

import SwiftUI
import Foundation

struct PDFItem: Identifiable, Equatable, Sendable {
    
    @MainActor
    static var temp: [PDFItem] {
        [
           PDFItem(pdfId: "1", title: "Flashcard numbers", url: "", rating: 5.0),
           PDFItem(pdfId: "2", title: "Jack and the beanstalk", url: "", rating: 3.1),
           PDFItem(pdfId: "3", title: "Story of Childrens Rights", url: "", rating: 4.6),
           PDFItem(pdfId: "4", title: "Stories from Children", url: "", rating: 4.6),
           PDFItem(pdfId: "5", title: "Connect", url: "", rating: 4.6),
           PDFItem(pdfId: "6", title: "Word list picture book", url: "", rating: 4.4),
        ]
    }
    
    let pdfId: String
    let title: String
    let url: String
    let rating: Float
    let localPDFURL: URL?
    let thumbnailImage: UIImage?
    
    var id: String {
        pdfId + "_" + title + "_" + (localPDFURL?.absoluteString ?? "")
    }
    
    init(pdfId: String, title: String, url: String, rating: Float) {
        self.pdfId = pdfId
        self.title = title
        self.url = url
        self.rating = rating
        self.localPDFURL = nil
        self.thumbnailImage = nil
    }
    
    
    init(pdf: PDFItem, localPDFURL: URL, thumbnailImage: UIImage?) {
        self.pdfId = pdf.pdfId
        self.title = pdf.title
        self.url = pdf.url
        self.rating = pdf.rating
        self.localPDFURL = localPDFURL
        self.thumbnailImage = thumbnailImage
    }
    
    var remotePDFURL: URL? {
        URL(string: url)
    }
    
    var ratingString: String {
        String(format: "%.1f", rating)
    }
}
