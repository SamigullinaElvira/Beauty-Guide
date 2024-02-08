//
//  EntriesCollectionViewCell.swift
//  BeautyGuide
//
//  Created by Элина Абдрахманова on 24.05.2023.
//

import UIKit

class EntriesCollectionViewCell: UITableViewCell {
    static let identifier = "EntriesCell"

    let serviceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let masterNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    private func setup() {
        
        let stackView = UIStackView(arrangedSubviews: [ serviceLabel, masterNameLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.setCustomSpacing(CGFloat(6), after: serviceLabel)
        
        contentView.addSubview(stackView)
        contentView.addSubview(timeLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            timeLabel.widthAnchor.constraint(equalToConstant: 60),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            timeLabel.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    
    func configure(with entry: NewUserEntryRequest) {
        serviceLabel.text = entry.service.name
        masterNameLabel.text = "master: " + entry.masterID
        timeLabel.text = entry.time
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

