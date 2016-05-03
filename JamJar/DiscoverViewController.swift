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
    
    var selectedConcert: Concert? = nil
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register tableview cell XIBs
        self.tableView.registerNib(UINib(nibName: "ConcertCell", bundle: nil), forCellReuseIdentifier: "ConcertCell")
        
        self.loadConcerts()
        
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
            SCLAlertView().showError("Under Construction!", subTitle: "Discovering concerts by genre will be available soon!", closeButtonTitle: "Got it")
            sectionPicker.selectedSegmentIndex = 1
        default:
            break;
        }
    }
    
    func refresh(sender:AnyObject)
    {
        
        self.loadConcerts()
    }
    
    func loadConcerts() {
        showProgressView()
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
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            hideProgressView()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.concerts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let concert = self.concerts[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ConcertCell", forIndexPath: indexPath) as! ConcertCell
        
        cell.setup(concert)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let concertCell = tableView.cellForRowAtIndexPath(indexPath) as! ConcertCell
        selectedConcert = concertCell.concert
        
        self.performSegueWithIdentifier("ToConcertPage", sender: nil)
        
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
