//
//  CustomButton.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 02.04.2023.
//

import UIKit

class CustomButton: UIButton {
    
    enum FontSize {
        case big
        case med
        case small
    }
    
    init(title: String, design: FontSize) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        self.backgroundColor = .clear
        
        self.setTitleColor(.black, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        switch design {
        case .big:
            self.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            self.backgroundColor = .black
            self.setTitleColor(.white, for: .normal)
        case .med:
            self.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        case .small:
            self.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
