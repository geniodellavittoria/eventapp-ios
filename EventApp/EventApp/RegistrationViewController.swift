//
//  RegistrationViewController.swift
//  EventApp
//
//  Created by Pascal on 17.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit
import Eureka
import Validator

class RegistrationViewController : FormViewController {
    
    let userController: UserController = UserController()
    
    // MARK: Validator Rules
    let stringRequiredRule = ValidationRuleRequired<String>(error: FormValidationError.requiredFieldError)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Section1")
            <<< TextRow(){
                $0.tag = "login"
                $0.title = "Username"
                $0.placeholder = "Enter text here"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< TextRow(){
                $0.tag = "firstName"
                $0.title = "First Name"
                $0.placeholder = "Enter text here"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< TextRow(){
                $0.tag = "lastName"
                $0.title = "Last Name"
                $0.placeholder = "Enter text here"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
        }
        form +++ Section("")
            <<< TextRow(){
                $0.tag = "email"
                $0.title = "Email"
                $0.placeholder = "Enter text here"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleEmail())
                $0.validationOptions = .validatesOnChangeAfterBlurred
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< PasswordRow(){
                $0.tag = "password"
                $0.title = "Password"
                $0.placeholder = "Enter text here"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 5))
                $0.validationOptions = .validatesOnChangeAfterBlurred
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< PasswordRow(){
                $0.tag = "confirmPassword"
                $0.title = "Confirm Password"
                $0.placeholder = "Enter text here"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 5))
                $0.validationOptions = .validatesOnChangeAfterBlurred
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
        }
        
    }
    
    @IBAction func RegisterUser(_ sender: UIBarButtonItem) {
        DictionaryEncoder.getModelFromDict(dict: form.values(), res: RegisterForm.self, onSuccess: { registerForm in
            if !(registerForm.password == registerForm.confirmPassword) {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Password is not the same", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            self.userController.register(registerForm: registerForm, completion: { success in
                if success {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Success", message: "Successfully registered", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Could not register user", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }, onError: { error in
            print(error)
        })
    }
    
    
    
}
