//
//  JamJarVideoCameraDelegate.swift
//  JamJar
//
//  Created by Mark Koh on 5/10/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import DKImagePickerController
import MobileCoreServices

public class JamJarVideoCameraDelegate: DKImagePickerControllerDefaultUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didCancel: (() -> Void)?
    var didFinishCapturingImage: ((image: UIImage) -> Void)?
    var didFinishCapturingVideo: ((videoURL: NSURL) -> Void)?
    
    public override func imagePickerControllerCreateCamera(imagePickerController: DKImagePickerController,
                                                           didCancel: (() -> Void),
                                                           didFinishCapturingImage: ((image: UIImage) -> Void),
                                                           didFinishCapturingVideo: ((videoURL: NSURL) -> Void)
        ) -> UIViewController {
        self.didCancel = didCancel
        self.didFinishCapturingImage = didFinishCapturingImage
        self.didFinishCapturingVideo = didFinishCapturingVideo
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        picker.mediaTypes = [kUTTypeMovie as String]
        
        return picker
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == kUTTypeImage as String {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.didFinishCapturingImage?(image: image)
        } else if mediaType == kUTTypeMovie as String {
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            self.didFinishCapturingVideo?(videoURL: videoURL)
        }
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.didCancel?()
    }
    
}
