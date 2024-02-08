//
//  NewUserEntryRequest.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 04.06.2023.
//

import Foundation

struct NewUserEntryRequest: Equatable {
    var userID: String
    var masterID: String
    var date: String
    var time: String
    var service: Service
    
    static func == (lhs: NewUserEntryRequest, rhs: NewUserEntryRequest) -> Bool {
        return lhs.userID == rhs.userID &&
        lhs.masterID == rhs.masterID &&
        lhs.date == rhs.date &&
        lhs.time == rhs.time &&
        lhs.service == rhs.service
    }
}
