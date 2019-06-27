//
//  SignUpViewController.swift
//  MySubscriptions
//
//  Created by Amal Alqadhibi on 22/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
class SignUpViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reTypePassword : UITextField!
    @IBOutlet weak var activeityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.setBorder()
        Email.setBorder()
        password.setBorder()
        reTypePassword.setBorder()
    }
    
    @IBAction func cancelOnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // hide the keyboard when user touch the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func CreateAccountAction(_ sender: Any) {
        self.activeityIndicator.startAnimating()
        if Email.text == "" || password.text != reTypePassword.text {
            self.activeityIndicator.stopAnimating()
            alert(title: "Oops", message: "Please enter your email and password")
        }
        else {
            Auth.auth().createUser(withEmail: Email.text!, password: password.text!, completion: { (user: User?, error: Error?) in
                if error != nil {
                    self.activeityIndicator.stopAnimating()
                    self.alert(title: "Oops!", message: error?.localizedDescription)
                    return
                }
                else{
                    let info = ["username": self.name.text! , "email": self.Email.text!]
                    let uid = user?.uid
                    let ref = Database.database().reference()
                    ref.child("users").child(uid!).setValue(info)
                    self.activeityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "ShowMainPage", sender: nil)
                }
            })}
    }
}

