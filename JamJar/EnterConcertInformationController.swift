//
//  EnterConcertInformationViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import ObjectMapper
import SCLAlertView
import DKImagePickerController
import Photos

class EnterConcertInformationViewController: BaseViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    var selectedArtists = [Artist]()
    var selectedVenue: VenueSearchResult!
    var videosToUpload: [NSURL] = []
    // Seperate from textField to save the correct date format
    var savedDate: String!
    // queue is used to keep track of assets being saved so that segue can be called after the video URLs have been properly stored in videosToUpload
    var queue: Int = 0
    @IBOutlet var artistsTextField: AutoCompleteTextField!
    @IBOutlet var venueTextField: AutoCompleteTextField!
    @IBOutlet var dateTextField: UnderlinedTextField!
    
    @IBOutlet var artistsAutoCompleteTable: UITableView!
    @IBOutlet var artistsAutoCompleteTableHeight: NSLayoutConstraint!
    @IBOutlet var venuesAutoCompleteTable: UITableView!
    @IBOutlet var venuesAutoCompleteTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var artistsStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Define attributes for artistsTextField
        //artistsTextField.maximumAutoCompleteCount = 4
        artistsTextField.setColoredPlaceholder("Search Artists...")
        artistsTextField.setTableView(artistsAutoCompleteTable, tableViewHeighContstraint: artistsAutoCompleteTableHeight)
        self.view.bringSubviewToFront(artistsAutoCompleteTable)
        artistsTextField.autoCompleteTableHeight = 0
        artistsTextField.onTextChange = {[weak self] text in
            //reset the stored autoCompleteAttributes
            self!.artistsTextField.autoCompleteAttributes?.removeAll()
            if(!text.isEmpty) {
                self!.artistsTextFieldChange(text)
            } else {
                self!.artistsTextField.autoCompleteStrings = nil
            }
        }
        artistsTextField.onSelect = {[weak self] text, indexpath in
            let selectedArtist = self!.artistsTextField.autoCompleteAttributes![text] as! Artist
            
            self!.addArtist(selectedArtist)
            
            self!.artistsTextField.text = nil
        }
        
        //Define attributes for venueTextField
        venueTextField.setColoredPlaceholder("Search Venues...")
        venueTextField.setTableView(venuesAutoCompleteTable, tableViewHeighContstraint: venuesAutoCompleteTableHeight)
        venueTextField.onTextChange = {[weak self] text in
            //reset the stored autoCompleteAttributes
            self!.selectedVenue = nil
            self!.venueTextField.autoCompleteAttributes?.removeAll()
            if(!text.isEmpty) {
                self!.venueTextFieldChange(text)
            } else {
                self!.venueTextField.autoCompleteStrings = nil
            }
        }
        venueTextField.onSelect = {[weak self] text, indexpath in
            self!.selectedVenue = self!.venueTextField.autoCompleteAttributes![text] as! VenueSearchResult
            self!.view.endEditing(true)
        }
        
        //Define attributes for dateTextField
        dateTextField.setColoredPlaceholder("Enter Concert Date...")
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.addTarget(self, action: #selector(EnterConcertInformationViewController.dataPickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        dateTextField.inputView = datePickerView
    }
    
    func addArtist(artist: Artist) {
        // Add artist to the selected artist list
        self.selectedArtists.append(artist)
        
        let artistChip = ArtistChipView(frame: CGRectMake(0,0,self.artistsTextField.frame.width,40))
        artistChip.setup(artist, deleteTarget: self, deleteAction: #selector(EnterConcertInformationViewController.removeArtistTapped(_:)))
        self.artistsStackView.addArrangedSubview(artistChip)
        
        self.artistsTextField.setColoredPlaceholder("Add Another Artist...")
    }
    
    func removeArtistTapped(sender: UIButton) {
        let artistChip = sender.superview as! ArtistChipView
        let artist = artistChip.artist
        self.artistsStackView.removeArrangedSubview(artistChip)
        
        // Remove the artist from the selectedArtists list
        // TODO: Change this to filter by spotify_id once we make the a
        let artistIndex = self.selectedArtists.indexOf { $0.name == artist.name }
        self.selectedArtists.removeAtIndex(artistIndex!)
        
        self.artistsStackView.removeArrangedSubview(artistChip)
        
        if self.selectedArtists.count == 0 {
            self.artistsTextField.setColoredPlaceholder("Search Artists...")
        }
    }
    
    //artistsTextFieldChange takes the input string and updates the search results
    private func artistsTextFieldChange(inputString: String) {
        
        ArtistService.search(inputString) {
            (success: Bool, artists: [Artist]?, message: String?) in
            if !success {
                // Error - show the user and clear previous search info
                // HIDE THIS FOR THE DEMO, THEN UNHIDE IT ONCE ITZ FIXED
//                let errorTitle = "Search failed!"
//                if let error = message { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
//                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
//                self.artistsTextField.autoCompleteStrings = nil
            }
            else {
                // Our search was successful, display search results
                var artistResults = [String]()
                for artist in artists! {
                    artistResults.append(artist.name)
                    self.artistsTextField.autoCompleteAttributes![artist.name] = artist
                }
                self.artistsTextField.autoCompleteStrings = artistResults
            }
        }
    }
    
    //artistsTextFieldChange takes the input string and updates the search results
    private func venueTextFieldChange(inputString: String) {
        
        VenueService.search(inputString) {
            (success, venues, message) in
            if !success {
                // Error - show the user and clear previous search info
                let errorTitle = "Search failed!"
                if let error = message { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
                self.venueTextField.autoCompleteStrings = nil
            }
            else {
                // Our search was successful, display search results
                var venueResults = [String]()
                for venue in venues! {
                    venueResults.append(venue.name)
                    self.venueTextField.autoCompleteAttributes![venue.name] = venue
                }
                self.venueTextField.autoCompleteStrings = venueResults
            }
        }
    }
    
    func dataPickerChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        let strDate = dateFormatter.stringFromDate(sender.date)
        
        dateTextField.text = strDate
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.savedDate = dateFormatter.stringFromDate(sender.date)
    }
    
    @IBAction func continueButtonPressed(sender: UIButton) {
        if(self.selectedVenue == nil || self.selectedArtists.isEmpty || self.dateTextField.text == "") {
            SCLAlertView().showError("Incomplete Fields", subTitle: "Please select artists, a venue, and a date", closeButtonTitle: "Got it")
        } else {
            // Instantiate DKImagePickerController and set it to only show videos
            let pickerController = DKImagePickerController()
            pickerController.sourceType = .Photo
            pickerController.assetType = .AllVideos
            // Cancel button action for DKImagePickerController
            pickerController.didCancel = {
                pickerController.dismissViewControllerAnimated(true, completion: nil)
            }
            pickerController.showsCancelButton = true
            
            // Action for DKImagePickerController after videos were selected
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                
                // Don't let the user move on until they have selected videos
                if(assets.count == 0) {
                    SCLAlertView().showError("No Videos Selected!", subTitle: "Please select a video", closeButtonTitle: "Got it")
                    return
                }
                
                showProgressView()
                self.queue = assets.count
                
                // Store all of the URLs for the selected videos
                for asset in assets {
                    asset.fetchAVAsset(nil, completeBlock: { info in
                        let targetVideoURL = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "/" + info.AVAsset!.URL.lastPathComponent!
                        
                        PHCachingImageManager().requestAVAssetForVideo(asset.originalAsset!, options: nil, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) in
                            dispatch_async(dispatch_get_main_queue(), {
                                let asset = asset as? AVURLAsset
                                if let data = NSData(contentsOfURL: asset!.URL) {
                                    data.writeToFile(targetVideoURL, atomically: true)
                                    // Saved URL is stored for future use
                                    self.videosToUpload.append(NSURL(fileURLWithPath: targetVideoURL))
                                    self.callback()
                                } else {
                                    print("Error: Video could not be processed")
                                    showErrorView()
                                }
                            })
                        })
                    })
                }
            }
            
            self.presentViewController(pickerController, animated: true) {}
        }
        
    }
    
    // Keep track of video URLs being stored
    func callback()
    {
        self.queue -= 1
        // Execute final callback when queue is empty
        if self.queue == 0 {
            showSuccessView()
            self.performSegueWithIdentifier("uploadVideo", sender: nil)
        }
    }
    
    // Method to clear the form
    func clearViewForm() {
        self.selectedArtists = []
        self.selectedVenue = nil
        self.savedDate = nil
        self.queue = 0
        self.artistsTextField.text = ""
        self.venueTextField.text = ""
        self.dateTextField.text = ""
        self.artistsStackView.subviews.forEach({ $0.removeFromSuperview() })
        self.artistsTextField.setColoredPlaceholder("Search Artists...")
    }
    
    override func dismissKeyboard(sender: UITapGestureRecognizer) {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        let touch = sender.locationInView(sender.view)
        if(!CGRectContainsPoint(artistsAutoCompleteTable.frame, touch) && !CGRectContainsPoint(venuesAutoCompleteTable.frame, touch)) {
            self.view.endEditing(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "uploadVideo") {
            let uploadVideoViewController = segue.destinationViewController as! UploadVideoViewController
            
            uploadVideoViewController.selectedVenue = self.selectedVenue
            uploadVideoViewController.selectedArtists = self.selectedArtists
            uploadVideoViewController.selectedDate = self.savedDate
            uploadVideoViewController.videosToUpload = self.videosToUpload
            
            //Clear video list to avoid conflicts
            self.videosToUpload = []
        }
    }
}