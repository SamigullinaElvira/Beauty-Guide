//
//  Label + Extensions.swift
//  BeautyGuide
//
//  Created by Элина Абдрахманова on 14.04.2023.
//

import UIKit

extension UILabel {
    convenience init(text: String = "", font: UIFont?, textColor: UIColor) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.adjustsFontSizeToFitWidth = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
