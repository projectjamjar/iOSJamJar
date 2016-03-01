//
//  ArtistChipView.swift
//  JamJar
//
//  Created by Mark Koh on 3/1/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class ArtistChipView: UIView {
    var artist: Artist!
    
    let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        self.heightAnchor.constraintEqualToConstant(self.frame.height).active = true
        
        self.nameLabel.textColor = UIColor.whiteColor()
    }
    
    func setup(artist: Artist, deleteTarget: UIViewController, deleteAction: Selector) {
        self.artist = artist
        
        // Add the artist name
        nameLabel.text = artist.name
        nameLabel.sizeToFit()
        self.addSubview(nameLabel)
        
        // Add a "Delete" button
        let delete = UIButton(frame: CGRectMake(self.frame.width - 45, 5.0, 35, 35))
        delete.setBackgroundImage(UIImage(named: "delete"), forState: .Normal)
        delete.addTarget(deleteTarget, action: deleteAction, forControlEvents: .TouchUpInside)
        self.addSubview(delete)
    }
}
