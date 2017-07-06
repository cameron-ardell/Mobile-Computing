//
//  MySplitViewController.swift
//  calculator
//
//  Created by Sophia M. Ardell on 4/25/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import UIKit

class MySplitViewController: UISplitViewController, UISplitViewControllerDelegate  {


    
    //something is very wrong here
    //http://stackoverflow.com/questions/25875618/uisplitviewcontroller-in-portrait-on-iphone-shows-detail-vc-instead-of-master?rq=1
    
    /* alternate version:
    

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: GraphViewController!, ontoPrimaryViewController primaryViewController: CalculatorViewController!) -> Bool{
        return true
    }
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.preferredDisplayMode = .PrimaryOverlay
    }
    
    
    //this version currently doesn't work
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        return true
    }


}
