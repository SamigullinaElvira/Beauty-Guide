//
//  MainButton.swift
//  BeautyGuide
//
//  Created by Элина Абдрахманова on 14.04.2023.
//
import UIKit

class MainButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(text: String) {
        self.init(type: .system)
        
        setTitle(text, for: .normal)
        configure()
    }
    
    private func configure() {
        backgroundColor =  #colorLiteral(red: 0.1333333333, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tintColor = .white
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
    }
}

