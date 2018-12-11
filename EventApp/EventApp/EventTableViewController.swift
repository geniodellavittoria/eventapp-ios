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
UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating{
    @IBOutlet weak var searchFooter: UISearchBar!
    
    var detailViewController: EventDetailViewController? = nil
    private var filteredEventList = [Event]()
    private var eventList = [Event]()
    
    private let eventController = EventController()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    let formatter = DateFormatter()
    let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.startTracking()     
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        
        tableView.delegate = self
        
        eventController.getEvents(onSuccess: { events in
            self.eventList = events
            self.filteredEventList = events
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
        
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = EventDetailViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if splitViewController!.isCollapsed {
            if let selectionIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectionIndexPath, animated: animated)
            }
        }
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Split View
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                print("indexPath " + String(indexPath.item))
                //let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! EventDetailViewController
                controller.detailEvent = filteredEventList[indexPath.item]
                controller.viewMode = true
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
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
            cell.eventImage?.image = getBase64DecodedImage(event.eventImage)
            cell.eventTitleLbl?.text = event.name
            cell.eventCategoryLbl?.text  = event.category?.name
            cell.eventTimeFromLbl.text = self.formatter.string(from: event.eventStart!)
            cell.eventTimeToLbl.text = self.formatter.string(from: event.eventEnd!)
            
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            if let formattedPrice = formatter.string(from: event.price! as NSNumber)
            {
                cell.eventPriceLbl?.text = formattedPrice
            }
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredEventList.count
        }
        return eventList.count
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
    
    func getBase64DecodedImage(_ data: String?) -> UIImage {
        if (data == nil) {
            return UIImage()
        }
        let decodedData = Data(base64Encoded: data!, options: NSData.Base64DecodingOptions(rawValue: 0))
        
        if (decodedData != nil) {
            return UIImage(data: decodedData!)!
        }
        return UIImage()
    }
    
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
        var nearEvents: [Event] = []
        /*for event in events {
         let location = CLLocation(latitude: event.latitude!, longitude: event.longitude!)
         if(locationManager.getDistanceInMeters(coordinate1: locationManager.currentLocation, coordinate2: location) < 5000){
         nearEvents.append(event)
         }
         }
         
         return nearEvents
         */
    }
    
}


