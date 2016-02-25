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

class EnterConcertInformationViewController: BaseViewController, UITextFieldDelegate, ELCImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedArtists = [Artist]()
    var selectedVenue: Venue!
    var videosToUpload: [AnyObject]?
    @IBOutlet var artistsTextField: AutoCompleteTextField!
    @IBOutlet var venueTextField: AutoCompleteTextField!
    @IBOutlet var dateTextField: UnderlinedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //TODO: Create method to set up UI Attributes
        //Define attributes for artistsTextField
        //artistsTextField.maximumAutoCompleteCount = 4
        artistsTextField.attributedPlaceholder = NSAttributedString(string:"Artists",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
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
            self!.selectedArtists.append(selectedArtist)
        }
        
        //Define attributes for venueTextField
        venueTextField.attributedPlaceholder = NSAttributedString(string:"Venue",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
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
        dateTextField.attributedPlaceholder = NSAttributedString(string:"Date",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.addTarget(self, action: Selector("dataPickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        dateTextField.inputView = datePickerView
    }
    
    //artistsTextFieldChange takes the input string and updates the search results
    private func artistsTextFieldChange(inputString: String) {
        
        APIService.get(APIService.buildURL("artists/search/" + inputString)).response{request, response, data, error in
            
            let artistsData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            
            //Variable to store results
            //We do not use the autoCompleteAttributes keys as this array will store values by importance, not alphabetical order
            var artistResults = [String]()
            
            //print(artistsData)
            
            if let artists = artistsData as? NSArray{
                for artist in artists {
                    artistResults.append(artist["name"] as! String)
                    self.artistsTextField.autoCompleteAttributes![artist["name"] as! String] = Artist(id: artist["id"] as! String, name: artist["name"] as! String)
                }
                self.artistsTextField.autoCompleteStrings = artistResults
            } else {
                self.artistsTextField.autoCompleteStrings = nil
            }
        }
    }
    
    //artistsTextFieldChange takes the input string and updates the search results
    private func venueTextFieldChange(inputString: String) {
        //TODO: Make service for Venue with all of this
        let googleMapsKey = "AIzaSyBXPftf0XBdnSQhHzUuXihnABCRfnl3OiI"
        let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(inputString)"
        let url = NSURL(string: (urlString as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!.absoluteString
        
        APIService.get(url).response{request, response, data, error in
            
            let venueData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            
            //Variable to store results
            //We do not use the autoCompleteAttributes keys as this array will store values by importance, not alphabetical order
            var venueResults = [String]()
            
            if let status = venueData["status"] as? String {
                if status == "OK" {
                    if let predictions = venueData["predictions"] as? NSArray {
                        for location in predictions as! [NSDictionary]{
                            venueResults.append(location["description"] as! String)
                            self.venueTextField.autoCompleteAttributes![location["description"] as! String] = Venue(place_id: location["place_id"] as! String, description: location["description"] as! String)
                            self.venueTextField.autoCompleteStrings = venueResults
                        }
                    }
                } else {
                    print("Failed to get venue results")
                }
            } else {
                self.venueTextField.autoCompleteStrings = nil
            }
        }
    }
    
    func dataPickerChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        //dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let strDate = dateFormatter.stringFromDate(sender.date)
        dateTextField.text = strDate
    }
    
    @IBAction func continueButtonPressed(sender: UIButton) {
        if(self.selectedVenue == nil || self.selectedArtists.isEmpty || self.dateTextField.text == "") {
            let alert = UIAlertController(title: "Incomplete Fields", message: "Please select artists, a venue, and a date", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let videoPicker = ELCImagePickerController(imagePicker: ())
            videoPicker.maximumImagesCount = 3
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