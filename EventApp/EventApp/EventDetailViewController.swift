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
    
    private let eventController = EventController()
    let categoryController: CategoryController = CategoryController()
    
    var detailEvent = Event(name: "")
    
    var viewMode = false
    var updateMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEvent))
        let registerBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerForEvent))
        
        if (isUserOwner()) {
            self.navigationItem.rightBarButtonItem = saveBarButtonItem
        } else if (viewMode) {
            self.navigationItem.rightBarButtonItem = registerBarButtonItem
        }
        
        print(detailEvent)
        
        // Do any additional setup after loading the view.
        
        form +++ Section("Infos")
            <<< ImageRow("eventImage") {
                $0.title = "Event Image"
                
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
                $0.clearAction = .yes(style: UIAlertAction.Style.destructive)
                }.cellSetup { cell, row in
                    row.value = Base64ImageHelper.getBase64DecodedImage(self.detailEvent.eventImage)
                    row.baseCell.isUserInteractionEnabled = self.isUserOwner()
            }
            
            <<< TextRow("name").cellSetup { cell, row in
                cell.textField.placeholder = row.tag
                row.value = self.detailEvent.name
                row.baseCell.isUserInteractionEnabled = self.isUserOwner()
                }.onChange { row in
                    self.navigationItem.title = row.value
            }
            
            /*<<< TextRow("Location").cellSetup {
             $1.cell.textField.placeholder = $0.row.tag
             }*/
            
            <<< PushRow<String>("categoryId") {
                $0.cellSetup { cell, row in
                    let category = self.detailEvent.category?.name
                    if (category != nil) {
                        row.value = category!
                    }
                }
                $0.title = "Category"
                $0.value = category
                $0.options = categoryOptions.map({ $0.name })
                $0.baseCell.isUserInteractionEnabled = self.isUserOwner()
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
            <<< TextAreaRow("description") {
                $0.tag = "description"
                $0.placeholder = "Description"
                $0.value = self.detailEvent.description
                $0.baseCell.isUserInteractionEnabled = self.isUserOwner()
        }
        
        form +++ Section("Details")
            <<< DateTimeRow("eventStart") {
                $0.title = "Start"
                $0.value = (self.detailEvent.eventStart ?? Date()).addingTimeInterval(60*60*24)
                $0.baseCell.isUserInteractionEnabled = self.isUserOwner()
            }
            
            <<< DateTimeInlineRow("eventEnd") {
                $0.title = "End"
                $0.value = (self.detailEvent.eventEnd ?? Date()).addingTimeInterval(60*60*25)
                $0.baseCell.isUserInteractionEnabled = self.isUserOwner()
            }
            <<< LocationRow("location").cellSetup { cell, row in
                row.title = "Location"
                row.value = CLLocation(latitude: self.detailEvent.locationLatitude ?? 0, longitude: self.detailEvent.locationLongitude ?? 0)
                row.baseCell.isUserInteractionEnabled = self.isUserOwner()
        }
        
    }
    
    private func isUserOwner() -> Bool {
        return authService.userId == detailEvent.userId || detailEvent.userId == nil;
    }
    
    @objc func registerForEvent(_ sender: Any) {
        var eventRegistration: EventRegistration = EventRegistration()
        eventRegistration.eventRegistrationId = 1 // to register
        eventRegistration.userId = authService.userId
        eventRegistration.timestamp = Date.init()
        
        eventController.registerEvent(eventId: detailEvent.id!, eventRegistration: eventRegistration, completion: { (success) in
            if (!success){
                print("could not register for the event")
            }
            else{
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
                
            }
        })
    }
    
    @objc func saveEvent(_ sender: Any) {
        var eventForm = self.form.values()
        var event = Event(name: eventForm["name"] as? String ?? "")
        if detailEvent.id != nil {
            event.id = detailEvent.id;
        }
        event.eventStart = eventForm["eventStart"] as? Date ?? nil
        event.eventEnd = eventForm["eventEnd"] as? Date ?? nil
        event.description = eventForm["description"] as? String ?? ""
        
        let location = eventForm["location"] as! CLLocation
        event.locationLatitude = location.coordinate.latitude
        event.locationLongitude = location.coordinate.longitude
        event.timestamp = Date()
        event.userId = authService.userId
        if let eventImage = eventForm["eventImage"] as? UIImage {
            event.eventImage = Base64ImageHelper.encodingImage(eventImage)
        }
        
        if updateMode {
            eventController.updateEvent(event: event, completion: { success in
                DispatchQueue.main.async {
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                    
                }
            })
        } else {
            eventController.createEvent(event: event, completion: { success in
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
            })
        }
        
    }
}




