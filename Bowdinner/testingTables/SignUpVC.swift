//
//  SignUpVC.swift
//  testingTables
//
//  Created by Marcus E. Christiansen on 5/7/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, NSURLSessionDelegate {
    
    var exists:Bool = false

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userFirstName: UITextField!
    @IBOutlet weak var userLastName: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userConfirmPassword: UITextField!
    @IBOutlet weak var userClassYear: UITextField!
    @IBOutlet weak var userMajor: UITextField!
    
    @IBAction func userSignUp(sender: UIButton) {
        
        var validEmail: Bool = true
        let newUserEmail = userEmail.text! as String
        let newUserFirstName = userFirstName.text! as String
        let newUserLastName = userLastName.text! as String
        let newUserPassword = userPassword.text! as String
        let newUserConfirmPassword = userConfirmPassword.text! as String
        let newUserClassYear = userClassYear.text! as String
        let newUserMajor = userMajor.text! as String
        
        checkUserEmail(newUserEmail)
        
        if newUserEmail.rangeOfString("@") == nil {
            validEmail = false
        }
        
        let emailBowdoin = (newUserEmail.characters.split {$0 == "@"}.map { String ($0) }).last
        
        if (newUserEmail == "" || newUserFirstName == "" || newUserLastName == "" || newUserPassword == "" || newUserConfirmPassword == "" || newUserClassYear == "" || newUserMajor == "") {
            let alertController = UIAlertController(title: "Sign Up Failed", message: "No field can be blank", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
            
        else if (!validEmail) {
            let alertController = UIAlertController(title: "Sign Up Failed", message: "Please enter a valid email address", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
            
        else if (emailBowdoin != "bowdoin.edu") {
            let alertController = UIAlertController(title: "Sign Up Failed", message: "Please enter a valid Bowdoin email address", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        else if (newUserPassword != newUserConfirmPassword) {
            let alertController = UIAlertController(title: "Sign Up Failed", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
            
        else if (exists == true) {
            let alertController = UIAlertController(title: "Sign Up Failed", message: "Email address already in use", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        else { //add user
            
            addUser(newUserEmail, newUserFirstName: newUserFirstName, newUserLastName: newUserLastName, newUserPassword: newUserPassword, newUserClassYear: newUserClassYear, newUserMajor: newUserMajor)
            
            let alertController = UIAlertController(title: "Success", message: "Account Created", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in self.dismissViewControllerAnimated(true, completion: nil)}))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func signUpToLogIn(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func checkUserEmail(newUserEmail:String) {
        
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
                
                if (compareString.characters.count != 12) {
                    self.exists = true
                }
                
                dispatch_semaphore_signal(semaphore)

                
            }
        );
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }
    
    func addUser(newUserEmail:String, newUserFirstName:String, newUserLastName:String, newUserPassword:String, newUserClassYear:String, newUserMajor:String) {
        
        let url:NSURL = NSURL(string: "https://dev-student-apps.bowdoin.edu/mobilemeal/addNewUser.php")!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let data = "a=\(newUserEmail)&b=\(newUserPassword)&c=\(newUserFirstName)&d=\(newUserLastName)&e=\(newUserClassYear)&f=\(newUserMajor)".dataUsingEncoding(NSUTF8StringEncoding)
        
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
