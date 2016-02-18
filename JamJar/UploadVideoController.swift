//
//  UploadVideoController.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class UploadVideoViewController: BaseViewController {
    
    @IBOutlet var artistsTextField: AutoCompleteTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        artistsTextField.onTextChange = {[weak self] text in
            // your code goes here
            print(self?.artistsTextField.text);
            APIService.get(APIService.buildURL("artists/search/" + (self?.artistsTextField.text)!)).response{request, response, data, error in
                
                let artistsData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                
                //Variable to store results
                //TODO: Store more than names and have the results display names
                var artistResults = [String]()
                
                //print(artistsData)
                
                if let artists = artistsData as? NSArray{
                    for artist in artists {
                        print(artist["name"])
                        artistResults.append(artist["name"] as! String)
                    }
                    //print(artists[0])
                    //print("artists worked")
                    self?.artistsTextField.autoCompleteStrings = artistResults
                }
                else {
                    self?.artistsTextField.autoCompleteStrings = nil
                }
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