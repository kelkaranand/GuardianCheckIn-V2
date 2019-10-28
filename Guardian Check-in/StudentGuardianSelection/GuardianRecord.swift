//
//  GuardianRecord.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 28/10/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation

class GuardianRecord {
    
    var fname:String
    var lname:String
    var relation:String
    
    init() {
        fname = ""
        lname = ""
        relation = ""
    }
    
    init(_ fname:String, _ lname:String, _ relation:String) {
        self.fname = fname
        self.lname = lname
        self.relation = relation
    }
    
}
