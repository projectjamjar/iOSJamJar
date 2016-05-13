//
//  JamJarPageViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 5/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SCLAlertView

class JamJarPageViewController: VideoPageViewController, updateVideoDelegate {
    
    weak var jamjar: JamJarGraph!
    
    // UI Element
    @IBOutlet weak var jamJarContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Register the reusable video cell
        self.suggestedTableView.registerNib(UINib(nibName: "JamJarCell", bundle: nil), forCellReuseIdentifier: "JamJarCell")
        
        self.suggestedTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Todo: find out if this works if completely removed
    override func removeObserversInPlayer() {
        for controller in self.childViewControllers {
            if let child = controller as? StitchedJamJarAVPlayerViewController {
                child.removeObservers()
            }
        }
    }
    
    // This is used to switch the active JamJar when "Suggested Content" has a selected element
    func changeJamJarInPlayer() {
        for controller in self.childViewControllers {
            if let child = controller as? StitchedJamJarAVPlayerViewController {
                child.removeObservers()
                
                //define first video
                let firstVideo = self.concert.videos.filter{ $0.id == self.jamjar.startId }.first
                self.updateVideo(firstVideo!)
                let videoPath = NSURL(string: (firstVideo?.hls_src)!)
                
                child.player = JamJarAVPlayer(URL: videoPath!, videoId: (firstVideo?.id)!)
                child.currentVideo = firstVideo
                child.jamjar = self.jamjar
                
                child.viewDidLoad()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playJamJar") {
            unowned let embeddedVideoViewController = segue.destinationViewController as! StitchedJamJarAVPlayerViewController
            
            //define first video
            let firstVideo = self.concert.videos.filter{ $0.id == self.jamjar.startId }.first
            self.updateVideo(firstVideo!)
            let videoPath = NSURL(string: (firstVideo?.hls_src)!)
            
            //record view of first video
            self.updateViewCount(firstVideo?.id!)
            
            embeddedVideoViewController.player = JamJarAVPlayer(URL: videoPath!, videoId: (firstVideo?.id)!)
            embeddedVideoViewController.currentVideo = firstVideo
            embeddedVideoViewController.videos = self.concert.videos
            embeddedVideoViewController.jamjar = self.jamjar
            embeddedVideoViewController.jamjarDelegate = self
        }
        else if segue.identifier == "ToConcertPage" {
            let vc = segue.destinationViewController as! ConcertPageViewController
            vc.concert = self.concert
        }
    }
    
    /***************************************************************************
     TableView Setup
     ***************************************************************************/
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return concert.jamjars.count - 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var jamjarList: [JamJarGraph] = self.concert!.jamjars!.filter { (jamjar) -> Bool in
            return !(jamjar.startId! == self.jamjar.startId)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("JamJarCell", forIndexPath: indexPath) as! JamJarCell
        
        let startVideo = self.concert.videos.filter { (video) -> Bool in
            return video.id == jamjarList[indexPath.row].startId
        }.first
        
        cell.setup(jamjarList[indexPath.row], startVideo: startVideo!)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let jamjarCell = tableView.cellForRowAtIndexPath(indexPath) as! JamJarCell
        self.jamjar = jamjarCell.jamjar
        changeJamJarInPlayer()
        self.viewDidLoad()
    }
}