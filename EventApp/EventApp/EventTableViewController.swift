//
//  EventTableViewController.swift
//  EventApp
//
//  Created by Pascal on 17.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit

class EventTableViewController : UITableViewController,
 UISearchControllerDelegate {
    @IBOutlet weak var searchFooter: UISearchBar!
    
    var detailViewController: EventDetailViewController? = nil
    
    private var filteredEventList = [Event]()
    private var eventList = [Event]()
    
    private let eventController = EventController()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        
        eventController.getEvents(onSuccess: { events in
            self.eventList = events
            self.tableView.reloadData()
        }, onError: { error in
            print("could not load any events")
        })
        //searchController = UISearchController(searchResultsController: resultsTableController)
        
        //searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        
        // scope bar
        //searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = ["All", "Nearest", "Closest"]
        
        // tableView.tableFooterView = searchFooter
        
        //resultsTableController = ResultsTableController()
        
        //resultsTableController.tableView.delegate = self
        
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
        
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Split View
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Update the filtered array based on the search text.
        let searchResults = eventList
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString =
            searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        // Build all the "AND" expressions for each value in searchString.
        /*let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            findMatches(searchString: searchString)
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate =
            NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }
        
        // Apply the filtered results to the search results table.
        if let resultsController = searchController.searchResultsController as? ResultsTableController {
            resultsController.filteredProducts = filteredResults
            resultsController.tableView.reloadData()
        }*/
    }
    
    func configureSearchController() {
        
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        //filterSearchController(searchController.searchBar)
    }
    
    func filterSearchController(searchBar: UISearchBar) {
        let searchText = searchBar.text ?? ""
        filteredEventList = eventList.filter { event in
            let isMatchingSearchText = event.name.lowercased().contains(searchText.lowercased()) || searchText.count == 0
            return isMatchingSearchText
        }
        tableView.reloadData()
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell

        let event = eventList[indexPath.row]
        
        cell.eventTitleLbl?.text = event.name
        cell.eventCategoryLbl?.text  = event.category?.name
        cell.eventPriceLbl?.text = String(format:"%f", event.price!)
        //cell.eventImage =  UIImage(named: event.eventImage)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredEventList.count, of: eventList.count)
            return filteredEventList.count
        }*/
        
        //searchFooter.setNotFiltering()
        print(eventList.count)
        return eventList.count
    }
    
    
    // MARK: - Search bar
    
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
 
}


