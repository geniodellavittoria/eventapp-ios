//
//  SettingsController.swift
//  EventApp
//
//  Created by Pascal on 29.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit
import Eureka

class SettingsController: FormViewController {


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
        
    }

}
