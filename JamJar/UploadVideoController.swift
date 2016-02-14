//
//  UploadVideoController.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class UploadVideoViewController: BaseViewController {
    
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