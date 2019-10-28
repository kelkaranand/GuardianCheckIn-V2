//
//  Student.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 28/10/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation

class StudentRecord {
    
    var fname:String
    var lname:String
    var id:String
    
    init() {
        fname = ""
        lname = ""
        id = ""
    }
    
    init(_ fname:String, _ lname:String, _ id:String) {
        self.fname = fname
        self.lname = lname
        self.id = id
    }
    
}
