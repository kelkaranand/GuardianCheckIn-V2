//
//  GuardianRecord.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 28/10/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation

/**
    Class for GuardianRecord. Objects of this class can be used to store FamilyMember information
 **/
class GuardianRecord {
    
    var name:String
    var id:String
    var relation:String
    
    init() {
        name = ""
        id = ""
        relation = ""
    }
    
    init(_ name:String, _ id:String, _ relation:String) {
        self.name = name
        self.id = id
        self.relation = relation
    }
    
}
