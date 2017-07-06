//
//  AddFriendVC.swift
//  testingTables
//
//  Created by Sophie Ardell on 5/10/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class AddFriendVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func retreat(sender: UIButton) {
        let presentingVC = self.presentingViewController
        self.dismissViewControllerAnimated(true, completion: {
            presentingVC!.dismissViewControllerAnimated(false, completion: {})
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
