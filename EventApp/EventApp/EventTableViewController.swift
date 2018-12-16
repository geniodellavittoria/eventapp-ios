//
//  EventTableViewController.swift
//  EventApp
//
//  Created by Pascal on 17.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

//UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating
class EventTableViewController : UITableViewController,
UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, EventChangedDelegate {
    
    @IBOutlet weak var searchFooter: UISearchBar!
    
    var detailViewController: EventDetailViewController? = nil
    var filteredEventList = [Event]()
    var eventList = [Event]()
    
    private let eventController = EventController()
    private let eventRegistrationController = EventRegistrationController()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    let formatter = DateFormatter()
    let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.startTracking()     
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        
        tableView.delegate = self
        self.tableView.rowHeight = 115.0;
        
        eventController.getEvents(onSuccess: { events in
            self.eventList = events
            self.filteredEventList = events
            self.getAllEvents()
            self.tableView.reloadData()
        }, onError: { error in
            print("could not load any events")
        })
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            navigationItem.searchController = searchController
            
            // Make the search bar always visible.
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            tableView.tableHeaderView = searchController.searchBar
        }
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        
        navigationItem.searchController = searchController
        
        // scope bar
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = ["All", "Nearest", "Closest"]
        
        tableView.tableFooterView = searchFooter
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false // The default is true.
        //searchController.searchBar.delegate = self // Monitor when the search button is tapped.
        
        /** Search presents a view controller by applying normal view controller presentation semantics.
         This means that the presentation moves up the view controller hierarchy until it finds the root
         view controller or one that defines a presentation context.
         */
        
        /** Specify that this view controller determines how the search controller is presented.
         The search controller should be presented modally and match the physical size of this view controller.
         */
        definesPresentationContext = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! EventDetailViewController
                controller.detailEvent = filteredEventList[indexPath.row]
                controller.delegate = self
            }
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier:"showDetail" , sender: cell)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
        if (!filteredEventList.isEmpty) {
            let event = filteredEventList[indexPath.row]
            cell.eventImage?.image = Base64ImageHelper.getBase64DecodedImage(event.eventImage)
            cell.eventTitleLbl?.text = event.name
            cell.eventCategoryLbl?.text  = event.category?.name
            cell.eventTimeFromLbl.text = self.formatter.string(from: event.eventStart!)
            cell.eventTimeToLbl.text = self.formatter.string(from: event.eventEnd!)
            
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            if let formattedPrice = event.price as? NSNumber {
                cell.eventPriceLbl?.text = formatter.string(from: formattedPrice)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredEventList.count
        }
        return eventList.count
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        let event = filteredEventList[indexPath.row]
        let tagged = event.eventRegistrations?.contains(where: { $0.userId == authService.userId }) ?? false
        
        if authService.userId == event.userId {
            let deleteTitle = NSLocalizedString("Delete", comment: "Delete")
            let deleteAction = UITableViewRowAction(style: .destructive, title: deleteTitle, handler: { (action, indexPath) in
                self.deleteEvent(indexPath: indexPath)
            })
            actions.append(deleteAction)
        }
        if (tagged) {
            let taggingTitle = NSLocalizedString("Unfavorite", comment: "Unfavorite action")
            let taggingAction = UITableViewRowAction(style: .normal, title: taggingTitle) { (action, indexPath) in
                self.untagEvent(indexPath: indexPath)
            }
            taggingAction.backgroundColor = .blue
            actions.append(taggingAction)
        } else {
            let taggingTitle = NSLocalizedString("Favorite", comment: "Favorite action")
            let taggingAction = UITableViewRowAction(style: .normal, title: taggingTitle) { (action, indexPath) in
                self.tagEvent(indexPath: indexPath)
            }
            taggingAction.backgroundColor = .green
            actions.append(taggingAction)
        }
        return actions
        
    }
    
    
    // MARK: - Search bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !(searchBar.text?.isEmpty ?? false) else {
            filteredEventList = eventList
            tableView.reloadData()
            return
        }
        filteredEventList = eventList.filter { event in
            let eventDescription = event.description?.lowercased() ?? ""
            let eventCategory = event.category?.name.lowercased() ?? ""
            let eventString = event.name.lowercased() + " " + eventDescription + " " + eventCategory
            let isMatchingSearchText = eventString.contains(searchText.lowercased()) || searchText.count == 0
            return isMatchingSearchText
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if (selectedScope == 0) {
            getAllEvents()
        } else if (selectedScope == 1) {
            getNearestEvents()
        } else if (selectedScope == 2) {
            getClosestEvents()
        }
        tableView.reloadData()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredEventList = eventList.filter({ (event: Event) -> Bool in
            let doesCategoryMatch = (scope == "All") || (event.category?.name == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && event.name.lowercased().contains(searchText.lowercased())
            }
        })
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Update the filtered array based on the search text.
        let searchResults = eventList
        
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    func configureSearchController() {
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - Custom functions
    
    
    
    func getAllEvents() {
        filteredEventList.sort(by: { $0.name < $1.name })
    }
    
    func getClosestEvents() {
        filteredEventList.sort(by: {
            if ($0.eventStart == nil) {
                return false
            }
            if ($1.eventStart == nil) {
                return true
            }
            return $0.eventStart!.compare($1.eventStart!) == .orderedAscending
            
        })
    }
    
    func getNearestEvents() {
        filteredEventList.sort(by: {
            if ($0.locationLatitude == nil && $0.locationLongitude == nil) {
                return false
            }
            if($1.locationLatitude == nil && $1.locationLongitude == nil){
                return true
            }
            let location0 = CLLocation(latitude: $0.locationLatitude!, longitude: $0.locationLongitude!)
            let location1 = CLLocation(latitude: $1.locationLatitude!, longitude: $1.locationLongitude!)
            let distance0 = getDistanceToCurrentLocation(location: location0)
            let distance1 = getDistanceToCurrentLocation(location: location1)
            return distance0.isLessThanOrEqualTo(distance1) == false
        })
    }
    
    func getDistanceToCurrentLocation (location: CLLocation ) -> (Double){
        return locationManager.getDistanceInMeters(coordinate1: locationManager.currentLocation, coordinate2: location)
    }
    
    func tagEvent(indexPath: IndexPath) {
        var event = filteredEventList[indexPath.row]
        if (event.id != nil) {
            var eventRegistration = EventRegistration()
            eventRegistration.eventRegistrationId = 2
            eventRegistration.timestamp = Date()
            eventRegistration.userId = authService.userId
            eventController.registerEvent(eventId: event.id!, eventRegistration: eventRegistration, onSuccess: { registration in
                event.eventRegistrations?.append(eventRegistration)
                self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }, onError: { error in
                print(error)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Could not tag event.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func untagEvent(indexPath: IndexPath) {
        var event = filteredEventList[indexPath.row]
        if event.id != nil {
            eventController.unregisterEvent(eventId: event.id!, completion: { (success) in
                if success {
                    event.eventRegistrations?.removeAll(where: { $0.userId == authService.userId })
                    self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                } else {
                    print("Could not unregister for event")
                    
                }
            })
            
        }
    }
    
    func deleteEvent(indexPath: IndexPath) {
        let event = filteredEventList[indexPath.row]
        if event.id != nil {
            eventController.deleteEvent(eventId: event.id!, completion: { success in
                if success {
                    self.filteredEventList.removeAll(where: { $0.id == event.id })
                    self.eventList.removeAll(where: { $0.id == event.id })
                } else {
                    print("Could not delete event" + String(event.id!))
                }
            })
        }
    }
    
    func eventChanged(event: Event?) {
        if event != nil {
            if let index = eventList.firstIndex(where: { $0.id == event!.id }) {
                eventList[index] = event!
                let filterIndex = filteredEventList.firstIndex(where: { $0.id == event!.id })
                if filterIndex != nil {
                    filteredEventList[filterIndex!] = event!
                }
            } else {
                eventList.append(event!)
            }
            
            self.tableView.reloadData()
            
        }
    }
    
    @IBAction func unwindToEventTableView(_ sender: UIStoryboardSegue) {
        
    }
    
    
}


