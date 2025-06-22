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
           PDFItem(pdfId: "1", title: "Flashcard numbers", url: "https://learnenglishkids.britishcouncil.org/sites/kids/files/attachment/flashcards-numbers-1-12.pdf", rating: 5.0),
           PDFItem(pdfId: "2", title: "Jack and the beanstalk", url: "https://learnenglishkids.britishcouncil.org/sites/kids/files/attachment/short-stories-jack-and-the-beanstalk-transcript.pdf", rating: 3.1),
           PDFItem(pdfId: "3", title: "Story of Childrens Rights", url: "https://www.unicef.ie/app/uploads/2022/06/Social-Story-The-Story-of-Childrens-Rights-.pdf", rating: 4.6),
           PDFItem(pdfId: "4", title: "Stories from Children", url: "https://www.wexfordcypsc.ie/sites/default/files/content/ebsa/EBSA-Resource-Pack-Section-9-EBSA-Stories-from-Children-and-Young-People-and-Parents-Care-Givers-(p88-95).pdf", rating: 4.6),
           PDFItem(pdfId: "5", title: "Connect", url: "https://elearnningcontent.blob.core.windows.net/elearnningcontent/content/2022/kg/kg_1/term_1/Pdf-books/Connect_kg1_E_-SB_T1.pdf", rating: 4.6),
           PDFItem(pdfId: "6", title: "Word list picture book", url: "https://www.cambridgeenglish.org/images/starters-word-list-picture-book.pdf", rating: 4.4),
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
