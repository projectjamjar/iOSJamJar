//
//  Date.swift
//  JamJar
//
//  Created by Mark Koh on 3/10/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Foundation

let standardDateFormat = "yyyy-MM-dd HH:mm:ss"
let formattedDateFormat = "MMMM d hh:mm a"
let prettyDateFormat = "MMMM d, yyyy"
let shortDateFormat = "yyyy-MM-dd"

extension NSDate {
    
    func string(format: String) -> String {
        let formatter = DateFormatter(format: format)
        return formatter.stringFromDate(self)
    }
    
    func timeOnly() -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([.Hour, .Minute, .Second], fromDate: self)
        return cal.dateFromComponents(components)!
    }
    
    class func fromString(string: String, format: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(string)
    }
    
    class func ISO8601(string: String) -> NSDate? {
        return NSDate.fromString(string, format: "yyyy-MM-dd'T'HH:mm:ss.SSS")
    }
    
    func AMPM() -> String {
        return self.string("a")
    }
}

class Date {
    
    /**
     * Returns the standard date format
     */
    class func standardFormat() -> String {
        return standardDateFormat
    }
    
    /**
     * Returns the formatted date format
     */
    class func formattedFormat() -> String {
        return formattedDateFormat
    }
}

class DateFormatter: NSDateFormatter {
    
    /**
     Initializes a NSDateFormatter with a format
     
     :param: format format of date
     
     :returns: the NSDateFormatter object
     */
    init(format: NSString) {
        super.init()
        
        dateFormat = format as String
        locale = NSLocale.currentLocale()
    }
    
    override init() {
        super.init()
        
        dateFormat = standardDateFormat
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     * Returns a date string from a date string in standard date format using the specified dateFormat
     * :param: string date string
     * :returns: string the new date string
     */
    func dateFromStringWithStandardFormat(string: String) -> String {
        
        let newDateFormat = dateFormat
        
        dateFormat = standardDateFormat
        
        let date = dateFromString(string)
        
        if date == nil {
            return "ERROR"
        }
        
        dateFormat = newDateFormat
        
        let newDate = stringFromDate(date!)
        
        return newDate
    }
    
    /**
     * Returns a date string from a date string in the date format MMMM d hh:mm a
     * :param: string date string
     * :returns: string the new date string
     */
    func dateFromStringWithFormattedDate(string: String) -> String {
        
        let newDateFormat = dateFormat
        
        dateFormat = formattedDateFormat
        
        let date = dateFromString(string)
        
        if date == nil {
            return "ERROR"
        }
        
        dateFormat = newDateFormat
        
        let newDate = stringFromDate(date!)
        
        return newDate
    }
    
    /**
     * Uses the formatted date format
     */
    func useFormattedDateFormat() {
        dateFormat = formattedDateFormat
    }
}