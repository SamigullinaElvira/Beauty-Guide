//
//  UserInfoEditView.swift
//  BeautyGuide
//
//  Created by Элина Абдрахманова on 10.05.2023.
//

import UIKit
import Firebase
import SafariServices

class UserInfoEditView: UIView {
    
    let db = Firestore.firestore()
    
    private let editLabel = UILabel(text: "Режим редактирования",
                                    font: UIFont.systemFont(ofSize: 16, weight: .medium),
                                    textColor: .black)
    
    private lazy var editSwitchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(editSwitchValueChanged(_:)), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private lazy var infoUserTextField = CustomTextField(fieldType: .infoUser)
    private lazy var infoUserNumberTextField = CustomTextField(fieldType: .infoNumber)
    private lazy var infoUserContactsTextField = CustomTextField(fieldType: .infoContats)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setConstraints()
        
        loadDataFromFirestore()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .none
        translatesAutoresizingMaskIntoConstraints = false
        
        infoUserTextField.isEnabled = false
        infoUserNumberTextField.isEnabled = false
        infoUserContactsTextField.isEnabled = false
        
        addSubview(editLabel)
        addSubview(editSwitchControl)
        addSubview(infoUserTextField)
        addSubview(infoUserNumberTextField)
        addSubview(infoUserContactsTextField)
    }
    
    @objc private func editSwitchValueChanged(_ sender: UISwitch) {
        infoUserTextField.isEnabled = sender.isOn
        infoUserNumberTextField.isEnabled = sender.isOn
        infoUserContactsTextField.isEnabled = sender.isOn
        
        if sender.isOn == true || sender.isOn == false {
            saveChangesToFirebase()
        }
    }
    
    private func saveChangesToFirebase() {
        guard let userID = Auth.auth().currentUser?.uid,
              let infoUserText = infoUserTextField.text,
              let infoUserNumberText = infoUserNumberTextField.text,
              let infoUserContactsText = infoUserContactsTextField.text else {
            return
        }
        
        let data: [String: Any] = [
            "infoUser": infoUserText,
            "infoUserNumber": infoUserNumberText,
            "infoUserContacts": infoUserContactsText
        ]
        
        let userRef = db.collection("users").document(userID)
        let infoCollectionRef = userRef.collection("info")
        
        infoCollectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            for document in snapshot.documents {
                infoCollectionRef.document(document.documentID).delete { error in
                    if let error = error {
                        print("Error deleting document: \(error.localizedDescription)")
                    }
                }
            }
            
            infoCollectionRef.addDocument(data: data) { [weak self] error in
                if let error = error {
                    print("Error saving changes to Firestore: \(error.localizedDescription)")
                } else {
                    print("Changes saved successfully to Firestore")
                    // Загрузка данных в текстовые поля после сохранения изменений
                    self?.loadDataFromFirestore()
                }
            }
        }
    }
    
    private func loadDataFromFirestore() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userRef = db.collection("users").document(userID)
        let infoCollectionRef = userRef.collection("info")
        
        infoCollectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            if let document = snapshot.documents.first {
                let data = document.data()
                
                DispatchQueue.main.async {
                    self?.infoUserTextField.text = data["infoUser"] as? String
                    self?.infoUserNumberTextField.text = data["infoUserNumber"] as? String
                    self?.infoUserContactsTextField.text = data["infoUserContacts"] as? String
                }
            }
        }
    }

}

extension UserInfoEditView {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            editLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            editLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            editLabel.trailingAnchor.constraint(equalTo: editSwitchControl.leadingAnchor, constant: -10),
            
            editSwitchControl.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            editSwitchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            infoUserTextField.topAnchor.constraint(equalTo: editLabel.bottomAnchor, constant: 30),
            infoUserTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoUserTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            infoUserNumberTextField.topAnchor.constraint(equalTo: infoUserTextField.bottomAnchor, constant: 20),
            infoUserNumberTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoUserNumberTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            infoUserContactsTextField.topAnchor.constraint(equalTo: infoUserNumberTextField.bottomAnchor, constant: 20),
            infoUserContactsTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoUserContactsTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
}

