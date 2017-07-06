//
//  UpdateMealMenuVC.swift
//  testingTables
//
//  Created by Sophia M. Ardell on 5/16/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class UpdateMealMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var destination = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        
        if let hvc = destination as? UpdateSpecificMealViewController {
            
            if let identifier = segue.identifier{
                
                if identifier == "Meal One Segue" {
                    hvc.mealNumber = 1
                    hvc.typeOfInvite += "One!"
                }
                if identifier == "Meal Two Segue" {
                    hvc.mealNumber = 2
                    hvc.typeOfInvite += "Two!"
                }
                if identifier == "Meal Three Segue" {
                    hvc.mealNumber = 3
                    hvc.typeOfInvite += "Three!"
                }
                
            }
        }
    }
    
    @IBAction func backToNewsFeed(sender: UIButton) {
        let presentingVC = self.presentingViewController
        self.dismissViewControllerAnimated(true, completion: {
            presentingVC!.dismissViewControllerAnimated(false, completion: {})
        })
    }

}
