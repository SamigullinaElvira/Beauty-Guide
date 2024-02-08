//
//  LoginViewController.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 30.03.2023.
//

import UIKit

class LoginViewController: UIViewController {
    // MARK: - UI Components
    private let headerLabel = UILabel(text: "Вход",
                                      font: UIFont.systemFont(ofSize: 24, weight: .medium),
                                      textColor: .black)
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "logotip")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    
    private let signInButton = CustomButton(title: "Войти", design: .big)
    private lazy var dontHaveAccountButton = CustomButton(title: "Нет аккаунта? Зарегистрироваться", design: .med)
    private lazy var forgotPasswordButton = CustomButton(title: "Забыли пароль?", design: .small)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setConstraints()
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        dontHaveAccountButton.addTarget(self, action: #selector(didTapDontHaveAccount), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .white
        
        view.addSubview(headerLabel)
        view.addSubview(logoImageView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(dontHaveAccountButton)
    }
    
    // MARK: - Selectors
    @objc private func didTapSignIn() {
        let loginRequest = LoginUserRequest(
              email: self.emailField.text ?? "",
              password: self.passwordField.text ?? ""
          )
          
          // Email check
          if !Validator.isEmailValid(for: loginRequest.email) {
              AlertManager.showInvalidEmailAlert(on: self)
              return
          }
          
          // Password check
          if !Validator.isPasswordValid(for: loginRequest.password) {
              print(loginRequest.password)
              AlertManager.showInvalidPasswordAlert(on: self)
              return
          }
          
          AuthService.shared.signIn(with: loginRequest) { error in
              if let error = error {
                  AlertManager.showSignInErrorAlert(on: self, with: error)
                  return
              }
              
              if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                  sceneDelegate.checkAuth()
              }
          }
    }
    
    @objc private func didTapDontHaveAccount() {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapForgotPassword() {
        let resetVC = ResetPasswordViewController()
            self.navigationController?.pushViewController(resetVC, animated: true)
    }
}

//MARK: - set constraints

extension LoginViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        
            logoImageView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 6),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor),
            
            emailField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 35),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 35),
            passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 6),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 14),
            forgotPasswordButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            
            signInButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 35),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 38),
            signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            
            dontHaveAccountButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 12),
            dontHaveAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dontHaveAccountButton.heightAnchor.constraint(equalToConstant: 14),
            dontHaveAccountButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])
    }
}
