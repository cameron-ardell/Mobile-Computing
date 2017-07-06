//
//  NewsFeedTableViewCell.swift
//  testingTables
//
//  Created by Sophia M. Ardell on 5/1/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit


class NewsFeedTableViewCell: UITableViewCell {

   // weak var dataSource: NewsFeedCellDataSource?
    
  
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAvailability: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userTime: UILabel!
    
    
    var personName: [String] = []
    
    //var statusInformation: [String] = []

    


}
