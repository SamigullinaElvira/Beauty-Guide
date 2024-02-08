//
//  SearchViewController.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 14.04.2023.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {
    private let db = Firestore.firestore()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.alpha = 0.8
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(SearchViewCell.self, forCellReuseIdentifier: "Cell")
        return tv
    }()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Поиск"
        sc.searchBar.tintColor = .black
        sc.searchBar.barStyle = .black
        sc.searchBar.sizeToFit()
        sc.searchBar.searchBarStyle = .prominent
        sc.searchBar.delegate = self
        return sc
    }()
    
    private var masters: [Master] = []
    private var filteredMasters = [Master]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchMastersData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setConstraints()
        
//        uploadData()
    }
    
    private func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    private func isFiltering() -> Bool {
        return searchController.isActive && !isSearchBarEmpty()
    }
    
    private func filterContentForSearch(searchText: String) {
        filteredMasters = masters.filter({ (master: Master) -> Bool in
            return master.unique_name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    private func fetchMastersData() {
        db.collection("masters").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.masters = documents.map { (queryDocumentSnapshot) -> Master in
                let data = queryDocumentSnapshot.data()
                
                let name = data["name"] as? String ?? ""
                let unique_name = data["unique_name"] as? String ?? ""
                let category = data["category"] as? String ?? ""
                let city = data["city"] as? String ?? ""
                let address = data["address"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let phone = data["phone"] as? String ?? ""
                let WhatsApp = data["WhatsApp"] as? String ?? ""
                let ig = data["ig"] as? String ?? ""
                let photoUrl = data["photoUrl"] as? String ?? ""
                let photos = data["photos"] as? [String] ?? [""]

                
                return Master(name: name, unique_name: unique_name, category: category, city: city, address: address, services: [], description: description, phone: phone, WhatsApp: WhatsApp, ig: ig, photoUrl: photoUrl, photos: photos)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}



// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() { return filteredMasters.count }
        return masters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? SearchViewCell else { return UITableViewCell() }
        
        let currentMaster: Master
        
        if isFiltering() {
            currentMaster = filteredMasters[indexPath.row]
        } else {
            currentMaster = masters[indexPath.row]
        }
        cell.nameLabel.text = "\(currentMaster.unique_name) | \(currentMaster.name)"
        cell.categoryLabel.text = currentMaster.category
        cell.addressLabel.text = "\(currentMaster.city), \(currentMaster.address)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var master = masters[indexPath.row]
        if isFiltering() {
            master = filteredMasters[indexPath.row]
        }
        let profileVC = MasterProfileViewController(master: master)
        let nav = UINavigationController(rootViewController: profileVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchText: searchController.searchBar.text!)
    }
}

// MARK: - Setup
extension SearchViewController {
    private func setupUI() {
        setBackground()
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController

        view.addSubview(tableView)
    }
    
    func setBackground() {
        let background = UIImage(named: "background")

        var imageView: UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

