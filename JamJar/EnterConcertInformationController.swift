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

class EnterConcertInformationViewController: BaseViewController, UITextFieldDelegate, ELCImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedArtists = [Artist]()
    var selectedVenue: Venue!
    var videosToUpload: [AnyObject]?
    @IBOutlet var artistsTextField: AutoCompleteTextField!
    @IBOutlet var venueTextField: AutoCompleteTextField!
    @IBOutlet var dateTextField: UnderlinedTextField!
    
    @IBOutlet weak var artistsStackView: UIStackView!
    @IBOutlet weak var artistStackViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //TODO: Create method to set up UI Attributes
        //Define attributes for artistsTextField
        //artistsTextField.maximumAutoCompleteCount = 4
        artistsTextField.setColoredPlaceholder("Search Artists...")
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
            self!.artistsTextField.setColoredPlaceholder("Add Another Artist...")
        }
        
        //Define attributes for venueTextField
        venueTextField.setColoredPlaceholder("Search Venues...")
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
            self!.selectedVenue = self!.venueTextField.autoCompleteAttributes![text] as! Venue
        }
        
        //Define attributes for dateTextField
        dateTextField.setColoredPlaceholder("Enter Concert Date...")
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.addTarget(self, action: Selector("dataPickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        dateTextField.inputView = datePickerView
    }
    
    func addArtist(artist: Artist) {
        // If this is the first artist we're adding, remove stackview constraint
        if self.selectedArtists.count == 0 {
            self.artistStackViewHeightConstraint.active = false
        }
        
        // Add artist to the selected artist list
        self.selectedArtists.append(artist)
        
        let artistChip = ArtistChipView(frame: CGRectMake(0,0,self.artistsTextField.frame.width,30))
        artistChip.setup(artist, deleteTarget: self, deleteAction: Selector("removeArtistTapped:"))
        self.artistsStackView.addArrangedSubview(artistChip)
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
            self.artistStackViewHeightConstraint.active = true
        }
        
    }
    
    //artistsTextFieldChange takes the input string and updates the search results
    private func artistsTextFieldChange(inputString: String) {
        
        ArtistService.search(inputString) {
            (success: Bool, artists: [Artist]?, message: String?) in
            if !success {
                // Error - show the user and clear previous search info
                let errorTitle = "Search failed!"
                if let error = message { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
                self.artistsTextField.autoCompleteStrings = nil
            }
            else {
                print("Success")
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
            (success: Bool, venues: [Venue]?, message: String?) in
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
                    venueResults.append(venue.description)
                    self.venueTextField.autoCompleteAttributes![venue.description] = venue
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
    }
    
    @IBAction func continueButtonPressed(sender: UIButton) {
        if(self.selectedVenue == nil || self.selectedArtists.isEmpty || self.dateTextField.text == "") {
            SCLAlertView().showError("Incomplete Fields", subTitle: "Please select artists, a venue, and a date", closeButtonTitle: "Got it")
        } else {
            let videoPicker = ELCImagePickerController(imagePicker: ())
            videoPicker.maximumImagesCount = 10
            videoPicker.returnsOriginalImage = false; //Only return the fullScreenImage, not the fullResolutionImage
            videoPicker.returnsImage = true; //Return UIimage if YES. If NO, only return asset location information
            videoPicker.onOrder = true; //For multiple image selection, display and return selected order of images
            videoPicker.mediaTypes = [kUTTypeMovie as String] //Makes sure that only videos can be selected
            videoPicker.imagePickerDelegate = self
            
            presentViewController(videoPicker, animated: true, completion: nil)
        }
        
    }
    
    func elcImagePickerController(picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [AnyObject]!) {
        if(info.count > 0) {
            print(info)
            
            self.videosToUpload = info
            
            picker.dismissViewControllerAnimated(true, completion: nil)
            
            performSegueWithIdentifier("uploadVideo", sender: nil)
        }
    }
    
    func elcImagePickerControllerDidCancel(picker: ELCImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "uploadVideo") {
            let uploadVideoViewController = segue.destinationViewController as! UploadVideoViewController
            
            uploadVideoViewController.selectedVenue = self.selectedVenue
            uploadVideoViewController.selectedArtists = self.selectedArtists
            uploadVideoViewController.selectedDate = self.dateTextField.text
            uploadVideoViewController.videosToUpload = self.videosToUpload
        }
    }
}