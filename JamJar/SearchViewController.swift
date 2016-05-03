//
//  SearchViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class SearchViewController: BaseTableViewController, UISearchBarDelegate {

    // MARK: - Properties
    @IBOutlet var searchBar: UISearchBar!
    
    var searchActive : Bool = false
    var searchResult: SearchResult? = nil
    var selectedType: SearchResultType = .Concert
    var filtered:[AnyObject] = []
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
        let leftNavBarButton = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = leftNavBarButton
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // Search Bar Function jawn
        print("HEY! \(selectedScope)")
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //update search results jawn
        print("Jawn changed!")
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // Debounce search bar queries so we don't make a bazillion requests
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(self.searchText), object: nil)
        self.performSelector(#selector(self.searchText), withObject: nil, afterDelay: 0.5)

    }
    
    func searchText() {
        if let text = self.searchBar.text {
        
            SearchService.search(text) {
                (success, results, result) in
                if !success {
                    print("Uh oh! - Search got bonked!")
                }
                else {
                    self.searchResult = results!
                    self.updateTable()
                }
                
            }
        }
        
//        filtered = data.filter({ (text) -> Bool in
//            let tmp: NSString = text
//            let range = tmp.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch)
//            return range.location != NSNotFound
//        })
//        if(filtered.count == 0){
//            searchActive = false;
//        } else {
//            searchActive = true;
//        }
//        self.tableView.reloadData()
    }
    
    
    func updateTable() {
        
    }
}
