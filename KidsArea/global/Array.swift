//
//  Array.swift
//  TestCoreML
//
//  Created by OmAr Kader on 20/06/2025.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
