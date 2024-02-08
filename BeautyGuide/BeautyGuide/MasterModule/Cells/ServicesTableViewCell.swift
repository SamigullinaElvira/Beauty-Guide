//
//  ServicesTableViewCell.swift
//  Homework6
//
//  Created by Эльвира Самигуллина on 26.05.2023.
//

import UIKit

class ServicesTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
    
    let nameLabel: UILabel = .init()
    let priceLabel: UILabel = .init()
    
    private func setup() {
        nameLabel.font = .systemFont(ofSize: 15)
        nameLabel.numberOfLines = 0
        priceLabel.font = .boldSystemFont(ofSize: 15)
        priceLabel.numberOfLines = 0
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            priceLabel.widthAnchor.constraint(equalToConstant: 60),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -10),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
        ])
    }
}

