//
//  LoginViewController.swift
//  EventApp
//
//  Created by Pascal on 17.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//


import UIKit

class LoginViewController : UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func login(_ sender: UIButton) {
        
    }
}
