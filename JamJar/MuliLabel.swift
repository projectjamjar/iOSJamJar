//
//  MuliLabel.swift
//  JamJar
//
//  Created by Mark Koh on 5/4/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class MuliLabel: UILabel {
    var padding: CGFloat = 0.0
    
    var data: AnyObject?
    
    func setup(text: String,
               size: CGFloat = 16.0,
               title: String? = nil,
               numLines: Int = 0,
               color: UIColor = UIColor.whiteColor(),
               frameSize: CGSize? = nil,
               alignment: NSTextAlignment = .Natural,
               padding: CGFloat? = nil,
               data: AnyObject? = nil) {
        
        if let title = title {
            let attributedText = NSMutableAttributedString(
                string: "\(title): \(text)",
                attributes: [
                    NSFontAttributeName: UIFont(name: "Muli-Light",
                        size: size)!
                ]
            )
            attributedText.addAttribute(NSFontAttributeName,
                                        value: UIFont(name: "Muli",
                                            size: size)!,
                                        range: NSRange(location: 0, length: title.characters.count + 1))
            
            self.attributedText = attributedText
        }
        else {
            self.text = text
            self.font = UIFont(name: "Muli-Light", size: size)
        }
        
        self.numberOfLines = numLines
        self.lineBreakMode = .ByWordWrapping
        self.textColor = color
        
        self.textAlignment = alignment
        
        if let frameSize = frameSize {
            self.frame.size = self.sizeThatFits(frameSize)
        }
        else {
            self.sizeToFit()
        }
        
        if let padding = padding {
            self.padding = padding
            self.drawTextInRect(self.frame)
        }
        
        if data != nil {
            self.data = data
        }
    }
    
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, self.padding, 0, self.padding)))
    }
}
