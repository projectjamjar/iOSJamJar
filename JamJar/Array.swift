//
//  Array.swift
//  JamJar
//
//  Created by Ethan Riback on 5/4/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}