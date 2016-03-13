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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadConcerts()
    }
    
    func loadConcerts() {
        ConcertService.getConcerts() {
            (success, result, error) in
            if !success {
                // Error - show the user
                let errorTitle = "Server error!"
                if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
            }
            else {
                // Our login was successful, goto Home!
                self.concerts = result!
                self.tableView.reloadData()
            }
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
        
        self.performSegueWithIdentifier("ToVideoList", sender: nil)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: self)
        
        if segue.identifier == "ToVideoList" {
            let vc = segue.destinationViewController as! VideoListViewController
            vc.videos = self.selectedConcert!.videos
            vc.concert = self.selectedConcert!
        }
    }
}
