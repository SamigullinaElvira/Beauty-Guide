//
//  ServiceCollectionViewCell.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 01.06.2023.
//

import UIKit

class ServiceCollectionViewCell: UICollectionViewCell {
    static let identifier = "ServiceCell"
    
    let textLabel = UILabel(
        font: UIFont.systemFont(ofSize: 17, weight: .regular),
        textColor: .black
    )
    let priceLabel = UILabel(
        font: UIFont.systemFont(ofSize: 17, weight: .regular),
        textColor: .black
    )
    let icon = UIImageView(image: UIImage(systemName: "plus.circle.fill"))

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
        
        textLabel.numberOfLines = 0
        icon.tintColor = .black
        
        contentView.addSubview(textLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(icon)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            icon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            icon.widthAnchor.constraint(equalToConstant: icon.frame.width),
            
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            priceLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layer.cornerRadius = contentView.frame.height/5
        contentView.layer.masksToBounds = true
        
        layer.cornerRadius = contentView.frame.height/5
        layer.masksToBounds = false
    }
}
