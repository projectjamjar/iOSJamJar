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

// via cocaopods
import Alamofire

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
        //let url = NSURL(string: "http://localhost:5001/videos/")
        
        // make request here pls
        let parameters = [
            "name": "lololol"
        ]
        
        Alamofire.upload(
            .POST,
            "http://localhost:5001/videos/",
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: videoToUpload, name: "file")
                
                for (key, value) in parameters {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
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
