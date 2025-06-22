//
//  Color.swift
//  TestCoreML
//
//  Created by OmAr Kader on 21/06/2025.
//

import SwiftUI

extension UIColor {

    convenience init(_ red: Int,_ green: Int,_ blue: Int, alpha: Float = 1) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha))
    }
    
    var color: Color {
        return Color(self)
    }
}
