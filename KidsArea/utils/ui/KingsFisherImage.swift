import Kingfisher
import SwiftUI
import Foundation
import Combine
import ShimmerEffect

struct KingsImageFull: View {
    private let urlString: String
    private let contentMode: SwiftUI.ContentMode
    private let height: CGFloat
    @State private var uiImage: UIImage?
    @State private var isLoading: Bool = true
    
    init(urlString: String, height: CGFloat, contentMode: SwiftUI.ContentMode = .fit) {
        self.urlString = urlString
        self.height = height
        self.contentMode = contentMode
    }
    
    var body: some View {
        ZStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .aspectRatio(contentMode: contentMode)
                    .scaledToFill()
                    .frame(height: height)
            } else {
                if isLoading {
                    RoundedRectangle(cornerRadius: 0)
                        .scaledToFill()
                        .shimmer(true)
                        .frame(height: height)
                }
                KFImage.url(URL(string: urlString), cacheKey: urlString)
                    .resizable()
                    .loadDiskFileSynchronously(false)
                    .cacheMemoryOnly(false)
                    .waitForCache(false)
                    .onFailure {_ in
                        isLoading = false
                    }
                    .onSuccess { result in
                        self.uiImage = result.image
                    }.scaledToFill().frame(height: height)
            }
        }
    }
}



extension CGSize {
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}
