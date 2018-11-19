//
//  RegistrationViewController.swift
//  EventApp
//
//  Created by Pascal on 17.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit
import Eureka

class RegistrationViewController : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Section1")
            <<< TextRow(){ row in
                row.title = "Username"
                row.placeholder = "Enter text here"
            }
            <<< TextRow(){ row in
                row.title = "First Name"
                row.placeholder = "Enter text here"
            }
            <<< TextRow(){ row in
                row.title = "Last Name"
                row.placeholder = "Enter text here"
        
        }
        form +++ Section("")
            <<< TextRow(){ row in
                row.title = "Email"
                row.placeholder = "Enter text here"
                
            }
            <<< TextRow(){ row in
                row.title = "Password"
                row.placeholder = "Enter text here"
            }
            <<< TextRow(){ row in
                row.title = "Confirm Password"
                row.placeholder = "Enter text here"
            }

    }
}
