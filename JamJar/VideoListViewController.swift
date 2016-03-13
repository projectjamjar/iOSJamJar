//
//  VideoListViewController.swift
//  JamJar
//
//  Created by Mark Koh on 3/12/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import SCLAlertView

class VideoListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
//    @IBOutlet weak var sectionPicker: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var tableView: UITableView!
    
    var videos: [Video] = [Video]()
    var filteredVideos: [Video] = [Video]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the reusable video cell
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredVideos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let video = self.filteredVideos[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        
        cell.setup(video)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Video selected: \(indexPath.row)")
    }
}

