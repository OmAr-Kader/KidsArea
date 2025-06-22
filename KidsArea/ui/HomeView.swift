//
//  HomeView.swift
//  TestCoreML
//
//  Created by OmAr Kader on 20/06/2025.
//

import SwiftUI
import Foundation
import ShimmerEffect
import QuickLookThumbnailing

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var columns: [GridItem] {
        let count = horizontalSizeClass == .compact ? 2 : 3
        return Array(repeating: GridItem(.flexible()), count: count)
    }
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(resource: .secondMain)]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(resource: .main)]
    }

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        if viewModel.items.isEmpty {
                            ForEach(0..<12) { _ in
                                PDFItemShimmer()
                            }
                        } else {
                            ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { _, item in
                                NavigationLink {
                                    PDFViewer(title: item.title, url: item.localPDFURL)
                                } label:{
                                    PDFItemView(item: item).onAppeared {
                                        viewModel.downloadPDF(pdfId: item.pdfId)
                                    }
                                }.disabled(item.localPDFURL == nil)
                            }
                        }
                    }.padding()
                }
                NavigationLink {
                    FreeFormDrawingView()
                } label: {
                    ImageSystem(systemIcon: "scribble", tint: .black)
                        .frame(size: 25)
                        .padding()
                        .background(.red)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding()
                }.onStart().onBottom()
                NavigationLink {
                    CameraView()
                } label: {
                    ImageSystem(systemIcon: "camera.fill", tint: .white)
                        .frame(size: 25)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding()
                }.onBottomEnd()
            }.navigationTitle("Kid Learing")
        }.onAppeared {
            Task(priority: .background) {
                await Task.afterSeconds(0.5)
                Task { @MainActor in
                    withAnimation {
                        viewModel.items = PDFItem.temp
                    }
                }
            }
        }.accentColor(.gray)
        
    }
    
    
    func openCamera() {
        // Camera logic here (custom camera view or image picker)
        print("Camera tapped")
    }
}

struct PDFItemView : View {
    
    let item: PDFItem
    
    var body: some View {
        VStack(alignment: .leading) {
            PDFThumbnailView(item: item)
            VStack {
                Text(item.title)
                    .foregroundStyle(.text)
                    .font(.system(size: 16))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }.height(40)
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    if Double(index) < floor(Double(item.rating)) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    } else if Double(index) < Double(item.rating) {
                        Image(systemName: "star.leadinghalf.filled")
                            .foregroundColor(.yellow)
                    } else {
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                    }
                }
                Text(String(format: "%.1f", item.rating))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }.padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
    }
}

struct PDFItemShimmer : View {
        
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .frame(height: 100)
                .shimmer(true)
                .scaledToFill()
            
            RoundedRectangle(cornerRadius: 8)
                .padding(2)
                .height(40)
                .scaledToFill()
                .shimmer(true)

            RoundedRectangle(cornerRadius: 8)
                .padding(2)
                .height(10)
                .scaledToFill()
                .shimmer(true)
                .lineLimit(1)
        }.padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
    }
}

struct PDFThumbnailView: View {
    let item: PDFItem

    var body: some View {
        if let image = item.thumbnailImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .cornerRadius(8)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .frame(height: 100)
                .shimmer(true)
                .scaledToFill()
            
        }
    }

}
