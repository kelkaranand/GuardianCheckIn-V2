//
//  Location.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 10/01/20.
//  Copyright © 2020 Anand Kelkar. All rights reserved.
//

import Foundation

class LocationRecord {
    
    var name:String
    var options:String
    var guardianCheck:Bool
    
    init() {
        name = ""
        options = ""
        guardianCheck = false
    }
    
    init(_ name:String, _ options:String, _ guardianCheck:Bool) {
        self.name = name
        self.options = options
        self.guardianCheck = guardianCheck
    }
    
}
