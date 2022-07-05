//
//  MyProfileViewController.swift
//  PicShare
//
//  Created by Roei Barkan on 25/06/2022.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MyProfileViewController: UIViewController{
    
    @IBOutlet var phoneNumberInput: UILabel!
    @IBOutlet var fullName: UILabel!
    @IBOutlet var emailInput: UILabel!
    
    let fireStore = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()

    }
    
    @IBAction func homeButtonClicked(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "homeVC") as?
                HomeViewController else{
            return
        }
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
    func getData(){
       
        guard let userID = Auth.auth().currentUser?.uid else {return}

        let docRef = fireStore.document("users/"+userID)
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            
            guard let name = data["fullName"] as? String else { return}
            guard let email = data["email"] as? String else { return}
            guard let phone = data["phoneNumber"] as? String else { return}
            
            self.fullName.text = name
            self.phoneNumberInput.text = phone
            self.emailInput.text = email

            
        }
    }
    
}



