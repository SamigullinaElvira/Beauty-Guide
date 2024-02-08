//
//  AlertManager.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 03.04.2023.
//

import UIKit

class AlertManager {
    
    private static func showBasicAlert(on vc: UIViewController, title: String, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }
}

// MARK: - Show Validation Alerts
extension AlertManager {
    
    public static func showInvalidNameAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Неверное имя", message: "Пожалуйста, введите допустимое имя. Используйте только буквы")
    }

    public static func showInvalidEmailAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Неверный адрес электронной почты", message: "Пожалуйста, введите действительный адрес электронной почты")
    }

    public static func showInvalidPasswordAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Неверный пароль", message: "Пожалуйста, введите действительный пароль. Используйте не менее 8 символов. Используйте хотя бы 1 цифру")
    }
}

// MARK: - Registration Errors
extension AlertManager {
    
    public static func showRegistrationErrorAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Неизвестная ошибка регистрации", message: nil)
    }

    public static func showRegistrationErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Неизвестная ошибка регистрации", message: "\(error.localizedDescription)")
    }
}


// MARK: - Log In Errors
extension AlertManager {
    
    public static func showSignInErrorAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Неизвестная ошибка входа", message: nil)
    }

    public static func showSignInErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Ошибка входа", message: "\(error.localizedDescription)")
    }
}

// MARK: - Logout Errors
extension AlertManager {
    public static func showSignOutError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Ошибка выхода", message: "\(error.localizedDescription)")
    }
}

// MARK: - New Entry Errors
extension AlertManager {
    public static func showEmptyEntryError(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Невозможно создать заявку", message: "Заполните все поля")
    }
}

extension AlertManager {
    public static func showInvalidNicknameAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Некорректный никнейм",
            message: "Пожалуйста, выберите другой никнейм.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
