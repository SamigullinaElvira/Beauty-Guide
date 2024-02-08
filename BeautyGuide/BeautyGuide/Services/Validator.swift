//
//  Validator.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 03.04.2023.
//

import Foundation

class Validator {
    static func isNameValid(for name: String) -> Bool {
        let nameRegEx = "^[A-Za-zА-Яа-я\\s]+$"
        let namePred = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return namePred.evaluate(with: name)
    }
    
    static func isEmailValid(for email: String) -> Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isPasswordValid(for password: String) -> Bool {
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordRegEx = "^(?=.*[A-Za-zА-Яа-я])(?=.*[0-9]).{8,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    static func isNicknameValid(for nickname: String) -> Bool {
            return nickname.count >= 3
        }
}
