//
//  EditProfilController.swift
//  BeautyGuide
//
//  Created by Элина Абдрахманова on 25.04.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private lazy var userPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = #colorLiteral(red: 0.9450979829, green: 0.9450979829, blue: 0.9450979829, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8793205619, green: 0.8793205619, blue: 0.8793205619, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8793205619, green: 0.8793205619, blue: 0.8793205619, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel = UILabel(text: "Имя",
                                    font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                                    textColor: .black)
    private let nameTextField = CustomTextField(fieldType: .nameEdit)
    private var nameStackView = UIStackView()
    
    private let nicknameLabel = UILabel(text: "Ник",
                                        font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                                        textColor: .black)
    private let nicknameTextField = CustomTextField(fieldType: .nickNameEdit)
    private var nicknameStackView = UIStackView()
    
    private let emailLabel = UILabel(text: "Email",
                                     font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                                     textColor: .black)
    private let emailTextField = CustomTextField(fieldType: .emailEdit)
    private var emailStackView = UIStackView()
    
    private var stackView = UIStackView()
    
    private lazy var deleteAccButton = MainButton(text: "Удалить аккаунт")
    private lazy var changeImageButton = MainButton(text: "Изменить фото")
    
    override func viewDidLayoutSubviews() {
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.height / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setConstraints()
        addTaps()
        
        getInfo()
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Редактировать профиль"
        deleteAccButton.tintColor =  #colorLiteral(red: 1, green: 0.2428209186, blue: 0.2903954089, alpha: 1)
        deleteAccButton.backgroundColor = .clear
        changeImageButton.tintColor =  #colorLiteral(red: 0, green: 0.3985355198, blue: 1, alpha: 1)
        changeImageButton.backgroundColor = .clear
        userPhotoImageView.contentMode = .scaleToFill
        
        deleteAccButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(saveInfo))
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0.3985355198, blue: 1, alpha: 1)
        
        nameStackView = UIStackView(arrangedSubviews: [nameLabel, nameTextField],
                                    axis: .horizontal,
                                    spacing: 60)
        nicknameStackView = UIStackView(arrangedSubviews: [nicknameLabel, nicknameTextField],
                                        axis: .horizontal,
                                        spacing: 60)
        emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField],
                                     axis: .horizontal,
                                     spacing: 50)
        stackView = UIStackView(arrangedSubviews: [nameStackView, nicknameStackView, emailStackView],
                                axis: .vertical,
                                spacing: 18)
        
        view.addSubview(stackView)
        view.addSubview(userPhotoImageView)
        view.addSubview(deleteAccButton)
        view.addSubview(changeImageButton)
        view.addSubview(lineView1)
        view.addSubview(lineView2)
    }
    
    private func addTaps() {
        let tapImageView = UITapGestureRecognizer(target: self, action: #selector(setUserPhoto))
        changeImageButton.isUserInteractionEnabled = true
        changeImageButton.addGestureRecognizer(tapImageView)
    }
    
    private lazy var imagePicker = UIImagePickerController()
    
    @objc private func setUserPhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let originalImage = info[.originalImage] as? UIImage {
            userPhotoImageView.image = originalImage
            
            uploadProfilePhoto(originalImage)
        }
    }
    
    private func uploadProfilePhoto(_ image: UIImage) {
        guard let currentUser = Auth.auth().currentUser,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let storageRef = Storage.storage().reference()
        let profilePhotosRef = storageRef.child("profile_photos/\(currentUser.uid).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        profilePhotosRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading profile photo: \(error)")
                return
            }
            
            // Update the photo URL in Firestore
            
        }
    }
    
    private func updatePhotoURL(_ photoURL: String) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        
        userRef.updateData([
            "photoUrl": photoURL
        ]) { error in
            if let error = error {
                print("Error updating photo URL in Firestore: \(error)")
                return
            }
            
            print("Photo URL updated successfully")
        }
    }
    
    private func getInfo() {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid
        db.collection("users").document(userId!).getDocument { (snapshot, error) in
            if let error = error {
                print("Error retrieving user data: \(error)")
                return
            }
            
            guard let document = snapshot?.data(),
                  let name = document["name"] as? String,
                  let email = document["email"] as? String,
                  let uniqueName = document["nickname"] as? String,
                  let photoUrlString = document["photoUrl"] as? String,
                  let photoUrl = URL(string: photoUrlString) else {
                // Handle missing or invalid data
                return
            }
            
            DispatchQueue.main.async {
                self.nameTextField.text = name
                self.emailTextField.text = email
                self.nicknameTextField.text = uniqueName
                self.downloadProfilePhoto(from: photoUrl)
            }
        }
    }
    
    @objc private func didTapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func saveInfo() {
        guard let nickname = nicknameTextField.text else {
            AlertManager.showInvalidNicknameAlert(on: self)
            return
        }
        
        if !Validator.isNicknameValid(for: nickname) {
            AlertManager.showInvalidNicknameAlert(on: self)
            return
        }
        
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid
        
        guard let name = self.nameTextField.text, Validator.isNameValid(for: name) else {
            AlertManager.showInvalidNameAlert(on: self)
            return
        }
        
        guard let email = self.emailTextField.text, Validator.isEmailValid(for: email) else {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        db.collection("users").document("\(userId!)").getDocument { (snapshot, error) in
            if let error = error {
                print("Error retrieving user data: \(error)")
                return
            }
            
            guard let document = snapshot?.data(), let currentUserNickname = document["nickname"] as? String else {
                self.saveUserData(db: db, userId: userId, email: email, name: name, nickname: nickname)
                return
            }
            
            if currentUserNickname == nickname {
                self.saveUserData(db: db, userId: userId, email: email, name: name, nickname: nickname)
            } else {
                self.checkNicknameAvailability(nickname: nickname) { isAvailable in
                    if !isAvailable {
                        DispatchQueue.main.async {
                            self.showNicknameExistsAlert(on: self)
                        }
                        return
                    }
                    
                    self.saveUserData(db: db, userId: userId, email: email, name: name, nickname: nickname)
                }
            }
        }
        
        let storageRef = Storage.storage().reference()
        let profilePhotosRef = storageRef.child("profile_photos/\(String(describing: Auth.auth().currentUser?.uid)).jpg")
        
        profilePhotosRef.downloadURL { (url, error) in
            if let error = error {
                print("Error retrieving profile photo URL: \(error)")
                return
            }
            
            guard let downloadURL = url else {
                print("Profile photo URL is nil")
                return
            }
            
            self.updatePhotoURL(downloadURL.absoluteString)
        }
    }
    
    func saveUserData(db: Firestore, userId: String?, email: String, name: String, nickname: String) {
        db.collection("users").document("\(userId!)").updateData([
            "email" : email,
            "name" : name,
            "nickname" : nickname
        ]) { error in
            if let error = error {
                print("Error updating user data: \(error)")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
            
            let currentUser = Auth.auth().currentUser
            
            if email != currentUser?.email {
                currentUser?.updateEmail(to: email) { error in
                    if let error = error {
                        print("Error updating user email: \(error)")
                    }
                }
            }
            
            
        }
    }
    
    func checkNicknameAvailability(nickname: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        usersRef.whereField("nickname", isEqualTo: nickname).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking nickname availability: \(error)")
                completion(false)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func showNicknameExistsAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Такой никнейм уже существует",
            message: "Пожалуйста, выберите другой никнейм.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    private func downloadProfilePhoto(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.userPhotoImageView.image = image
            }
        }.resume()
    }
}


//MARK: - set constraints

extension EditProfileViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            userPhotoImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30),
            userPhotoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userPhotoImageView.widthAnchor.constraint(equalToConstant: 95),
            userPhotoImageView.heightAnchor.constraint(equalToConstant: 95),
            
            changeImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeImageButton.topAnchor.constraint(equalTo: userPhotoImageView.bottomAnchor, constant: 10),
            
            stackView.topAnchor.constraint(equalTo: changeImageButton.bottomAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            
            deleteAccButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteAccButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -80),
            
            lineView1.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -30),
            lineView1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            lineView1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            lineView2.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            lineView2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            lineView2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            lineView1.heightAnchor.constraint(equalToConstant: 1),
            lineView2.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}

extension EditProfileViewController {
    @objc private func deleteAccount() {
        let alert = UIAlertController(
            title: "Удаление аккаунта",
            message: "Вы действительно хотите удалить аккаунт?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { _ in
            self.confirmDeleteAccount()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func confirmDeleteAccount() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        let userId = currentUser.uid
        
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user data: \(error)")
            }
        }
        
        currentUser.delete { error in
            if let error = error {
                print("Error deleting account: \(error)")
            } else {
                DispatchQueue.main.async {
                    let loginViewController = LoginViewController()
                    let navigationController = UINavigationController(rootViewController: loginViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                }
            }
        }
    }
}



