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
    var categoryOptions: [Category] = []
    
    let categoryController: CategoryController = CategoryController()
    
    var detailEvent = Event(name: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        form +++ Section("Infos")
            <<< ImageRow() {
                $0.title = "Event Image"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
                $0.clearAction = .yes(style: UIAlertAction.Style.destructive)
            }
            
            <<< TextRow("Title").cellSetup { cell, row in
                cell.textField.placeholder = row.tag
                }.onChange { row in
                    self.navigationItem.title = row.value
            }
            
            <<< TextRow("Location").cellSetup {
                $1.cell.textField.placeholder = $0.row.tag
            }
            
            <<< PushRow<String>() {
                $0.title = "Category"
                $0.value = category
                $0.options = categoryOptions.map({ $0.name })
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.category = value
                    }
                }
                    .cellUpdate { cell, row in
                        self.categoryController.getCategories(onSuccess: { categories in
                            self.categoryOptions = categories //.map({ EventDetailCategory(id: $0.id, value: $0.name) })
                            row.options = self.categoryOptions.map({ $0.name }).sorted()
                        }, onError: { error in
                            print(error)
                        })
                }
            }
            
            form +++ Section("Description")
            <<< TextAreaRow() {
                $0.tag = "description"
                $0.placeholder = "Description"
            }
            
            form +++ Section("Details")
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
    @IBAction func SaveEvent(_ sender: UIBarButtonItem) {
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}




