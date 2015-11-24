//
//  AddEditNewVideoViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 11/2/15.
//  Copyright © 2015 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

class AddEditNewVideoViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var videoNameTextVield: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var concertDateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.videoNameTextVield.delegate = self;
        
        //set concert date text field to receive selected date
        let datePickerView:UIDatePicker = UIDatePicker()
        concertDateTextField.inputView = datePickerView
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func uploadButtonPressed(sender: UIButton) {
        let videoPicker = UIImagePickerController()
        videoPicker.delegate = self
        videoPicker.allowsEditing = false
        videoPicker.sourceType = .PhotoLibrary
        videoPicker.mediaTypes = [kUTTypeMovie as String]
        
        presentViewController(videoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        print(info)
        
        let videoToUpload = info["UIImagePickerControllerMediaURL"] as! NSURL
        let url = NSURL(string: "http://api.projectjamjar.com/videos/")
        
        print(videoToUpload.path)
        
        var path = NSBundle.mainBundle().pathForResource(videoToUpload.path, ofType: "mp4")
        var data1 = NSData()
        //var videodata: NSData? = NSData.dataWithContentsOfMappedFile(path!) as? NSData
        var request = NSMutableURLRequest(URL: url!)
        
        //var session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"

        /*
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let postString = "name=" + videoNameTextVield.text! + "&src=" + videoToUpload.path!
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            } else {
                print("response = \(response!)")
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                print("responseString = \(responseString)")
            }
        }
        
        task.resume()
        */
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
