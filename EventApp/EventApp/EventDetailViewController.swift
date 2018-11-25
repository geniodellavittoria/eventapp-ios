//
//  EventDetailViewController.swift
//  EventApp
//
//  Created by Tim Bolzern on 19.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit
import Eureka

class EventDetailViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    }

}
