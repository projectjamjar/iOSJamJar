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
    @IBOutlet var artistsTextField: AutoCompleteTextField!
    @IBOutlet var venueTextField: AutoCompleteTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Define attributes for artistsTextField
        //artistsTextField.maximumAutoCompleteCount = 4
        artistsTextField.onTextChange = {[weak self] text in
            // your code goes here
            //reset the stored autoCompleteAttributes
            self!.artistsTextField.autoCompleteAttributes?.removeAll()
            if(!text.isEmpty) {
                self!.artistsTextFieldChange(text)
            } else {
                self!.artistsTextField.autoCompleteStrings = nil
            }
        }
        artistsTextField.onSelect = {[weak self] text, indexpath in
            // your code goes here
            let selectedArtist = self!.artistsTextField.autoCompleteAttributes![text] as! Artist
            self!.selectedArtists.append(selectedArtist)
        }
    }
    
    //artistsTextFieldChange takes the input string and updates the search results
    //TODO: FIX BUG: Crashes if a space " " is in the search string
    private func artistsTextFieldChange(inputString: String) {
        //print(inputString);
        APIService.get(APIService.buildURL("artists/search/" + inputString)).response{request, response, data, error in
            
            let artistsData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            
            //Variable to store results
            //We do not use the autoCompleteAttributes keys as this array will store values by importance, not alphabetical order
            var artistResults = [String]()
            
            //print(artistsData)
            
            if let artists = artistsData as? NSArray{
                for artist in artists {
                    //print(artist["name"])
                    artistResults.append(artist["name"] as! String)
                    //artistResults[artist["name"] as! String] = Artist(id: artist["id"] as! String, name: artist["name"] as! String)
                    self.artistsTextField.autoCompleteAttributes![artist["name"] as! String] = Artist(id: artist["id"] as! String, name: artist["name"] as! String)
                }
                //print(artists[0])
                //print("artists worked")
                
                self.artistsTextField.autoCompleteStrings = artistResults
            } else {
                self.artistsTextField.autoCompleteStrings = nil
            }
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