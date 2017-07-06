//
//  LogInVCViewController.swift
//  testingTables
//
//  Created by Marcus E. Christiansen on 5/7/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class LogInVCViewController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var validEmail: Bool = true
    
    var currUser: userModel = userModel()
    
    let loginModel = loginUserDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!

    @IBAction func userLogIn(sender: UIButton) {
        
        let newUserEmail = userEmail.text! as String
        let newUserPassword = userPassword.text! as String
        
        checkUserExists(newUserEmail)
        
        if (!validEmail) {
            let alertController = UIAlertController(title: "Sign In Failed", message: "Invalid Email", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            self.validEmail = true
            return
        }
        
        self.currUser = loginModel.downloadData(newUserEmail)
        
        if (newUserEmail == "" || newUserPassword == "") {
            let alertController = UIAlertController(title: "Sign In Failed", message: "Please enter username and password", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
            
        else if (currUser.password! != newUserPassword) { // check valid password
            let alertController = UIAlertController(title: "Sign In Failed", message: "Invalid Password", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        else { //add user
            
            self.defaults.setInteger(self.currUser.ID!, forKey: "userID")
            
            let alertController = UIAlertController(title: "Success", message: "Sign In Successful", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in self.dismissViewControllerAnimated(true, completion: nil)}))
            self.presentViewController(alertController, animated: true, completion: nil)

        }
        
    }
    
    func checkUserExists(newUserEmail: String) {
        
        let semaphore = dispatch_semaphore_create(0);
                
        let url:NSURL = NSURL(string: "https://dev-student-apps.bowdoin.edu/mobilemeal/checkUserExists.php")!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let data = "a=\(newUserEmail)".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: data, completionHandler:
            {(data,response,error) in
                
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
                let compareString = (NSString(data: data!, encoding: NSUTF8StringEncoding))! as String
                
                print(compareString)
                
                print(compareString.characters.count)
                
                if compareString.characters.count == 12 {
                    
                    self.validEmail = false
                }
                
                dispatch_semaphore_signal(semaphore)

            }
        );
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }
    
}
