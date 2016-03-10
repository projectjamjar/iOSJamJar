//
//  DiscoverViewController.swift
//  JamJar
//
//  Created by Mark Koh on 3/9/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class ConcertCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
}

class DiscoverViewController: BaseViewController {
    @IBOutlet weak var sectionPicker: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        UserService.logout()
        //        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
