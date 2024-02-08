import UIKit

protocol CalendarViewProtocol: AnyObject {
    func selectItem(date: Date)
}
protocol CalendarCollectionDelegate: AnyObject {
    func selectedDateDidChange(newDate: String)
}

class CalendarCollectionView: UICollectionView {
    weak var calendarDelegate: CalendarViewProtocol?
    weak var collectionDelegate: CalendarCollectionDelegate?
    
    private let collectionLayout = UICollectionViewFlowLayout()
    
    private let idCalendarCell = "idCalendarCell"
    
    var selectedCellIndex: IndexPath?
    var selectedDate: String = "" {
        didSet {
            collectionDelegate?.selectedDateDidChange(newDate: selectedDate)
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: collectionLayout)
        
        configure()
        setupLayout()
        setDelegates()
        register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: idCalendarCell)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        collectionLayout.minimumInteritemSpacing = 3
        collectionLayout.scrollDirection = .horizontal
    }
    
    private func configure() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        showsHorizontalScrollIndicator = false
        
    }
    
    private func setDelegates() {
        dataSource = self
        delegate = self
    }
}

//MARK: - UICollectionViewDataSource

extension CalendarCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCalendarCell, for: indexPath) as? CalendarCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let currentDate = Date()
        
        let selectedWeekIndex = indexPath.item / 7
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.weekOfYear = selectedWeekIndex
        let date = calendar.date(byAdding: dateComponents, to: currentDate)!
        
        var startDateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        startDateComponents.weekday = 1
        let startDate = calendar.date(from: startDateComponents)!
        
        let dayOffset = indexPath.item % 7
        let displayDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd"
        
        let fullDate = fullDateFormatter.string(from: displayDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let formattedDate = dateFormatter.string(from: displayDate)
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEE"
        let formattedDayOfWeek = dayOfWeekFormatter.string(from: displayDate)
        
        cell.dateForCell(numberOfDay: formattedDate, dayOfWeek: formattedDayOfWeek, fullDate: fullDate)
        
        _ = calendar.component(.day, from: currentDate)
        
        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let displayDateComponents = calendar.dateComponents([.year, .month, .day], from: displayDate)
        
        if currentDateComponents == displayDateComponents {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension CalendarCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentDate = Date()
        let selectedWeekIndex = indexPath.item / 7
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.weekOfYear = selectedWeekIndex
        let date = calendar.date(byAdding: dateComponents, to: currentDate)!
        calendarDelegate?.selectItem(date: date)
        
        selectedCellIndex = indexPath
        
        selectedDate = getDateOnSelectedCell() ?? ""
    }
    
    func getDateOnSelectedCell() -> String? {
        if let selectedCellIndex = selectedCellIndex,
           let selectedCell = self.cellForItem(at: selectedCellIndex) as? CalendarCollectionViewCell {
            return selectedCell.dateOnSelectedCell
        } else {
            return convertDateToString(date: Date())
        }
    }
    
    public func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension CalendarCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width / 8,
               height: collectionView.frame.height)
    }
}
