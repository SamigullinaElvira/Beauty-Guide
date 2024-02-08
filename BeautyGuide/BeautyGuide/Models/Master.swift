//
//  Master.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 28.05.2023.
//

import Foundation

struct Master {
    var name: String
    let unique_name: String
    var category: String
    var city: String
    var address: String
    var services: [Service]
    var description: String
    var phone: String
    var WhatsApp: String
    var ig: String
    var photoUrl: String
    var photos: [String]
}

struct Service: Equatable {
    var name: String
    var price: Int
    
    static func == (lhs: Service, rhs: Service) -> Bool {
        return lhs.name == rhs.name &&
        lhs.price == rhs.price
    }
}
