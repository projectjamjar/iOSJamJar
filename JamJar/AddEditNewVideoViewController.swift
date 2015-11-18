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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.videoNameTextVield.delegate = self;
        
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
        
        print("Beginning upload now")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        let param = [
            "name" : videoNameTextVield.text!
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "src", filePathURL: videoToUpload, boundary: boundary)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("****** response data = \(responseString!)")
            
        }
        
        task.resume()
        
        print("Ending upload now")
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, filePathURL: NSURL, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendData(NSString(string: "--\(boundary)\r\n").dataUsingEncoding(NSUTF16StringEncoding)!)
                body.appendData(NSString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n").dataUsingEncoding(NSUTF16StringEncoding)!)
                body.appendData(NSString(string: "\(value)\r\n").dataUsingEncoding(NSUTF16StringEncoding)!)
            }
        }
        
        let filename = filePathURL.lastPathComponent
        print(filename)
        let mimetype = mimeTypeForPath(filePathURL)
        print(mimetype)
        let videoData = NSData(contentsOfURL: filePathURL)
        
        body.appendData(NSString(string: "--\(boundary)\r\n").dataUsingEncoding(NSUTF16StringEncoding)!)
        body.appendData(NSString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n").dataUsingEncoding(NSUTF16StringEncoding)!)
        body.appendData(NSString(string: "Content-Type: \(mimetype)\r\n\r\n").dataUsingEncoding(NSUTF16StringEncoding)!)
        body.appendData(videoData!)
        body.appendData(NSString(string: "\r\n").dataUsingEncoding(NSUTF16StringEncoding)!)
        
        body.appendData(NSString(string: "--\(boundary)--\r\n").dataUsingEncoding(NSUTF16StringEncoding)!)
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func mimeTypeForPath(path: NSURL) -> String {
        let pathExtension = path.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
    }
}
