//
//  VideoStagingArea.swift
//  JamJar
//
//  Created by Mark Koh on 5/11/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class VideoItem: UICollectionViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var video: NSURL!
    
    func setup(video: NSURL) {
        self.video = video
        
//        self.thumbnail
    }
    
    @IBAction func deleteVideo(sender: UIButton?) {
        print("Delete: \(video)")
    }
}

class ChooseVideosViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //information about the concert that is sent to this controller
    var selectedArtists = [Artist]()
    var selectedVenue: VenueSearchResult!
    var selectedDate: String!
    
    // Videos that are selected in this controller
    var videosToUpload: [NSURL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do stuff here
        
        self.updateUI()
    }
    
    func updateUI() {
        // Enable/disable the continue button
        self.continueButton.enabled = videosToUpload.count > 0
    }
    
    /***************************************************************************
     Video Collection View
     ***************************************************************************/
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VideoItem", forIndexPath: indexPath)
        
        return cell
    }
}
