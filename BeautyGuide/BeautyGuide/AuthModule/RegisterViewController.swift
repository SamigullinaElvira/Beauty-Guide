//
//  RegisterViewController.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 02.04.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - UI Components
    
    private let headerLabel = UILabel(text: "Регистрация",
                                      font: UIFont.systemFont(ofSize: 24, weight: .medium),
                                      textColor: .black)
    
    private lazy var userPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = #colorLiteral(red: 0.9450979829, green: 0.9450979829, blue: 0.9450979829, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "camera.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameField = CustomTextField(fieldType: .name)
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    private let nicknameField = CustomTextField(fieldType: .nickname)
    
    private lazy var signUpButton = CustomButton(title: "Зарегистрироваться", design: .big)
    private lazy var alreadyHaveAccountButton = CustomButton(title: "Уже есть аккаунт? Войти", design: .med)
    
    private let clientCheckboxLabel = UILabel(text: "Клиент",
                                              font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                              textColor: .black)
    private lazy var clientCheckboxButton = CustomCheckBox()
    private var clientStackView = UIStackView()
    
    private let masterCheckboxLabel = UILabel(text: "Мастер",
                                              font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                              textColor: .black)
    private lazy var masterCheckboxButton = CustomCheckBox()
    private var masterStackView = UIStackView()
    
    private var masterClientStackView = UIStackView()
    
    
    // MARK: - LifeCycle
    override func viewDidLayoutSubviews() {
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.height / 2
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setConstraints()
        addTaps()
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        alreadyHaveAccountButton.addTarget(self, action: #selector(didTapAlreadyHaveAccount), for: .touchUpInside)
        
        clientCheckboxButton.addTarget(self, action: #selector(buttonCheckUncheckClick(_:)), for: .touchUpInside)
        masterCheckboxButton.addTarget(self, action: #selector(buttonCheckUncheckClick(_:)), for: .touchUpInside)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.setHidesBackButton(true, animated:true)
        
        clientStackView = UIStackView(arrangedSubviews: [clientCheckboxButton, clientCheckboxLabel],
                                      axis: .horizontal,
                                      spacing: 7)
        masterStackView = UIStackView(arrangedSubviews: [masterCheckboxButton, masterCheckboxLabel],
                                      axis: .horizontal,
                                      spacing: 7)
        masterClientStackView = UIStackView(arrangedSubviews: [clientStackView, masterStackView],
                                            axis: .horizontal,
                                            spacing: 30)
        
        
        view.addSubview(headerLabel)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(nicknameField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(alreadyHaveAccountButton)
        view.addSubview(userPhotoImageView)
        view.addSubview(masterClientStackView)
    }
    
    var urlString = ""
    // MARK: - Selectors
    @objc func didTapSignUp() {
        let registerUserRequest = RegiserUserRequest(
            name: self.nameField.text ?? "",
            email: self.emailField.text ?? "",
            password: self.passwordField.text ?? "",
            checkbox: self.clientCheckboxSelected == false || self.masterCheckboxSelected == true,
            nickname: self.nicknameField.text ?? "",
            urlString: self.urlString
        )
        
        // Username check
        if !Validator.isNameValid(for: registerUserRequest.name) {
            AlertManager.showInvalidNameAlert(on: self)
            return
        }
        
        // Email check
        if !Validator.isEmailValid(for: registerUserRequest.email) {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        // Password check
        if !Validator.isPasswordValid(for: registerUserRequest.password) {
            AlertManager.showInvalidPasswordAlert(on: self)
            return
        }
        
        if !Validator.isNicknameValid(for: registerUserRequest.nickname) {
            AlertManager.showInvalidNicknameAlert(on: self)
            return
        }
        
        AuthService.shared.registerUser(with: registerUserRequest) { [weak self] wasRegistered, error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showRegistrationErrorAlert(on: self, with: error)
                return
            }
            
            if wasRegistered {
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.checkAuth()
                }
                
                if let currentUserId = Auth.auth().currentUser?.uid,
                   let photo = self.userPhotoImageView.image {
                    self.upload(currentUserId: currentUserId, photo: photo) { result in
                        switch result {
                        case .success(let url):
                            self.urlString = url.absoluteString
                            print("Photo uploaded successfully. URL: \(url)")
                            let db = Firestore.firestore()
                            let userRef = db.collection("users").document(currentUserId)
                            userRef.updateData(["photoUrl": self.urlString]) { error in
                                if let error = error {
                                    print("Failed to update user document with error: \(error)")
                                } else {
                                    print("Photo URL added to user document successfully")
                                }
                            }
                        case .failure(let error):
                            print("Failed to upload photo with error: \(error)")
                        }
                    }
                }
                
            } else {
                AlertManager.showRegistrationErrorAlert(on: self)
            }
        }
    }
    
    func upload(currentUserId: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child("avatars").child(currentUserId)
        
        guard let imageData = photo.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    @objc private func didTapAlreadyHaveAccount() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func addTaps() {
        let tapImageView = UITapGestureRecognizer(target: self, action: #selector(setUserPhoto))
        userPhotoImageView.isUserInteractionEnabled = true
        userPhotoImageView.addGestureRecognizer(tapImageView)
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
        if let originalImage = info[.editedImage] as? UIImage {
            userPhotoImageView.image = originalImage
        }
    }
    
    var clientCheckboxSelected = false
    var masterCheckboxSelected = false
    
    @objc private func buttonCheckUncheckClick(_ sender: UIButton) {
        if sender == clientCheckboxButton {
            clientCheckboxSelected = !clientCheckboxSelected
            if clientCheckboxSelected {
                masterCheckboxSelected = false
                masterCheckboxButton.isSelected = false
            }
        } else if sender == masterCheckboxButton {
            masterCheckboxSelected = !masterCheckboxSelected
            if masterCheckboxSelected {
                clientCheckboxSelected = false
                clientCheckboxButton.isSelected = false
            }
        }
        sender.isSelected = !sender.isSelected
    }
}

//MARK: - set constraints

extension RegisterViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            
            userPhotoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userPhotoImageView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 55),
            userPhotoImageView.widthAnchor.constraint(equalToConstant: 116),
            userPhotoImageView.heightAnchor.constraint(equalToConstant: 116),
            
            nameField.topAnchor.constraint(equalTo: userPhotoImageView.bottomAnchor, constant: 55),
            nameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameField.heightAnchor.constraint(equalToConstant: 35),
            nameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 35),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            nicknameField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            nicknameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameField.heightAnchor.constraint(equalToConstant: 35),
            nicknameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            passwordField.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 20),
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 35),
            passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            signUpButton.topAnchor.constraint(equalTo: masterClientStackView.bottomAnchor, constant: 25),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 38),
            signUpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            
            alreadyHaveAccountButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 12),
            alreadyHaveAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alreadyHaveAccountButton.heightAnchor.constraint(equalToConstant: 14),
            alreadyHaveAccountButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            masterClientStackView.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 25),
            masterClientStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
