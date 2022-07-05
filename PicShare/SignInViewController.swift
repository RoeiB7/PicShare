//
//  ViewController.swift
//  PicShare
//
//  Created by Roei Barkan on 23/06/2022.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet var emailInput: UITextField!
    @IBOutlet var passwordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpButtonClicked(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "signUpVC") as?
                SignUpViewController else{
            return
        }
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        guard let email = emailInput.text, !email.isEmpty,
              let password = passwordInput.text, !password.isEmpty else{
            print("Missing field data!")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion:{[weak self] result, error in guard let strongSelf = self else{
                return
            }
            
            guard error == nil else{
                strongSelf.showAlert()
                return
            }
            
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
        let alert = UIAlertController(title: "Error", message: "No account found in system", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: {_ in
            
        }))
        
        present(alert, animated: true)
    }
    
}

