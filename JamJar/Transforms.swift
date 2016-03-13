//
//  Transforms.swift
//  JamJar
//
//  Created by Mark Koh on 3/10/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

public class StringDoubleTransform: TransformType {
    public typealias Object = Double
    public typealias JSON = String
    
    public func transformFromJSON(value: AnyObject?) -> Double? {
        if let numString = value as? NSString {
            return numString.doubleValue
        }
        return nil
    }
    
    public func transformToJSON(value: Double?) -> String? {
        if let num = value {
            return num.description
        }
        return nil
    }
}