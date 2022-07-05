//
//  UserProfileViewController.swift
//  PicShare
//
//  Created by Roei Barkan on 05/07/2022.
//

import UIKit
import FirebaseFirestore

class UserProfileViewController: UIViewController {

    @IBOutlet var userNameInput: UILabel!
    @IBOutlet var phoneNumberInput: UILabel!
    @IBOutlet var emailInput: UILabel!
    
    let fireStore = Firestore.firestore()

    var userID: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()

    }
    
    
    func getData(){

        let docRef = fireStore.document("users/"+self.userID)
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            
            guard let name = data["fullName"] as? String else { return}
            guard let email = data["email"] as? String else { return}
            guard let phone = data["phoneNumber"] as? String else { return}
            
            
            self.userNameInput.text = name
            self.phoneNumberInput.text = phone
            self.emailInput.text = email
            
        }
    }

}
