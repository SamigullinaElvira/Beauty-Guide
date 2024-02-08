//
//  File.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 05.06.2023.
//

import Foundation
import Firebase

public func uploadData() {
    let db = Firestore.firestore()

    let mastersRef = db.collection("masters")
    let masterRef = mastersRef.document("mozhno.studio")

    // master data
    masterRef.setData([
        "name": "Салон красоты Конечно Можно",
        "unique_name": "mozhno.studio",
        "category": "Стрижка/Окрашивание",
        "city":  "Казань",
        "address": "Николая Столбова, 1/3",
        "description": "Уютное бьюти пространство",
        "phone": "79270393343",
        "WhatsApp": "https://wa.me/79270393343",
        "ig": "https://www.instagram.com/mozhno.studio",
        "photoURL": ""
        ])
    
    // services data
    let servicesRef = masterRef.collection("services")

    let services = [
        ["name": "Стрижка челки", "price": 700],
        ["name": "Стрижка с укладкой (выше плеч)", "price": 2000],
        ["name": "Стрижка с укладкой (ниже плеч)", "price": 2500],
        ["name": "Стрижка со сложной укладкой (выше плеч)", "price": 3000],
        ["name": "Стрижка со сложной укладкой (ниже плеч)", "price": 3500],
        ["name": "Детская стрижка", "price": 1000],
        ["name": "Прямой срез", "price": 1000],
        ["name": "Окрашивание корней", "price": 4000],
        ["name": "Окрашивание в один тон", "price": 6200],
        ["name": "Тонирование", "price": 4500],
        ["name": "Осветление корней + тонирование", "price": 5000],
        ["name": "Окрашивание корней + тонирование", "price": 5500],
        ["name": "Сложное окрашивание", "price": 8500],
    ]
    
    for service in services {
        servicesRef.addDocument(data: service)
    }
    
    // free time data
    let freeTimeRef = masterRef.collection("freeTime")
    
    let documents = [
        ["date": "07-06-23", "time": "8:00"],
        ["date": "07-06-23", "time": "9:00"],
        ["date": "07-06-23", "time": "10:00"],
        ["date": "07-06-23", "time": "11:00"],
        ["date": "07-06-23", "time": "12:00"],
        ["date": "07-06-23", "time": "13:00"],
        ["date": "07-06-23", "time": "14:00"],
        ["date": "07-06-23", "time": "15:00"],
        ["date": "07-06-23", "time": "16:00"],
        ["date": "07-06-23", "time": "17:00"],
        ["date": "07-06-23", "time": "18:00"],
    ]
    
    for document in documents {
        freeTimeRef.addDocument(data: document)
    }
}
