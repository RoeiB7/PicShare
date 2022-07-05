//
//  UploadImageViewController.swift
//  PicShare
//
//  Created by Roei Barkan on 24/06/2022.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class UploadImageViewController: UIViewController {
    
    @IBOutlet var selectGenreButton: UIButton!
    @IBOutlet var genreButtons: [UIButton]!
    @IBOutlet var imageView: UIImageView!
    
    var selectedGenre: String = ""
    
    var img: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func showButtonVisibility(){
        genreButtons.forEach{
            button in UIView.animate(withDuration: 0.3){
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func selectGenreButtonClicked(_ sender: UIButton) {
        showButtonVisibility()
        
    }
    
    //save selectedGenre variable in FB
    @IBAction func genreButtonClicked(_ sender: UIButton){
        showButtonVisibility()
        switch sender.currentTitle {
        case "Animals":
            selectGenreButton.setTitle("Animal", for: .normal)
            selectedGenre = "Animals"
        case "Other":
            selectGenreButton.setTitle("Other", for: .normal)
            selectedGenre = "Other"
        case "Food":
            selectGenreButton.setTitle("Food", for: .normal)
            selectedGenre = "Food"
        case "Sport":
            selectGenreButton.setTitle("Sport", for: .normal)
            selectedGenre = "Sport"
        default:
            selectGenreButton.setTitle("Select Genre", for: .normal)
        }
    }
    
    @IBAction func pickImageButtonClicked(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func uploadButtonClicked(_ sender: UIButton) {
        uploadPhoto()
    }
    
    @IBAction func homeButtonClicked(_ sender: UIButton) {
        moveToHome()
    }
    
    func uploadPhoto(){
        
        guard img != nil else{
            print("img is nil")
            return
        }
        
        let storageRef = Storage.storage().reference()
        
        let imageData = img!.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            print("imageData is nil")
            return
        }
        
        let path = "images/"+selectedGenre+"/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        
        fileRef.putData(imageData!) { metadata, error in
            if error == nil && metadata != nil {
                self.uploadImageToFirestore(path: path, genre: self.selectedGenre)
                self.showAlert(message: "Image uploaded successfully!", isSuccess: true)
            }
            self.showAlert(message: "Failed to upload image!", isSuccess: false)
            
            
        }
    }
    
    func showAlert(message:String, isSuccess:Bool){
        let alert = UIAlertController(title: "Upload Image", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: {_ in
            if(isSuccess){
                self.moveToHome()
            }
        }))
        
        present(alert, animated: true)
    }
    
    func moveToHome(){
        selectGenreButton.isHidden = true
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "homeVC") as?
                HomeViewController else{
            return
        }
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
        
    }
    
    func uploadImageToFirestore(path: String, genre: String){
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        let docRef = db.document("users/"+userID+"/"+genre+"/myImages")
        
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                db.document("users/"+userID)
                    .collection(genre)
                    .document("myImages")
                    .setData(["urls": [path]])
                return
            }
            
            guard var imgs = data["urls"] as? [String] else { return}
            imgs.append(path)
            db.document("users/"+userID)
                .collection(genre)
                .document("myImages")
                .setData(["urls": imgs])
            
        }
                
    }
    
}

extension UploadImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]
            as? UIImage {
            imageView.image = image
            img = image
            selectGenreButton.isHidden = false
        }
        picker.dismiss(animated: true,completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
    
}

