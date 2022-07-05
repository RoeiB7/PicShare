//
//  SignUpController.swift
//  PicShare
//
//  Created by Roei Barkan on 23/06/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    @IBOutlet var fullNameInput: UITextField!
    @IBOutlet var phoneNumberInput: UITextField!
    @IBOutlet var emailInput: UITextField!
    @IBOutlet var passwordInput: UITextField!
    
    let fireStore = FirebaseFirestore.Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "signInVC") as?
                SignInViewController else{
            return
        }
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
    @IBAction func signUpButtonClicked(_ sender: UIButton) {
        guard let email = emailInput.text, !email.isEmpty,
              let password = passwordInput.text, !password.isEmpty,
              let fullName = fullNameInput.text, !fullName.isEmpty,
              let phoneNumber = phoneNumberInput.text, !phoneNumber.isEmpty else{
            print("Missing field data!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in guard let strongSelf = self else{
            return
        }
            
            guard error == nil else{
                strongSelf.showAlert()
                return
            }
            
            strongSelf.writeData(name: fullName, email: email, phone: phoneNumber)
            
            guard let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "homeVC") as?
                    HomeViewController else{
                return
            }
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            strongSelf.present(vc, animated: true)
            
        })
        
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Error", message: "account already found in system", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: {_ in
            
        }))
        
        present(alert, animated: true)
    }
    
    func writeData(name:String, email: String, phone:String){
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let docRef = fireStore.document("users/"+userID)
        docRef.setData(["fullName": name, "email": email, "phoneNumber": phone])
        
    }
}
