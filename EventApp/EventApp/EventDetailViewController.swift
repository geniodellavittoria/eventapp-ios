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

protocol EventChangedDelegate: class {
    func eventChanged(event: Event?)
}

class EventDetailViewController: FormViewController, UIActionSheetDelegate {
    weak var delegate: EventChangedDelegate?
    
    let formatter = DateFormatter()
    var category = ""
    var categoryOptions: [Category] = []
    
    private let eventController = EventController()
    let categoryController: CategoryController = CategoryController()
    
    var detailEvent = Event(name: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEvent))
        let registerBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerForEvent))
        let unregisterBarButtonItem = UIBarButtonItem(title: "Unregister", style: .plain, target: self, action: #selector(unregisterActionSheet))
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        if isUserOwner() {
            self.navigationItem.rightBarButtonItem = saveBarButtonItem
        } else {
            if isUserRegistered() {
                self.navigationItem.rightBarButtonItem = unregisterBarButtonItem
            } else {
                self.navigationItem.rightBarButtonItem = registerBarButtonItem
            }
        }
        
        form +++ Section("General")
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
                row.title = "Name"
                row.placeholder = "Name"
                row.add(rule: RuleRequired())
                row.value = self.detailEvent.name
                row.baseCell.isUserInteractionEnabled = self.isUserOwner()
                }.cellUpdate { cell, row in
                    self.navigationItem.title = row.value
                    FormValidation.validateField(cell: cell, row: row)
            }
            
            <<< PushRow<Category>("categoryId") {
                $0.title = "Category"
                $0.value = detailEvent.category
                $0.options = categoryOptions
                $0.add(rule: RuleRequired())
                $0.displayValueFor = {
                    guard let category = $0 else { return nil }
                    return category.name
                }
                $0.baseCell.isUserInteractionEnabled = self.isUserOwner()
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.category = value.name
                    }
                    }
                    .cellUpdate { cell, row in
                        self.categoryController.getCategories(onSuccess: { categories in
                            self.categoryOptions = categories //.map({ EventDetailCategory(id: $0.id, value: $0.name) })
                            row.options = self.categoryOptions.sorted(by: { $0.name > $1.name })
                        }, onError: { error in
                            print(error)
                        })
                        
                    }.onPresent { form, selectorController in
                        selectorController.enableDeselection = false
                }
        }
        
        form +++ Section("Description")
            <<< TextAreaRow("description").cellSetup { cell, row in
                row.tag = "description"
                row.placeholder = "Description"
                row.baseCell.isUserInteractionEnabled = self.isUserOwner()
                row.value = self.detailEvent.description
                }.cellUpdate { cell, row in
                    //FormValidation.validateField(cell: cell, row: row)
        }
        
        form +++ Section("Details")
            <<< DateTimeRow("eventStart") {
                $0.title = "Start"
                $0.add(rule: RuleRequired())
                $0.value = (self.detailEvent.eventStart ?? Date()).addingTimeInterval(60*60*24)
                $0.baseCell.isUserInteractionEnabled = self.isUserOwner()
                }.cellUpdate { (cell, row) in
                    row.minimumDate = Date()
            }
            
            <<< DateTimeInlineRow("eventEnd") {
                $0.title = "End"
                $0.add(rule: RuleRequired())
                $0.value = (self.detailEvent.eventEnd ?? Date()).addingTimeInterval(60*60*25)
                $0.baseCell.isUserInteractionEnabled = self.isUserOwner()
                }.cellUpdate { (cell, row) in
                    row.minimumDate = Date()
            }
            <<< LocationRow("location").cellSetup { cell, row in
                row.title = "Location"
                row.value = CLLocation(latitude: self.detailEvent.locationLatitude ?? 0, longitude: self.detailEvent.locationLongitude ?? 0)
                row.baseCell.isUserInteractionEnabled = self.isUserOwner()
            }
            <<< DecimalRow("price").cellSetup { cell, row in
                cell.textField.placeholder = "Price"
                row.title = "Price"
                row.value = self.detailEvent.price ?? 0
                row.baseCell.isUserInteractionEnabled = self.isUserOwner()
            }
            <<< SwitchRow("placeSwitch") {
                $0.title = "Limit place"
                $0.value = self.isUserOwner() && (self.detailEvent.place ?? 0) > 0
                $0.baseCell.isUserInteractionEnabled = self.isUserOwner()
                $0.hidden = Condition.function(["placeSwitch"], { form in
                    return !self.isUserOwner()
                })
            }
            <<< IntRow("place") {
                $0.hidden = Condition.function(["placeSwitch"], { form in
                    return !((form.rowBy(tag: "placeSwitch") as? SwitchRow)?.value ?? true)
                })
                }.cellSetup { cell, row in
                    cell.textField.placeholder = "Place"
                    row.title = "Place"
                    row.value = self.detailEvent.place
                    row.baseCell.isUserInteractionEnabled = self.isUserOwner()
        }
            <<< IntRow("freePlace") {
                $0.hidden = Condition.function(["placeSwitch"], { form in
                    return (!((form.rowBy(tag: "placeSwitch") as? SwitchRow)?.value ?? true) && self.detailEvent.freePlace == nil) && self.isUserOwner()
                })
                }.cellSetup { cell, row in
                    row.title = "Free Place"
                    row.value = self.detailEvent.freePlace
                    row.baseCell.isUserInteractionEnabled = false
        }
    }
    
    private func isUserOwner() -> Bool {
        return authService.userId == detailEvent.userId || detailEvent.userId == nil;
    }
    
    private func isUserRegistered() -> Bool {
        return detailEvent.eventRegistrations?.contains(where: { $0.userId == authService.userId }) ?? false
    }
    
    private func isEdited() -> Bool {
        return detailEvent.id != nil
    }
    
    @objc func registerForEvent(_ sender: Any) {
        var eventRegistration: EventRegistration = EventRegistration()
        eventRegistration.eventRegistrationId = 1 // to register
        eventRegistration.userId = authService.userId
        eventRegistration.timestamp = Date.init()
        
        eventController.registerEvent(eventId: detailEvent.id!, eventRegistration: eventRegistration, onSuccess: { registration in
            self.reduceFreePlace()
            var event = self.detailEvent
            event.eventRegistrations?.append(registration)
            self.delegate?.eventChanged(event: event)
            self.performSegue(withIdentifier: "unwindEventDetailSegue", sender: self)
            
        }, onError: { error in
            print(error)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Could not register for event.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @objc func unregisterActionSheet() {
        let unregisterAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        let unregisterActionButton = UIAlertAction(title: "Unregister", style: .default) { _ in
            self.unregisterFromEvent()
        }
        
        unregisterAlertController.addAction(cancelActionButton)
        unregisterAlertController.addAction(unregisterActionButton)
        
        self.present(unregisterAlertController, animated: true, completion: nil)
    }
    
    @objc func unregisterFromEvent() {
        eventController.unregisterEvent(eventId: detailEvent.id!, completion: { success in
            if success {
                self.incrementFreePlace()
                self.detailEvent.eventRegistrations?.removeAll(where: { $0.userId == authService.userId })
                self.delegate?.eventChanged(event: self.detailEvent)
                self.performSegue(withIdentifier: "unwindEventDetailSegue", sender: self)
            } else {
                print("Could not unregister from event")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Could not unregister from event.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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
        event.category = eventForm["categoryId"] as? Category ?? nil
        event.price = eventForm["price"] as? Double ?? 0
        if let placeSwitch = eventForm["placeSwitch"] as? Bool {
            if placeSwitch {
                event.place = eventForm["place"] as? Int ?? 0
                if event.freePlace == nil {
                    event.freePlace = event.place
                }
            } else {
                event.place = 0
                event.freePlace = nil
            }
        }
        event.timestamp = Date()
        event.userId = authService.userId
        
        if let eventImage = eventForm["eventImage"] as? UIImage {
            event.eventImage = Base64ImageHelper.encodingImage(eventImage)
        }
        
        detailEvent = event
        
        if isEdited() {
            updateEvent(event)
        } else {
            createEvent(event)
        }
    }
    
    func updateEvent(_ event: Event) {
        eventController.updateEvent(event: event, completion: { success in
            if success {
                self.delegate?.eventChanged(event: self.detailEvent)
                self.performSegue(withIdentifier: "unwindEventDetailSegue", sender: self)
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Could not update event.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func createEvent(_ event: Event) {
        eventController.createEvent(event: event, onSuccess: { event in
            self.delegate?.eventChanged(event: event)
            self.performSegue(withIdentifier: "unwindEventDetailSegue", sender: self)
            
        }, onError: { error in
            print(error)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Could not create event.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func reduceFreePlace() {
        if detailEvent.freePlace != nil {
            detailEvent.freePlace! -= 1
        }
    }
    
    func incrementFreePlace() {
        if detailEvent.freePlace != nil {
            detailEvent.freePlace! += 1
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}




