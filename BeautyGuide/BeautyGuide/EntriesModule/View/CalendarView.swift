//
//  CalendarView.swift
//  BeautyGuide
//
//  Created by Элина Абдрахманова on 14.04.2023.
//

import UIKit

protocol CalendarDelegate: AnyObject {
    func selectedDateDidChange(newDate: String)
}

class CalendarView: UIView {
    private let collectionView = CalendarCollectionView()
    
    weak var delegate: CalendarDelegate?
    
    private var selectedDate: String = "" {
        didSet {
            delegate?.selectedDateDidChange(newDate: selectedDate)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setConstraints()

        collectionView.collectionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .none
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
    }
    public func setDelegate(_ delegate: CalendarViewProtocol?) {
        collectionView.calendarDelegate = delegate
    }
    
    public func getSelectedDate() -> String? {
        return collectionView.getDateOnSelectedCell()
    }
    
    private func updateSelectedDate(newDate: String) {
        self.selectedDate = newDate
    }
}

extension CalendarView: CalendarCollectionDelegate {
    func selectedDateDidChange(newDate: String) {
        updateSelectedDate(newDate: newDate)
    }
}

extension CalendarView {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
}
