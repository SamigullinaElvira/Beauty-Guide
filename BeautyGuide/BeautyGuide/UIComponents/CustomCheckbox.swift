//
//  CustonCheckbox.swift
//  BeautyGuide
//
//  Created by Элина Абдрахманова on 23.04.2023.
//

import UIKit

class CustomCheckBox: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(type: .custom)
        configure()
    }
    
    private func configure() {
        setImage(UIImage.init(named: "uncheckbox"), for: .normal)
        setImage(UIImage.init(named: "checkbox"), for: .selected)
        translatesAutoresizingMaskIntoConstraints = false
    }
}
