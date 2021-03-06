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
    
    // Selections to be used for segues
    var selectedItem: AnyObject?
    
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
        
        self.setBackgroundView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // UI Stuff
    ////////////////////////////////////////////////////////////////////////////
    
    func updateUI() {
        self.tableView.reloadData()
        self.setBackgroundView()
        
        if let result = searchResult {
            let numConcerts = result.concerts.count
            let numVideos = result.videos.count
            self.sectionPicker.setTitle("Concerts (\(numConcerts))", forSegmentAtIndex: 0)
            self.sectionPicker.setTitle("Videos (\(numVideos))", forSegmentAtIndex: 1)
        }
        else {
            self.sectionPicker.setTitle("Concerts", forSegmentAtIndex: 0)
            self.sectionPicker.setTitle("Videos", forSegmentAtIndex: 1)
        }
    }
    
    func setBackgroundView() {
        // Set the background view message if we haven't searched yet
        if self.searchResult == nil {
            self.displayBackgroundMessage("Type above to search Concerts and Videos...")
        }
        else if selectedType == .Concert &&
                self.searchResult!.concerts.count == 0 {
            self.displayBackgroundMessage("No matching concerts found...")
        }
        else if selectedType == .Video &&
            self.searchResult!.videos.count == 0 {
            self.displayBackgroundMessage("No matching videos found...")
        }
        else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .SingleLine
        }
    }
    
    func displayBackgroundMessage(message: String) {
        let backgroundLabel = MuliLabel()
        backgroundLabel.setup(message,
                              size: 24.0,
                              alignment: .Center,
                              padding: 10.0,
                              color: UIColor.lightGrayColor())
        self.tableView.backgroundView = backgroundLabel
        self.tableView.separatorStyle = .None
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // Segmented Control Stuff
    ////////////////////////////////////////////////////////////////////////////
    
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
        self.updateUI()
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // Search Bar Stuff
    ////////////////////////////////////////////////////////////////////////////
    
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
                    self.updateUI()
                }
                
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = nil
        self.searchResult = nil
        self.updateUI()
    }
 
    ////////////////////////////////////////////////////////////////////////////
    // Table Stuff
    ////////////////////////////////////////////////////////////////////////////
    
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
                
                cell.setup(video, concert: video.concert!, viewController: self)
                
                return cell
            }
        }
        // This should never happen
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if let concertCell = cell as? ConcertCell {
            // We chose a concert!
            let concert = concertCell.concert
            self.selectedItem = concert
            self.performSegueWithIdentifier("ToConcert", sender: self)
        }
        else if let videoCell = cell as? VideoCell {
            // We chose a video cell!
            let video = videoCell.video
            self.selectedItem = video
            self.performSegueWithIdentifier("ToVideo", sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    ////////////////////////////////////////////////////////////////////////////
    // Segue Stuff
    ////////////////////////////////////////////////////////////////////////////

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "ToConcert" {
            if let destination = segue.destinationViewController as? ConcertPageViewController,
                concert = self.selectedItem as? Concert {
                destination.concert = concert
            }
        }
        else if segue.identifier == "ToVideo" {
            if let destination = segue.destinationViewController as? VideoPageViewController,
                video = self.selectedItem as? Video {
                destination.video = video
                if let concert = video.concert {
                    destination.concert = concert
                }
            }
        }
    }
    
}
