//
//  JamJarTabBarController.swift
//  JamJar
//
//  Created by Mark Koh on 2/29/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import QuartzCore

class JamJarTabBarController: UITabBarController {
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        
//        self.tabBar.layer.borderWidth = 0
//        self.tabBar.layer.borderColor = self.tabBar.tintColor.CGColor
//        
//        self.addCenterButtonWithImage(UIImage(named: "navbtn-discover")!, highlightImage: nil)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func addCenterButtonWithImage(buttonImage: UIImage, highlightImage: UIImage?){
//        let button = UIButton(type: UIButtonType.Custom) as UIButton
//        button.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin , UIViewAutoresizing.FlexibleLeftMargin , UIViewAutoresizing.FlexibleBottomMargin , UIViewAutoresizing.FlexibleTopMargin]
//        
//        button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)
//        button.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
//        button.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
//        button.addTarget(self, action: "buttonEvent", forControlEvents: UIControlEvents.TouchUpInside)
//        
//        let heightDifference: CGFloat = buttonImage.size.height - self.tabBar.frame.size.height
//        
//        if (heightDifference < 0){
//            button.center = self.tabBar.center
//        }else{
//            var center: CGPoint = self.tabBar.center
//            center.y = center.y - self.tabBar.frame.origin.y - heightDifference/2.0
//            //            center.y = center.y - heightDifference/2.0
//            button.center = center
//        }
//        
//        
//        
//        //        self.view.addSubview(button)
//        self.tabBar.addSubview(button)
//        
//    }
//    
//    func buttonEvent() {
//        self.selectedIndex = 1
//    }
}
