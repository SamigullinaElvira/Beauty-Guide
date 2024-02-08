//
//  EntriesViewController.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 14.04.2023.
//

import UIKit
import Firebase

class EntriesViewController: UIViewController {
    private lazy var monthLabel = UILabel(text: "Январь",
                                          font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                          textColor: .black)
    
    private let calendarView = CalendarView()
    
    private var userEntries: [NewUserEntryRequest] = []
    private var filteredEntries: [NewUserEntryRequest] = []
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setConstraints()
        
        calendarView.delegate = self
        
        fetchUserEntriesData() {
            let selectedDate = self.calendarView.getSelectedDate()
            self.updateEntriesList(newDate: selectedDate!)
        }
    }
    
    private func updateEntriesList(newDate: String) {
        filteredEntries = []
        for entry in userEntries {
            if entry.date == newDate {
                filteredEntries.append(entry)
            }
        }
        filteredEntries = filteredEntries.sorted { $0.time < $1.time }
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let month = dateFormatter.string(from: date)
        let capitalizedMonth = month.prefix(1).capitalized + month.dropFirst()
        monthLabel.text = String(capitalizedMonth)
        
        tableView.register(EntriesCollectionViewCell.self, forCellReuseIdentifier: EntriesCollectionViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        view.addSubview(calendarView)
        view.addSubview(monthLabel)
    }
}

extension EntriesViewController: CalendarDelegate {
    func selectedDateDidChange(newDate: String) {
        // Код, который будет выполнен при изменении selectedDate
        updateEntriesList(newDate: newDate)
    }
}

//MARK: - set constraints
extension EntriesViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            calendarView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 3),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            calendarView.heightAnchor.constraint(equalToConstant: 70),
            calendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension EntriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEntries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EntriesCollectionViewCell.identifier, for: indexPath) as! EntriesCollectionViewCell
        
        let entry = filteredEntries[indexPath.row]
        cell.configure(with: entry)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            if !self.filteredEntries.isEmpty && indexPath.row < self.filteredEntries.count {
                let entry = self.filteredEntries[indexPath.row]

                self.deleteEntry(entry) { success in
                    if success {
                        if indexPath.row < self.filteredEntries.count {
                            self.filteredEntries.remove(at: indexPath.row)
                            self.removeFromUserEntriesArray(filteredEntry: entry)
                        }

                        if indexPath.row < tableView.numberOfRows(inSection: indexPath.section) {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            tableView.reloadData()
                        }
                    }
                }
            }
            
            completion(true)
        }
        deleteAction.backgroundColor = UIColor.red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func removeFromUserEntriesArray(filteredEntry: NewUserEntryRequest) {
        if let matchingIndex = userEntries.firstIndex(where: { $0 == filteredEntry }) {
            let matchingEntry = userEntries[matchingIndex]
            userEntries.remove(at: matchingIndex)
        }
    }

    private func fetchUserEntriesData(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(currentUserID).collection("userEntries").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.userEntries = documents.map { (queryDocumentSnapshot) -> NewUserEntryRequest in
                let data = queryDocumentSnapshot.data()
                
                let masterID = data["masterID"] as? String ?? ""
                let date = data["date"] as? String ?? ""
                let time = data["time"] as? String ?? ""
                let serviceData = data["service"] as? [String: Any]
                
                let serviceName = serviceData?["name"] as! String
                let servicePrice = serviceData?["price"] as! Int
                let service = Service(name: serviceName, price: servicePrice)

                return NewUserEntryRequest(userID: currentUserID, masterID: masterID, date: date, time: time, service: service)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                completion()
            }
        }
    }
    
    private func deleteEntry(_ entry: NewUserEntryRequest, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        db.collection("users").document(currentUserID).collection("userEntries").whereField("date", isEqualTo: entry.date).whereField("time", isEqualTo: entry.time).limit(to: 1).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                completion(false)
                return
            }
        
            if let document = documents.first {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting entry: \(error)")
                        completion(false)
                    } else {
                        print("Entry deleted successfully")
                        completion(true)
                    }
                }
            } else {
                print("No matching document found")
                completion(false)
            }
        }
    }
}
