//
//  SearchImageViewController.swift
//  PicShare
//
//  Created by Roei Barkan on 03/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SearchImageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var selectGenreButton: UIButton!
    @IBOutlet var genreButtons: [UIButton]!
    @IBOutlet var imageTableView: UITableView!
    
    var selectedGenre: String = ""
    
    struct imageData{
        let userID: String
        let genre: String
        let image: UIImage
    }
    
    var data: [imageData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTableView.dataSource = self
        imageTableView.delegate = self
        
        
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
    
    @IBAction func genreButtonClicked(_ sender: UIButton){
        showButtonVisibility()
        switch sender.currentTitle {
        case "Animals":
            selectGenreButton.setTitle("Animals", for: .normal)
            selectedGenre = "Animals"
            imageTableView.isHidden = false
            retrieveImages()
        case "Other":
            selectGenreButton.setTitle("Other", for: .normal)
            selectedGenre = "Other"
            imageTableView.isHidden = false
            retrieveImages()
        case "Food":
            selectGenreButton.setTitle("Food", for: .normal)
            selectedGenre = "Food"
            imageTableView.isHidden = false
            retrieveImages()
        case "Sport":
            selectGenreButton.setTitle("Sport", for: .normal)
            selectedGenre = "Sport"
            imageTableView.isHidden = false
            retrieveImages()
        default:
            selectGenreButton.setTitle("Select Genre", for: .normal)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = imageTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let imgData = data[indexPath.row]
        cell.iconImageView.image = imgData.image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let imgData = data[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "userProfileVC") as!
                UserProfileViewController
        vc.userID = imgData.userID
        present(vc, animated: true)
        
    }
        
    func retrieveImages(){
        self.data.removeAll()
        self.imageTableView.reloadData()
        let db = Firestore.firestore()
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let docRef = db.document("users/"+document.documentID+"/"+self.selectedGenre+"/myImages")
                    
                    docRef.getDocument { snapshot, error in
                        guard let data = snapshot?.data(), error == nil else {
                            return
                        }
                        guard let imgsUrls = data["urls"] as? [String] else { return}
                        for imgUrl in imgsUrls {
                            let storageRef = Storage.storage().reference()
                            let fileRef = storageRef.child(imgUrl)
                            
                            fileRef.getData(maxSize: 5*1024*1024) { storageData, error in
                                if error == nil && storageData != nil{
                                    if let imageObj = UIImage(data: storageData!){
                                        self.data.append(imageData(userID: document.documentID, genre: self.selectedGenre, image: imageObj))
                                        
                                        self.imageTableView.reloadData()

                                    }
                                    
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
    }
}
