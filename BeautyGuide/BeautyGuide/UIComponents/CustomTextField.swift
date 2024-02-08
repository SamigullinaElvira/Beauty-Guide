//
//  CustomTextField.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 02.04.2023.
//

import UIKit

class CustomTextField: UITextField {
    
    private let passwordHideImage = UIImage(systemName: "eye.slash")
    private let passwordShowImage = UIImage(systemName: "eye")
    
    private lazy var passwordShowHideButton = UIButton(type: .custom)
    
    enum CustomTextFieldType {
        case name
        case email
        case password
        case nickname
        case nameEdit
        case nickNameEdit
        case emailEdit
        case categoryEdit
        case infoUser
        case infoNumber
        case infoContats
    }
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8793205619, green: 0.8793205619, blue: 0.8793205619, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let authFieldType: CustomTextFieldType
    
    init(fieldType: CustomTextFieldType) {
        self.authFieldType = fieldType
        super.init(frame: .zero)
        
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        
        self.leftViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        
        passwordShowHideButton.setImage(passwordHideImage, for: .normal)
        passwordShowHideButton.setImage(passwordShowImage, for: .selected)
        passwordShowHideButton.addTarget(self, action: #selector(passViewTap), for: .touchUpInside)
        passwordShowHideButton.tintColor = #colorLiteral(red: 0.2862743139, green: 0.2862747014, blue: 0.2948748767, alpha: 1)
        
        switch fieldType {
        case .name:
            self.placeholder = "Введите имя"
        case .email:
            self.placeholder = "Введите email"
            self.keyboardType = .emailAddress
            self.textContentType = .emailAddress
            
        case .password:
            self.placeholder = "Введите пароль"
            self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true
            rightView = passwordShowHideButton
            rightViewMode = .always
            
        case .nickname:
            self.placeholder = "Введите никнейм"
            
        case .nameEdit:
            self.placeholder = "Имя"
        
        case .nickNameEdit:
            self.placeholder = "Ник"
            
        case .emailEdit:
            self.placeholder = "Email"
            
        case .categoryEdit:
            self.placeholder = "Категория"
            
        case .infoUser:
            placeholder = "О себе"
        
        case .infoNumber:
            placeholder = "Номер телефона"
            
        case .infoContats:
            placeholder = "Ссылка"
        }
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(lineView)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func passViewTap(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isSecureTextEntry = !sender.isSelected
    }
}

extension CustomTextField {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

