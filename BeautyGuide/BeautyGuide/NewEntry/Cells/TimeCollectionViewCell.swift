//
//  TimeCollectionViewCell.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 01.06.2023.
//

import UIKit

class TimeCollectionViewCell: UICollectionViewCell {
    static let identifier = "TimeCell"
    
    let textLabel = UILabel(
        font: UIFont.systemFont(ofSize: 15, weight: .regular),
        textColor: .black
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor.lightGray : UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
        }
    }

    private func setup() {
        contentView.backgroundColor = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
        
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layer.cornerRadius = contentView.frame.height/2
        contentView.layer.masksToBounds = true
        
        layer.cornerRadius = contentView.frame.height/2
        layer.masksToBounds = false
    }
}


