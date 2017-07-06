//
//  userModel.swift
//  testingTables
//
//  Created by Marcus E. Christiansen on 5/9/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import Foundation

class userModel: NSObject {
    
    var ID: Int?
    var email: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    var year: String?
    var major: String?
    var bio: String?
    var status1: Int? //Bit. 1 = True. 0 = False.
    var time1: String?
    var place1: String?
    var status2: Int?
    var time2: String?
    var place2: String?
    var status3: Int?
    var time3: String?
    var place3: String?
    
    override init() {
    }
    
    init(ID:Int, email: String, password: String, firstName:String, lastName: String, year:String, major:String, bio: String, status1:Int, time1:String, place1: String, status2:Int, time2:String, place2: String, status3:Int, time3:String, place3: String) {
        self.ID = ID
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.year = year
        self.major = major
        self.bio = bio
        self.status1 = status1
        self.time1 = time1
        self.place1 = place1
        self.status2 = status2
        self.time2 = time2
        self.place2 = place2
        self.status3 = status3
        self.time3 = time3
        self.place3 = place3

    }
    
    override var description: String {
        return "ID: \(ID), Email: \(email), Name: \(firstName) \(lastName), Year: \(year), Major: \(major), Bio \(bio), Status 1: \(status1), Time 1: \(time1), Place 1: \(place1), Status 2: \(status2), Time 2: \(time2), Place 2: \(place2), Status 3: \(status3), Time 3: \(time3), Place 3: \(place3)"
    }
    
}