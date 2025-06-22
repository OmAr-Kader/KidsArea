//
//  Wiki.swift
//  TestCoreML
//
//  Created by OmAr Kader on 20/06/2025.
//

import Foundation

func fetchWikipediaSummary(for topic: String, invoke: @escaping (WikiData) -> Void, failed: @escaping () -> Void) {
    let encoded = topic.replacing(" ", with: "_").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encoded)")!

    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data,
              let wiki = try? JSONDecoder().decode(WikiData.self, from: data) else {
            print("fetchWikipediaSummary Error")
            failed()
            return
        }
        print("fetchWikipediaSummary \(wiki)")
        invoke(WikiData(topic: topic, wiki: wiki))
    }.resume()
}


struct WikiData : Codable {
    
    let topic: String
    let extract: String
    let originalimage: WikiOriginalImage?
    let thumbnail: WikiThumbnail?
    
    init(topic: String, wiki: WikiData) {
        self.topic = topic
        self.extract = wiki.extract
        self.originalimage = wiki.originalimage
        self.thumbnail = wiki.thumbnail
    }
    
    init(extract: String) {
        self.topic = ""
        self.extract = extract
        self.originalimage = nil
        self.thumbnail = nil
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.topic = ""
        self.extract = try container.decode(String.self, forKey: .extract)
        self.originalimage = try container.decodeIfPresent(WikiOriginalImage.self, forKey: .originalimage)
        self.thumbnail = try container.decodeIfPresent(WikiThumbnail.self, forKey: .thumbnail)
    }
}

struct WikiOriginalImage: Codable {
    let source: String?
}

struct WikiThumbnail: Codable {
    let source: String?
}
