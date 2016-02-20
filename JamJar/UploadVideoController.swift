//
//  UploadVideoController.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class UploadVideoViewController: BaseViewController {
    
    var selectedArtists = [Artist]()
    var selectedVenue: Venue!
    @IBOutlet var artistsTextField: AutoCompleteTextField!
    @IBOutlet var venueTextField: AutoCompleteTextField!
    @IBOutlet var concertDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //TODO: Create method to set up UI Attributes
        //Define attributes for artistsTextField
        //artistsTextField.maximumAutoCompleteCount = 4
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
        
        concertDatePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
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
            /*
            if let venue = venueData as? NSArray{
                artistResults.append(artist["name"] as! String)
                self.artistsTextField.autoCompleteAttributes![artist["name"] as! String] = Artist(id: artist["id"] as! String, name: artist["name"] as! String)
                self.artistsTextField.autoCompleteStrings = artistResults
            } else {
                self.artistsTextField.autoCompleteStrings = nil
            }
            */
        }
    }
    
    @IBAction func continueButtonPressed(sender: UIButton) {
        print("Pick video to upload");
        
        //Testing Stuff
        APIService.get(APIService.buildURL("concerts/")).response{request, response, data, error in
            
            let concertData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            
            print("Request")
            print(request)
            print("Response")
            print(response)
            print("Data")
            print(concertData)
            print("Error")
            print(error)
        }
    }
}