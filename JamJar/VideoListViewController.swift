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
    
    var videos = [NSURL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var objects = [String]()
        objects.append("http://devstreaming.apple.com/videos/wwdc/2015/106z3yjwpfymnauri96m/106/hls_vod_mvp.m3u8")
        objects.append("http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
        
        for object in objects {
            videos.append(NSURL(string: object)!)
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
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
                
                avplayerController.player = AVPlayer(URL: videos[indexPath.row])
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
        cell.textLabel!.text = video.absoluteString
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


}

