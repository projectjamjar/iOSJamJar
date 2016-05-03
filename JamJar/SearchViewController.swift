//
//  SearchViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sectionPicker: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var searchActive : Bool = false
    var searchResult: SearchResult? = nil
    var selectedType: SearchResultType = .Concert
    var filtered:[AnyObject] = []
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Register tableview cell XIBs
        self.tableView.registerNib(UINib(nibName: "ConcertCell", bundle: nil), forCellReuseIdentifier: "ConcertCell")
        // Register tableview cell XIBs
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        
        /*
        let leftNavBarButton = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = leftNavBarButton
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the appropriate number of rows
        if let result = self.searchResult {
            if self.selectedType == .Concert {
                return result.concerts.count
            }
            else if self.selectedType == .Video {
                return result.videos.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let result = self.searchResult {
            if self.selectedType == .Concert {
                let concert = result.concerts[indexPath.row]
                
                let cell = tableView.dequeueReusableCellWithIdentifier("ConcertCell", forIndexPath: indexPath) as! ConcertCell
                
                cell.setup(concert)
                
                return cell
            }
            else if self.selectedType == .Video {
                let video = result.videos[indexPath.row]
                
                let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
                
                cell.setup(video)
                
                return cell
            }
        }
        // This should never happen
        return UITableViewCell()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //update search results jawn
        print("Jawn changed!")
    }
    
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        switch sectionPicker.selectedSegmentIndex {
        case 0:
            print("Concerts Selected")
            self.selectedType = .Concert
        case 1:
            print("Videos Selected")
            self.selectedType = .Video
        default:
            self.selectedType = .Concert
            break;
        }
        self.updateTable()
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
    }
    
    
    func updateTable() {
        self.tableView.reloadData()
    }
}
