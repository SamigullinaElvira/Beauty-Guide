//
//  CalendarCollectionViewCell.swift
//  BeautyGuide
//
//  Created by Элина Абдрахманова on 14.04.2023.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    var dateOnSelectedCell: String = ""
    
    private let dayOfWeekLabel: UILabel = {
       let label = UILabel()
        label.text = "Пн"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let numberOfDayLabel: UILabel = {
       let label = UILabel()
        label.text = "8"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                circleView.backgroundColor =  #colorLiteral(red: 0.850980401, green: 0.850980401, blue: 0.850980401, alpha: 0.2992549669)
            } else {
                circleView.backgroundColor = .clear
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
//        layer.cornerRadius = 10
        
        addSubview(dayOfWeekLabel)
        addSubview(numberOfDayLabel)
        addSubview(circleView)
    }
    
    public func dateForCell(numberOfDay: String, dayOfWeek: String, fullDate: String) {
        dayOfWeekLabel.text = dayOfWeek
        numberOfDayLabel.text = numberOfDay
        dateOnSelectedCell = fullDate
    }
}

extension CalendarCollectionViewCell {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            dayOfWeekLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dayOfWeekLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            
            circleView.centerXAnchor.constraint(equalTo: numberOfDayLabel.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: numberOfDayLabel.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 29),
            circleView.heightAnchor.constraint(equalToConstant: 29),
            
            numberOfDayLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            numberOfDayLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            
            
        ])
    }
}

