//
//  GenreCell.swift
//  JamJar
//
//  Created by Mark Koh on 5/8/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class GenreCell: UITableViewCell {
    
    @IBOutlet weak var genreLabel: UILabel!
    
    var genre: Genre!
    
    func setup(genre: Genre, index: Int) {
        self.genre = genre
        
        
        let genreName = self.genre.name.capitalizedString
        self.genreLabel.text = genreName
        
        // Choose a color for the bg
        let colorIndex = index % UIColor.numAccentColors
        let color = UIColor.JamJarAccentColors[colorIndex]
        self.contentView.backgroundColor = color
    }
    
}