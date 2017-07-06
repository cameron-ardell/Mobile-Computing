//
//  ProfileViewController.swift
//  testingTables
//
//  Created by Sophia M. Ardell on 5/1/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

//gives individual username so their information can be found on server
//if user chooses to segue to their profile
protocol OtherProfileDataSource: class {
    func profileInfo(name: [String]) -> userModel?
}

class OtherProfileViewController: UIViewController{

    weak var dataSource: OtherProfileDataSource?
    
    var profileInformation: userModel?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var classYear: UILabel!
    @IBOutlet weak var majors: UILabel!
    @IBOutlet weak var bio: UILabel!
    
    var nameString: [String]?
    
    
    @IBOutlet weak var mealOneInfo: UILabel!
    @IBOutlet weak var mealTwoInfo: UILabel!
    @IBOutlet weak var mealThreeInfo: UILabel!
    
    
    @IBOutlet weak var inviteLabel: UIButton!
    
    @IBAction func backToNewsFeed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.text = nameString![0] + " " + nameString![1]
        
        profileInformation = dataSource?.profileInfo(nameString!)
        self.title = name.text
        self.setLabels()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUsername(named: String) {
        name.text = named
    }
    
    func setLabels() {
        
        inviteLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //need to find way to check to make sure it exists
       // if profileInformation!.firstName != nil {
            classYear.text = String(profileInformation!.year!)
            majors.text = profileInformation!.major
            bio.text = profileInformation!.bio
            
            if profileInformation!.status1 == 0 {
                mealOneInfo.text = "Unavailable for Meal 1."
            } else {
                mealOneInfo.text = "Availiable for \(profileInformation!.time1!), \(profileInformation!.place1!)"
            }
            if profileInformation!.status2 == 0 {
                mealTwoInfo.text = "Unavailable for Meal 2."
            } else {
                mealTwoInfo.text = "Availiable for \(profileInformation!.time2!), \(profileInformation!.place2!)"
            }
            if profileInformation!.status3 == 0 {
                mealThreeInfo.text = "Unavailable for Meal 3."
            } else {
                mealThreeInfo.text = "Availiable for \(profileInformation!.time3!), \(profileInformation!.place3!)"
            }
       // }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destination = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }

        
        if let hvc = destination as? InvitePersonViewController {
            
            if let identifier = segue.identifier {
                
                if identifier == "inviteSpecificPersonSegue" {
                    hvc.typeOfInvite = "Invite \(profileInformation!.firstName!)!"
                    hvc.userInvited = nameString![0] + " " + nameString![1]
                }
                
            }
            
        }
    }
    

}
