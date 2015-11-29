//
//  VideoListViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 10/27/15.
//  Copyright © 2015 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoListViewController: UITableViewController {
    
    var videos = [Video]()
    private var player: AVPlayer!
    
    @IBOutlet weak var addVideoButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: "reloadVideoList:", forControlEvents: UIControlEvents.ValueChanged)
        let url = NSURL(string: "http://api.projectjamjar.com/videos/")
        let data = NSData(contentsOfURL: url!)
        let videoList: [NSDictionary] = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
        
        for video in videoList {
            let videoId = video["id"] as! Int
            let videoName = video["name"] as! String
            let videoSrc = video["hls_src"] as! String
            
            videos.append(Video(id: videoId, name: videoName, hls_src: videoSrc)!)
        }        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVideo" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let avplayerController = segue.destinationViewController as! AVPlayerViewController
                let url = NSURL(string: videos[indexPath.row].hls_src)
                print(url)
                self.player = AVPlayer(URL: url!)
                avplayerController.player = self.player
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let video = videos[indexPath.row]
        cell.textLabel!.text = video.name
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Additional methods
    
    func reloadVideoList(refreshControl: UIRefreshControl) {
        //call loadVideos function (need to implement this method)
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
}

