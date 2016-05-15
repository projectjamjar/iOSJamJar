//
//  UIView.swift
//  JamJar
//
//  Created by Mark Koh on 5/15/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func cropToCircle() -> UIView? {
        // Make the photo circular
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
        
        return self
    }
    
    public func cropToCircleWithBorder(borderWidth: CGFloat, borderColor: UIColor) -> UIView? {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.CGColor
        self.cropToCircle()
        return self
    }
    
    // Add borders to the provided sides of a UIView
    // view.addBorder([.Top, .Bottom])
    func addBorder(edges edges: UIRectEdge, color: UIColor = UIColor.whiteColor(), thickness: CGFloat = 1) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRectZero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.Top) || edges.contains(.All) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[top(==thickness)]",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[top]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.Left) || edges.contains(.All) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[left(==thickness)]",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[left]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.Right) || edges.contains(.All) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:[right(==thickness)]-(0)-|",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[right]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.Bottom) || edges.contains(.All) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:[bottom(==thickness)]-(0)-|",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[bottom]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
    
    /**
     * Increase the height of a UIView by a constant
     */
    func adjustHeight(amount: CGFloat) {
        let frame = self.frame
        let origin = frame.origin
        let newFrame = CGRect(x: origin.x, y: origin.y, width: frame.width, height: frame.height + amount)
        self.frame = newFrame
    }
}
