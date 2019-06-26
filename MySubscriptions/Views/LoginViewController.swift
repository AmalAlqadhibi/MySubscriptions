//
//  LoginViewController.swift
//  Apatite
//
//  Created by Amal Alqadhibi on 17/03/2018.
//  Copyright © 2018 Amal Alqadhibi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    //Cancel button
    @IBAction func cancelOnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        let ref = Database.database().reference()
        //check if the textfield empty
        if self.Email.text == nil || self.Password.text == nil {
            //Alert to tell the user that there was an error
            
            let alertController = UIAlertController(title: "Oops!", message: "Please enter your Email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().signIn(withEmail: self.Email.text!, password: self.Password.text!) { (user, error) in
                if error == nil {
                    let uid = user?.uid
                    Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with:{(snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            self.performSegue(withIdentifier: "ShowHomePage", sender: nil)
                            print(dictionary)
                        }}, withCancel: nil)
                }
                else {
                    //Alert to Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    // hide the keyboard when user touch the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
