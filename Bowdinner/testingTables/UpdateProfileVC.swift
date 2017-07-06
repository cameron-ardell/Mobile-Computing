//
//  UpdateProfileVC.swift
//  testingTables
//
//  Created by Sophia M. Ardell on 5/10/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class UpdateProfileVC: UIViewController, NSURLSessionDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var userID: Int = Int()
    
    @IBOutlet weak var userNewPassword: UITextField!
    @IBOutlet weak var userConfirmNewPassword: UITextField!
    @IBOutlet weak var userNewClassYear: UITextField!
    @IBOutlet weak var userNewMajor: UITextField!
    @IBOutlet weak var userNewBio: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        let userAnyObject = defaults.objectForKey("userID")!
        userID = (userAnyObject as! NSNumber) as Int
    }
    
    @IBAction func backToMain(sender: UIButton) {
        
        let newPassword = userNewPassword.text! as String
        let newConfirmPassword = userConfirmNewPassword.text! as String
        let newClassYear = userNewClassYear.text! as String
        let newMajor = userNewMajor.text! as String
        let newBio = userNewBio.text! as String
        
        if (newPassword == "" || newConfirmPassword == "" || newClassYear == "" || newMajor == "") {
            let alertController = UIAlertController(title: "Sign Up Failed", message: "No field but the bio can be blank", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        else if (newPassword != newConfirmPassword) {
            let alertController = UIAlertController(title: "Sign Up Failed", message: "Passwords Must Match", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        else {
            
            updateProfile(newPassword, newClassYear: newClassYear, newMajor: newMajor, newBio: newBio)
            
            let alertController = UIAlertController(title: "Success", message: "Profile Changed", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in
                let presentingVC = self.presentingViewController
                self.dismissViewControllerAnimated(true, completion: {
                    presentingVC!.dismissViewControllerAnimated(false, completion: {})
                })
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    func updateProfile(newPassword: String, newClassYear: String, newMajor: String, newBio: String) {
        
        let url:NSURL = NSURL(string: "https://dev-student-apps.bowdoin.edu/mobilemeal/updateInfo.php")!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let data = "a=\(newPassword)&b=\(newClassYear)&c=\(newMajor)&f=\(newBio)&e=\(self.userID)".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: data, completionHandler:
            {(data,response,error) in
                
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
            }
        );
        
        task.resume()
        
    }
        
}
