//
//  FirstPageViewController.swift
//  MySubscriptions
//
//  Created by Amal Alqadhibi on 25/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import UIKit
import FirebaseAuth
class FirstPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
         if Auth.auth().currentUser?.uid != nil  {
            self.performSegue(withIdentifier: "HomeViewIdentifier", sender: self)
        }
    }
}
