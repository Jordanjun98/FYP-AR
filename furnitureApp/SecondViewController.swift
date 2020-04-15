//
//  SecondViewController.swift
//  furnitureApp
//
//  Created by Jordan on 06/01/2020.
//  Copyright © 2020 Jordan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class SecondViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var picker: UIImagePickerController? = UIImagePickerController()
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()

        //ref.child("soemid/name").setValue("jordan")
        //orderRef.child("order")
        self.hideKeyboardWhenTappedAround()
       
    }
    
       @IBOutlet weak var textFieldUsername: UITextField!
       
       
       @IBOutlet weak var textFieldEmail: UITextField!
       
       @IBOutlet weak var textFieldPhNo: UITextField!
       
       @IBOutlet weak var textFieldDetail: UITextView!
       
        @IBOutlet weak var imgView: UIImageView!
    
        @IBAction func buttonImage(_ sender: UIButton) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    
    

       @IBAction func buttonSubmit(_ sender: UIButton) {
        
        uploadImg()
       }
    
    func uploadImg(){
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("\(imageName).png")
       
        if let uploadData = imgView.image!.pngData(){
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in          
                if uploadData == nil{
                    print("pls add image")
                }
                var orderRef = Database.database().reference()
                var key = orderRef.childByAutoId().key
                let identifier = self.randomStringWithLength(len: 6)
                
                //var thirdViewController = ThirdViewController()
                var orderID = identifier as String
                
            
                storageRef.downloadURL { (url, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    if let imageUrl = url?.absoluteString {
                         let order = ["id": key,
                                     "order_name": self.textFieldUsername.text! as String,
                                     "email": self.textFieldEmail.text! as String,
                                     "ph_no": self.textFieldPhNo.text! as String,
                                     "detail": self.textFieldDetail.text! as String,
                                     "image":  imageUrl,
                                     "orderID": orderID
                        ]
                        orderRef.child("Customer/\(key!)").setValue(order)
                       
                    }
                }
            }
        }
    }
    
    func openGallery(){
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerController.SourceType.photoLibrary

    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imgView.image = img
        dismiss(animated: true) {
        }
    }
    
    func randomStringWithLength(len: Int) -> NSString {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

        let randomString : NSMutableString = NSMutableString(capacity: len)

        for _ in 1...len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }

        return randomString
    }
    

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
