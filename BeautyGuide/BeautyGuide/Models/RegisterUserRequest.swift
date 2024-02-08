//
//  RegisterUserRequest.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 30.03.2023.
//

import Foundation

struct RegiserUserRequest {
    let name: String
    let email: String
    let password: String
    let checkbox: Bool
    let nickname: String
    var urlString: String
}
