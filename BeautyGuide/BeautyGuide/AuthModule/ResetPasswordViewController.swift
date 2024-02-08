//
//  ResetPasswordViewController.swift
//  BeautyGuide
//
//  Created by Элина Абдрахманова on 04.06.2023.
//

import Foundation
import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    
    private let headerLabel = UILabel(text: "Сброс пароля",
                                      font: UIFont.systemFont(ofSize: 24, weight: .regular),
                                      textColor: .black)
    
    private let emailField = CustomTextField(fieldType: .email)
    
    private let resetButton = CustomButton(title: "Отправить", design: .big)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setConstraints()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapBack))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        view.addSubview(headerLabel)
        view.addSubview(emailField)
        view.addSubview(resetButton)
    }
    
    @objc private func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func resetButtonTapped() {
        
        if !Validator.isEmailValid(for: emailField.text ?? "") {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        let auth = Auth.auth()
        auth.sendPasswordReset(withEmail: emailField.text!) { (error) in
            if error != nil {
                let alertController = UIAlertController(title: "Ошибка сброса пароля",
                                                        message: "Пользователь не найден",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true)
                return
            }
            
            let alertController = UIAlertController(title: "Успешно",
                                                    message: "Ссылка для сброса пароля была отправлена на указанную почту",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
            
        }
    }
}

extension ResetPasswordViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 300),
            
            emailField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 50),
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 35),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            resetButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 35),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 38),
            resetButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
        ])
    }
}
