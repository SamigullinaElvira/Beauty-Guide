//
//  EntryViewController.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 01.06.2023.
//

import UIKit
import Firebase

struct FreeTime {
    let date: String
    let time: String
}

class EntryViewController: UIViewController {
    var masterID: String = ""
    var services: [Service] = []
    
    private var time: [FreeTime] = []
    
    let calendar = Calendar.current
    
    private var entryRequest = NewUserEntryRequest(userID: "", masterID: "", date: "", time: "", service: Service(name: "", price: 0))
            
    private lazy var monthLabel = UILabel(text: "Январь",
                                          font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                          textColor: .black)
    
    private let calendarView = CalendarView()
        
    private lazy var sendEntry = MainButton(text: "Отправить")
    
    private let timeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 12
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    private let servicesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setConstraints()
        
        sendEntry.addTarget(self, action: #selector(didTapSendEntry), for: .touchUpInside)
        
        timeCollectionView.register(TimeCollectionViewCell.self, forCellWithReuseIdentifier: TimeCollectionViewCell.identifier)
        timeCollectionView.dataSource = self
        timeCollectionView.delegate = self
        
        servicesCollectionView.dataSource = self
        servicesCollectionView.delegate = self
        servicesCollectionView.register(ServiceCollectionViewCell.self, forCellWithReuseIdentifier: ServiceCollectionViewCell.identifier)
        
        configureUserEntryRequest()
        getFreeTime()
    }
    
    @objc private func didTapSendEntry() {
        let date = calendarView.getSelectedDate()
        entryRequest.date = date ?? ""

        if !isEntryRequestNotEmpty(entryRequest: entryRequest) {
            AlertManager.showEmptyEntryError(on: self)
            return
        }
                
        let message = """
                        Дата: \(entryRequest.date)
                        Время: \(entryRequest.time)
                        Мастер: \(entryRequest.masterID)
                        Услуга: \(entryRequest.service.name)
                        Стоимость: \(entryRequest.service.price)
                    """
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Подтвердите запись", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Отмена", style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "ОК", style: .default) { [self] _ in
                uploadEntryToFirestore(request: entryRequest)
                didTapBack()
            })
            self.present(alert, animated: true)
        }
    }
    
    private func isEntryRequestNotEmpty(entryRequest: NewUserEntryRequest) -> Bool {
        return !entryRequest.userID.isEmpty && !entryRequest.masterID.isEmpty && !entryRequest.date.isEmpty && !entryRequest.time.isEmpty && !entryRequest.service.name.isEmpty && entryRequest.service.price > 0
    }
    
    func uploadEntryToFirestore(request: NewUserEntryRequest) {
        let db = Firestore.firestore()
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let entryData: [String: Any] = [
            "userID": entryRequest.userID,
            "masterID": entryRequest.masterID,
            "date": entryRequest.date,
            "time": entryRequest.time,
            "service": [
                "name": entryRequest.service.name,
                "price": entryRequest.service.price
            ] as [String : Any]
        ]
        
        let userDocRef = db.collection("users").document(currentUserID)
        let userEntriesCollectionRef = userDocRef.collection("userEntries")
        
        userEntriesCollectionRef.addDocument(data: entryData) { error in
            if let error = error {
                print("Ошибка при загрузке записи в Firestore: \(error.localizedDescription)")
            } else { return }
        }
        
        let masterDocRef = db.collection("masters").document(masterID)
        let masterEntriesCollectionRef = masterDocRef.collection("masterEntries")
        
        masterEntriesCollectionRef.addDocument(data: entryData) { error in
            if let error = error {
                print("Ошибка при загрузке записи в Firestore: \(error.localizedDescription)")
            } else { return }
        }
    }

    
    func configureUserEntryRequest() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        entryRequest.userID = userID
        entryRequest.masterID = masterID
    }

    func getFreeTime() {
        let db = Firestore.firestore()
        db.collection("masters").document(masterID).collection("freeTime").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.time = documents.map { (queryDocumentSnapshot) -> FreeTime in
                let data = queryDocumentSnapshot.data()

                let date = data["date"] as? String ?? ""
                let time = data["time"] as? String ?? ""

                return FreeTime(date: date, time: time)
            }
            self.time = self.time.sorted { $0.time < $1.time }
            DispatchQueue.main.async {
                self.timeCollectionView.reloadData()
            }
        }
    }
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension EntryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case timeCollectionView:
            return time.count
        case servicesCollectionView:
            return services.count
        default:
            return 0
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case timeCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeCollectionViewCell.identifier, for: indexPath) as! TimeCollectionViewCell
            cell.textLabel.text = time[indexPath.row].time
            return cell
        case servicesCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ServiceCollectionViewCell.identifier, for: indexPath) as! ServiceCollectionViewCell
            cell.textLabel.text = services[indexPath.row].name
            cell.priceLabel.text = String(services[indexPath.row].price) + " ₽"
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case timeCollectionView:
            let width: CGFloat = collectionView.frame.width/3 - 12
            let height: CGFloat = width/2.5
            return CGSize(width: width, height: height)
        case servicesCollectionView:
            let width: CGFloat = collectionView.frame.width
            return CGSize(width: width, height: 111)
        default:
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case timeCollectionView:
            entryRequest.time = time[indexPath.row].time
        case servicesCollectionView:
            entryRequest.service = services[indexPath.row]
        default:
            return
        }
    }
}



// MARK: - Setup
extension EntryViewController {
    private func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let month = dateFormatter.string(from: date)
        let capitalizedMonth = month.prefix(1).capitalized + month.dropFirst()
        monthLabel.text = String(capitalizedMonth)
        
        timeCollectionView.allowsSelection = true
        servicesCollectionView.allowsSelection = true
        
        view.addSubview(calendarView)
        view.addSubview(monthLabel)
        view.addSubview(timeCollectionView)
        view.addSubview(servicesCollectionView)
        view.addSubview(sendEntry)
    }
    
    @objc private func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setConstraints() {
        let itemWidth = (view.frame.width - 48)/3 - 12
        let itemHeight = itemWidth/2.5
        let height: CGFloat = itemHeight*3 + 48
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        
            calendarView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 3),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            calendarView.heightAnchor.constraint(equalToConstant: 70),
            calendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        
            timeCollectionView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 24),
            timeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            timeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            timeCollectionView.heightAnchor.constraint(equalToConstant: height),

            servicesCollectionView.topAnchor.constraint(equalTo: timeCollectionView.bottomAnchor, constant: 36),
            servicesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            servicesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            servicesCollectionView.bottomAnchor.constraint(equalTo: sendEntry.topAnchor, constant: -12),

            sendEntry.heightAnchor.constraint(equalToConstant: 43),
            sendEntry.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            sendEntry.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            sendEntry.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
        ])
    }
}
