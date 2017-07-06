//
//  homeModel.swift
//  testingTables
//
//  Created by Marcus E. Christiansen on 5/9/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import Foundation

//protocol loginUserDataProtocol: class {
//    func itemsDownloaded(user: userModel)
//}

class loginUserDataModel: NSObject, NSURLSessionDataDelegate {
    
    //weak var delegate: loginUserDataProtocol!
    
    var data: NSMutableData = NSMutableData()
    
    let urlPath: String = "https://dev-student-apps.bowdoin.edu/mobilemeal/loginUser.php"
    
    var user = userModel()
    
    func downloadData(userEmail: String) -> userModel {
        
        let semaphore = dispatch_semaphore_create(0);
        
        let url:NSURL = NSURL(string: urlPath)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let data = "a=\(userEmail)".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: data, completionHandler:
            {(data,response,error) -> Void in
                
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 200) {
                    
                    do{
                        
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                        
                        if let users = json["users"] as? [[String: AnyObject]] {
                            
                            for user in users {
                                
                                let newUser = userModel()
                                
                                let ID = (Int((user["id"] as? String)!)!)
                                newUser.ID = ID
                                
                                if let firstName = user["firstName"] as? String {
                                    newUser.firstName = firstName
                                }
                                
                                if let password = user["password"] as? String {
                                    newUser.password = password
                                }
                                
                                if let email = user["email"] as? String {
                                    newUser.email = email
                                }
                                
                                if let lastName = user["lastName"] as? String {
                                    newUser.lastName = lastName
                                }
                                
                                if let year = user["year"] as? String {
                                    newUser.year = year
                                }
                                
                                if let major = user["major"] as? String {
                                    newUser.major = major
                                }
                                
                                if let bio = user["bio"] as? String {
                                    newUser.bio = bio
                                }
                                
                                let status1 = (Int((user["status1"] as? String)!)!)
                                newUser.status1 = status1
                                
                                if let time1 = user["time1"] as? String {
                                    newUser.time1 = time1
                                }
                                if let place1 = user["place1"] as? String {
                                    newUser.place1 = place1
                                }
                                
                                let status2 = (Int((user["status2"] as? String)!)!)
                                newUser.status2 = status2
                                
                                if let time2 = user["time2"] as? String {
                                    newUser.time2 = time2
                                }
                                if let place2 = user["place2"] as? String {
                                    newUser.place2 = place2
                                }
                                
                                let status3 = (Int((user["status3"] as? String)!)!)
                                newUser.status3 = status3
                                
                                if let time3 = user["time3"] as? String {
                                    newUser.time3 = time3
                                }
                                if let place3 = user["place3"] as? String {
                                    newUser.place3 = place3
                                }
                                
                                self.user = newUser
                                
                            }
                            
                        }
                        
                    }catch {
                        print("Error with Json: \(error)")
                        
                    }
                    
                    dispatch_semaphore_signal(semaphore)

                    
                    
                }
                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.delegate.itemsDownloaded(self.user)
//                })
                
            }
                
//                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
//                print(json)
//                
//                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
//                    print("error")
//                    return
//                }
//                
//                let compareString = (NSString(data: data!, encoding: NSUTF8StringEncoding))! as String
//                
//                print(compareString)
//                
//                
//            }
        );
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        return self.user
        
    }
    
}