//
//  SearchViewCell.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 06.05.2023.
//

import UIKit

class SearchViewCell: UITableViewCell {
    let nameLabel: UILabel = .init()
    let categoryLabel: UILabel = .init()
    let addressLabel: UILabel = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        categoryLabel.font = UIFont.systemFont(ofSize: 11)
        addressLabel.font = UIFont.systemFont(ofSize: 11)

        let stackView = UIStackView(arrangedSubviews: [ nameLabel, categoryLabel, addressLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.setCustomSpacing(CGFloat(10), after: nameLabel)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}
