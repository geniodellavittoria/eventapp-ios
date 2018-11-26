//
//  LoginViewController.swift
//  EventApp
//
//  Created by Pascal on 17.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//


import UIKit
import Validator

class LoginViewController : UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var userController: UserController = UserController()
    
    // MARK: Validator Rules
    let stringRequiredRule = ValidationRuleRequired<String>(error: FormValidationError.requiredFieldError)
    let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: FormValidationError.invalidEmailError)
    let minLengthRule = ValidationRuleLength(min: 4, error: FormValidationError.tooShortTextError)
    
    var emailRules = ValidationRuleSet<String>()
    var passwordRules = ValidationRuleSet<String>()
    
    
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        emailTextField.text = "admin"
        passwordTextField.text = "admin"
        
        emailRules.add(rule: stringRequiredRule)
        //emailRules.add(rule: emailRule)
        emailTextField.validationRules = emailRules
        
        passwordRules.add(rule: stringRequiredRule)
        passwordRules.add(rule: minLengthRule)
        passwordTextField.validationRules = passwordRules
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func login(_ sender: UIButton) {
        if !emailTextField.validate().isValid {
            let alert = UIAlertController(title: "Error", message: "Field E-Mail cannot be empty", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if !passwordTextField.validate().isValid {
            let alert = UIAlertController(title: "Error", message: "Field Password cannot be empty", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        
        let loginForm = LoginForm(username: emailTextField.text!, password: passwordTextField.text!)
   
        
        userController.authenticate(loginForm: loginForm, completion: { (success) in
            print("loginviewcontroler")
            if !success {
                print("Login failed")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Could not login.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            
        })
        
    }
}
