//
//  MasterProfileViewController.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 14.04.2023.
//

import UIKit
import Firebase
import MapKit

class MasterProfileViewController: UIViewController {
    private var master: Master
    
    init(master: Master) {
        self.master = master
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = .init()
    let categoryLabel: UILabel = .init()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [ nameLabel, categoryLabel])
        sv.axis = .vertical
        sv.alignment = .leading
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    
    private lazy var userPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = #colorLiteral(red: 0.9450979829, green: 0.9450979829, blue: 0.9450979829, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var createEntry = MainButton(text: "Записаться онлайн")
    
    let segmentedControl = UISegmentedControl(items: ["Фото", "Инфо", "Услуги"])
    
    private let photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    private let infoTableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    private let servicesTableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ServicesTableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setConstraints()
        
        createEntry.addTarget(self, action: #selector(didTapCreateEntry), for: .touchUpInside)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getPhotoMaster()
    }
    
    @objc private func didTapCreateEntry() {
        let vc = EntryViewController()
        vc.masterID = master.unique_name
        vc.services = master.services
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getPhotoMaster() {
        let photoUrl = master.photoUrl
        
        if let url = URL(string: photoUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Ошибка загрузки изображения: \(error.localizedDescription)")
                    return
                }
                if let data = data {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.userPhotoImageView.contentMode = .scaleToFill
                            self.userPhotoImageView.image = image
                        }
                    }
                }
            }.resume()
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.height / 2
    }
    
    private func fetchMasterServicesData() {
        let db = Firestore.firestore()
        db.collection("masters").document(master.unique_name).collection("services").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.master.services = documents.map { (queryDocumentSnapshot) -> Service in
                let data = queryDocumentSnapshot.data()
                
                let name = data["name"] as? String ?? ""
                let price = data["price"] as? Int ?? nil
                
                return Service(name: name, price: price!)
            }
            DispatchQueue.main.async {
                self.servicesTableView.reloadData()
            }
        }
    }
}

// MARK: - Setup
extension MasterProfileViewController {
    private func setupUI() {
        view.backgroundColor = .white
        
        self.navigationItem.title = master.unique_name
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
        segmentedControlDidChange(segmentedControl)
        
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        categoryLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        categoryLabel.textColor = .darkGray
        nameLabel.text = master.name
        categoryLabel.text = master.category
        
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        
        fetchMasterServicesData()
        fetchMasterPhotos()
        servicesTableView.dataSource = self
        servicesTableView.delegate = self
        
        infoTableView.dataSource = self
        infoTableView.delegate = self
        
        view.addSubview(stackView)
        view.addSubview(userPhotoImageView)
        view.addSubview(createEntry)
        view.addSubview(segmentedControl)
        view.addSubview(photosCollectionView)
        view.addSubview(servicesTableView)
        view.addSubview(infoTableView)
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func segmentedControlDidChange(_ sender: UISegmentedControl) {
        photosCollectionView.isHidden = true
        servicesTableView.isHidden = true
        infoTableView.isHidden = true
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            photosCollectionView.isHidden = false
        case 1:
            infoTableView.isHidden = false
        case 2:
            servicesTableView.isHidden = false
        default:
            photosCollectionView.isHidden = false
        }
    }
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                
                index = numbers.index(after: index)
                
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MasterProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        master.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let photoUrl = master.photos[indexPath.item]
        
        if let url = URL(string: photoUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let imageView = cell.contentView.subviews.first as? UIImageView {
                            imageView.image = image
                        } else {
                            let imageView = UIImageView(image: image)
                            imageView.contentMode = .scaleAspectFill
                            imageView.clipsToBounds = true
                            imageView.frame = cell.contentView.bounds
                            cell.contentView.addSubview(imageView)
                        }
                    }
                }
            }.resume()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let param: CGFloat = collectionView.frame.width/3 - 1
        return CGSize(width: param, height: param)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MasterProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return .none
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .black
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        header.textLabel?.frame = header.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case infoTableView:
            return 5
        case servicesTableView:
            return master.services.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 37
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case infoTableView:
            if #available(iOS 14.0, *) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
                
                var configuration = UIListContentConfiguration.cell()
                
                configuration.textProperties.color = .systemBlue
                configuration.textProperties.font = .systemFont(ofSize: 15)
                switch indexPath.row {
                case 0:
                    configuration.text = "Обо мне \n\(master.description)"
                    configuration.textProperties.color = .black
                    cell.selectionStyle = .none
                case 1:
                    configuration.text = master.city + ", " + master.address
                case 2:
                    let phone = format(with: "+X (XXX) XXX-XX-XX", phone: master.phone)
                    configuration.text = phone
                case 3:
                    configuration.text = master.WhatsApp
                case 4:
                    configuration.text = master.ig
                default:
                    configuration.text = ""
                }
                
                cell.contentConfiguration = configuration
                return cell
            } else {
                fatalError()
            }
        case servicesTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ServicesTableViewCell else { return UITableViewCell() }
            cell.nameLabel.text = master.services[indexPath.row].name
            cell.priceLabel.text = "\(master.services[indexPath.row].price) ₽"
            cell.selectionStyle = .none
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView {
        case infoTableView:
            switch indexPath.row {
            case 1:
                let addr = "\(master.city), \(master.address)"
                openAddressInMap(address: addr)
            case 2:
                makePhoneCall()
            case 3:
                openLink(destinationURL: master.WhatsApp)
            case 4:
                openLink(destinationURL: master.ig)
            default:
                return
            }
        case servicesTableView:
            return
        default:
            return
        }
    }
}

// MARK: - info contacts links
extension MasterProfileViewController {
    ///Opens text address in maps
    func openAddressInMap(address: String?){
        guard let address = address else { return }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks?.first else {
                return
            }
            
            let location = placemarks.location?.coordinate
            
            if let lat = location?.latitude, let lon = location?.longitude{
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)))
                destination.name = address
                
                MKMapItem.openMaps(
                    with: [destination]
                )
            }
        }
    }
    
    func makePhoneCall() {
        if let url = URL(string: "tel://\(master.phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func openLink(destinationURL: String) {
        if let url = URL(string: destinationURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension MasterProfileViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.heightAnchor.constraint(equalToConstant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: userPhotoImageView.leadingAnchor, constant: -20),
            
            userPhotoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            userPhotoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            userPhotoImageView.widthAnchor.constraint(equalToConstant: 83),
            userPhotoImageView.heightAnchor.constraint(equalToConstant: 83),
            
            createEntry.topAnchor.constraint(equalTo: userPhotoImageView.bottomAnchor, constant: 30),
            createEntry.heightAnchor.constraint(equalToConstant: 43),
            createEntry.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            createEntry.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            segmentedControl.topAnchor.constraint(equalTo: createEntry.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            photosCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            photosCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            photosCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            photosCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            servicesTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            servicesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            servicesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            servicesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            infoTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            infoTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            infoTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            infoTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension MasterProfileViewController {
    private func fetchMasterPhotos() {
        let db = Firestore.firestore()
        db.collection("masters").document(master.unique_name).getDocument { (snapshot, error) in
            if let error = error {
                print("Error fetching master photos: \(error.localizedDescription)")
                return
            }
            
            if let document = snapshot, document.exists {
                if let photos = document.data()?["photos"] as? [String] {
                    self.master.photos = photos
                    self.photosCollectionView.reloadData()
                }
            }
        }
    }
}
