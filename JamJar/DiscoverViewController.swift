//
//  DiscoverViewController.swift
//  JamJar
//
//  Created by Mark Koh on 3/9/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import SCLAlertView

class DiscoverViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sectionPicker: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var concerts: [Concert] = [Concert]()
    var genres: [Genre] = [Genre]()
    
    
    var filteredConcerts: [Concert] = [Concert]()
    
    var selectedGenre: Genre? = nil
    
    var selectedConcert: Concert? = nil
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register tableview cell XIBs
        self.tableView.registerNib(UINib(nibName: "ConcertCell", bundle: nil), forCellReuseIdentifier: "ConcertCell")
        self.tableView.registerNib(UINib(nibName: "GenreCell", bundle: nil), forCellReuseIdentifier: "GenreCell")
        
        self.loadData()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(DiscoverViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl) // not required when using UITableViewController
    }
    
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        switch sectionPicker.selectedSegmentIndex {
        case 0:
            print("JamPicks Selected")
            SCLAlertView().showError("Under Construction!", subTitle: "Discovering JamPicks will be available soon!", closeButtonTitle: "Got it")
            sectionPicker.selectedSegmentIndex = 1
        case 1:
            print("Concerts Selected")
        case 2:
            print("Genres Selected")
        default:
            break;
        }

        // Reset the genre
        self.selectedGenre = nil
        
        // Reload the tableview
        self.tableView.reloadData()
    }
    
    func refresh(sender:AnyObject)
    {
        self.loadData()
    }
    
    func loadData() {
        showProgressView()
        
        // Create an async thread group
        let group = dispatch_group_create()
        
        // Enter the async request group
        dispatch_group_enter(group)
        ConcertService.getConcerts() {
            (success, result, error) in
            if !success {
                // Error - show the error
                let errorTitle = "Server error!"
                if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
            }
            else {
                // Loaded Concerts
                self.concerts = result!
            }
            dispatch_group_leave(group)
            
        }
        
        dispatch_group_enter(group)
        ArtistService.getGenres { (success, result, error) in
            if !success {
                // Display an error
            }
            else {
                // Loaded genres
                self.genres = result!
            }
            dispatch_group_leave(group)
        }
        
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            print("Async requests done")
            hideProgressView()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    // If the user selected a genre, get the matching concerts
    func getConcertsForGenre() {
        if let genre = self.selectedGenre {
            ConcertService.getConcerts([genre], completion: { (success, concerts, result) in
                if !success {
                    // Uh oh!
                }
                else {
                    self.filteredConcerts = concerts!
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionPicker.selectedSegmentIndex {
        case 0:
            return 0
        case 1:
            return self.concerts.count
        case 2:
            if self.selectedGenre == nil {
                // We wanna show the genres
                return self.genres.count
            }
            else {
                // We wanna show the filtered concerts
                return self.filteredConcerts.count
            }
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var concert: Concert?
        
        if sectionPicker.selectedSegmentIndex == 1 {
            concert = self.concerts[indexPath.row]
        }
        else if sectionPicker.selectedSegmentIndex == 2 {
            if self.selectedGenre == nil {
                // We haven't selected a genre yet, return genre cells
                let genre = self.genres[indexPath.row]
                
                let cell = tableView.dequeueReusableCellWithIdentifier("GenreCell", forIndexPath: indexPath) as! GenreCell
                
                cell.setup(genre, index: indexPath.row)
                
                return cell
            }
            else {
                // Set the concert to the filterd concert at this index
                concert = self.filteredConcerts[indexPath.row]
            }
        }
        
        // If we have a concert, return the concert cell
        if let concert = concert {
            let cell = tableView.dequeueReusableCellWithIdentifier("ConcertCell", forIndexPath: indexPath) as! ConcertCell
            
            cell.setup(concert)
            
            return cell
        }
        else {
            // This should never happen
            return UITableViewCell()
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let concertCell = tableView.cellForRowAtIndexPath(indexPath) as? ConcertCell {
            selectedConcert = concertCell.concert
            
            self.performSegueWithIdentifier("ToConcertPage", sender: nil)
        }
        else if let genreCell = tableView.cellForRowAtIndexPath(indexPath) as? GenreCell {
            self.selectedGenre = genreCell.genre
            self.getConcertsForGenre()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: self)
        
        if segue.identifier == "ToConcertPage" {
            let vc = segue.destinationViewController as! ConcertPageViewController
            vc.concert = self.selectedConcert!
        }
    }
}
