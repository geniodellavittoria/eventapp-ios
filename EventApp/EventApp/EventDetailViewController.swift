//
//  EventDetailViewController.swift
//  EventApp
//
//  Created by Tim Bolzern on 19.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import CoreLocation

class EventDetailViewController: FormViewController {

    var category = ""
    let categoryOptions = ["Party","Concert","Standup-Comedy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        form +++
            
            ImageRow() { row in
                row.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
                row.clearAction = .yes(style: UIAlertAction.Style.destructive)
            }
            
            <<< TextRow("Title").cellSetup { cell, row in
                cell.textField.placeholder = row.tag
            }
            
            <<< TextRow("Location").cellSetup {
                $1.cell.textField.placeholder = $0.row.tag
            }
            
            <<< PushRow<String>() {
                $0.title = "Category"
                $0.value = category
                $0.options = categoryOptions
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.category = value
                    }
                }
            }
            
            +++
            Section()
            <<< DateTimeRow("Starts") {
                $0.title = $0.tag
                $0.value = Date().addingTimeInterval(60*60*24)
                }
            
            <<< DateTimeInlineRow("Ends"){
                $0.title = $0.tag
                $0.value = Date().addingTimeInterval(60*60*25)
                }
            <<< LocationRow(){
                $0.title = "LocationRow"
                $0.value = CLLocation(latitude: -34.91, longitude: -56.1646)
        }
        
    }
}




