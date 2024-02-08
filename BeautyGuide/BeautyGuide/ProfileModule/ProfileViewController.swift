//
//  ProfileViewController.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 14.04.2023.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    private let uniqueNameLabel = UILabel(text: "unique_name",
                                          font: UIFont.systemFont(ofSize: 20, weight: .medium),
                                          textColor: .black)
    
    private let userNameLabel = UILabel(text: "Имя Фамилия",
                                        font: UIFont.systemFont(ofSize: 16, weight: .medium),
                                        textColor: .black)
    
    private lazy var userPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = #colorLiteral(red: 0.9450979829, green: 0.9450979829, blue: 0.9450979829, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var editButton = MainButton(text: "Редактировать")
    
    private let aboutUserLabel = UILabel(text: "О себе",
                                         font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                                         textColor: .black)
    
    private let userInfoView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor =  #colorLiteral(red: 0.8793205619, green: 0.8793205619, blue: 0.8793205619, alpha: 1)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Инфо"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    private let userInfoEditView = UserInfoEditView()
    
    private lazy var signOutButton = MainButton(text: "Выйти")
    
    override func viewDidLayoutSubviews() {
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.height / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setConstraints()
        self.signOutButton.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        
        getInfo()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        signOutButton.backgroundColor = .clear
        signOutButton.tintColor =  #colorLiteral(red: 1, green: 0.2428209186, blue: 0.2903954089, alpha: 1)
        
        view.addSubview(signOutButton)
        view.addSubview(uniqueNameLabel)
        view.addSubview(userNameLabel)
        view.addSubview(userPhotoImageView)
        view.addSubview(userInfoView)
        view.addSubview(userInfoEditView)
        view.addSubview(editButton)
        
    }
    
    // MARK: - Selectors
    @objc private func didTapSignOut() {
        AuthService.shared.signOut { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                AlertManager.showSignOutError(on: self, with: error)
                return
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.checkAuth()
            }
        }
    }
    
    @objc private func didTapEdit() {
        let editProfileVC = EditProfileViewController()
        let navController = UINavigationController(rootViewController: editProfileVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    private func getInfo() {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid
        db.collection("users").whereField("userId", isEqualTo: userId!).addSnapshotListener { (snap, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            for i in snap!.documentChanges {
                let name = i.document.get("name") as! String
                DispatchQueue.main.async {
                    self.userNameLabel.text = "\(name)"
                }
                
                let uniqueName = i.document.get("nickname") as! String
                DispatchQueue.main.async {
                    self.uniqueNameLabel.text = "\(uniqueName)"
                }
                
                let urlString = i.document.get("photoUrl") as? String
                DispatchQueue.main.async {
                    if let urlString = urlString {
                        self.loadImage(from: urlString)
                    }
                }
            }
        }
    }
}

//MARK: - set constraints

extension ProfileViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            uniqueNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            uniqueNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            userNameLabel.topAnchor.constraint(equalTo: userPhotoImageView.centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userNameLabel.trailingAnchor.constraint(equalTo: userPhotoImageView.leadingAnchor, constant: -20),
            
            userPhotoImageView.topAnchor.constraint(equalTo: uniqueNameLabel.bottomAnchor, constant: 20),
            userPhotoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            userPhotoImageView.widthAnchor.constraint(equalToConstant: 83),
            userPhotoImageView.heightAnchor.constraint(equalToConstant: 83),
            
            editButton.topAnchor.constraint(equalTo: userPhotoImageView.bottomAnchor, constant: 36),
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 43),
            
            userInfoView.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 25),
            userInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            userInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            userInfoView.heightAnchor.constraint(equalTo: userInfoView.widthAnchor, multiplier: 0.095),
            
            userInfoEditView.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 25),
            userInfoEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            userInfoEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            userInfoEditView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor, constant: -10),
            
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -160),
        ])
    }
}

extension ProfileViewController {
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.userPhotoImageView.contentMode = .scaleAspectFill
                    self.userPhotoImageView.image = image
                }
            }
        }
    }
}
