//
//  SignUpViewController.swift
//  Apatite
//
//  Created by Amal Alqadhibi on 16/03/2018.
//  Copyright © 2018 Amal Alqadhibi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
// set the Bottm border of text field by add sub layer
extension UITextField {
    func setBorder() {
         self.backgroundColor = UIColor.clear
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 29, width: 800, height: 0.7)
        bottomLayer.backgroundColor = UIColor(red:0/255, green:222/255, blue: 215/255, alpha:1).cgColor
        self.layer.addSublayer(bottomLayer)
    }}
class SignUpViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reTypePassword : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Name.setBorder()
//        Email.setBorder()
//        Password.setBorder()
//        PhoneNum.setBorder()
//        Address1.setBorder()
//        Address2.setBorder()
//        City.setBorder()
//        
//        let cancelbutton = UIButton(type: .system)
//        cancelbutton.setImage(#imageLiteral(resourceName: "Cancel"), for: .normal)
//        cancelbutton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
//        navigationItem.rightBarButtonItem = UIBarButtonItem (customView: cancelbutton)
        
        
        // Do any additional setup after loading the view.
    }
    // hide the keyboard when user touch the view 
    @IBAction func cancelOnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func CreateAccountAction(_ sender: Any) {
      //   SVProgressHUD.show()
        if Email.text == "" || password.text != reTypePassword.text {
                let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
         else {
        Auth.auth().createUser(withEmail: Email.text!, password: password.text!, completion: { (user: User?, error: Error?) in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                print(error!.localizedDescription)
                return
            }
            else{
                let info = ["username": self.name.text! , "email": self.Email.text!]
                let uid = user?.uid
                let ref = Database.database().reference()
                 ref.child("users").child(uid!).setValue(info)
                 self.performSegue(withIdentifier: "ShowMainPage", sender: nil)
            }
        })}
        }
}
