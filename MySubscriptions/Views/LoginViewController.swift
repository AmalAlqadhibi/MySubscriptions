//
//  LoginViewController.swift
//  MySubscriptions
//
//  Created by Amal Alqadhibi on 22/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Password.setBorder()
        Email.setBorder()
        if UserDefaults.standard.value(forKey: "UserEmail") != nil {
            self.Email.text = UserDefaults.standard.value(forKey: "UserEmail") as! String
        }
    }
    //Cancel button
    @IBAction func cancelOnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.activityIndicator.startAnimating()
        UserDefaults.standard.set(self.Email.text, forKey: "UserEmail")
        let ref = Database.database().reference()
        //check if the textfield empty
        if self.Email.text == nil || self.Password.text == nil {
            self.activityIndicator.stopAnimating()
            //Alert to tell the user that there was an error
            alert(title: "Oops!", message: "Please enter your Email and password.")
        } else {
            Auth.auth().signIn(withEmail: self.Email.text!, password: self.Password.text!) { (user, error) in
                if error == nil {
                    let uid = user?.uid
                    Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with:{(snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            self.performSegue(withIdentifier: "ShowHomePage", sender: nil)
                        }}, withCancel: nil)
                }
                else {
                    self.activityIndicator.stopAnimating()
                    //Alert to Tells the user that there is an error
                    self.alert(title: "Oops!", message: error?.localizedDescription)
                }
            }
        }
        activityIndicator.stopAnimating()
    }
    // hide the keyboard when user touch the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
// add Underline in UITextField
extension UITextField {
    func setBorder() {
        self.backgroundColor = UIColor.clear
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 29, width: 800, height: 0.7)
        bottomLayer.backgroundColor = UIColor(red:158/255, green:12/255, blue: 57/255, alpha:1).cgColor
        self.layer.addSublayer(bottomLayer)
    }}
