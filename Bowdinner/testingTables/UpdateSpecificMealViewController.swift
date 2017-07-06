//
//  UpdateSpecificMealViewController.swift
//  testingTables
//
//  Created by Sophia M. Ardell on 5/16/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class UpdateSpecificMealViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, NSURLSessionDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var userID: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DiningChoice.dataSource = self
        DiningChoice.delegate = self
        updatePlan()
        
        inviteLabel.setTitle(typeOfInvite, forState: UIControlState.Normal)
        
        inviteLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        inviteLabel.titleLabel?.textAlignment = .Center
        
        beginTime.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        endTime.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        beginTime.datePickerMode = .Time
        endTime.datePickerMode = .Time
        
        
        beginTime.backgroundColor = UIColor(red: 107/255.0, green: 183/255.0, blue: 255/255.0, alpha: 1)
        endTime.backgroundColor = UIColor(red: 107/255.0, green: 183/255.0, blue: 255/255.0, alpha: 1)
        DiningChoice.backgroundColor = UIColor(red: 107/255.0, green: 183/255.0, blue: 255/255.0, alpha: 1)
        
        timeFormatter.dateFormat = "h:mm a"
        
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        timeFormatter.AMSymbol = "AM"
        timeFormatter.PMSymbol = "PM"
        
        currentTime = timeFormatter.stringFromDate( NSDate() )
        plan[0] = currentTime
        plan[1] = currentTime
        
        updatePlan()

    }
    
    override func viewDidAppear(animated: Bool) {
        let userAnyObject = defaults.objectForKey("userID")!
        userID = (userAnyObject as! NSNumber) as Int
    }
    
    
    //
    // MARK - all the random variables
    //
    var typeOfInvite: String = "Set Meal "
    let timeFormatter = NSDateFormatter()
    var currentTime: String = ""
    var finalTime: String = ""
    let diningData = ["Moulton", "Thorne", "Pub", "either dining hall"]
    var plan: [String] = ["11:45 PM","11:45 PM","Moulton"]
    var user_ID: Int = Int()
    var available: Int = Int()
    var mealNumber: Int = Int()
    var finalLocation: String = ""
    
    func updateTimes() {
        //only update if end time is later
        if (beginTime.date.compare(endTime.date)) != NSComparisonResult.OrderedDescending {
            plan[0] = timeFormatter.stringFromDate(beginTime.date)
            plan[1] = timeFormatter.stringFromDate(endTime.date)
            updatePlan()
        }
        
        else {
            let alertController = UIAlertController(title: "Time traveling?", message: "Call us close-minded, but we only allow begin and end times that occur in the traditional order.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func availability(sender: UISwitch) {
        if sender.on {
            available = 1
            updatePlan()
        } else {
            available = 0
            currentPlan.text = "Unavailable"
        }
    }
    
    @IBOutlet weak var DiningChoice: UIPickerView!
    
    @IBOutlet weak var beginTime: UIDatePicker!
    @IBAction func beginTimeAction(sender: AnyObject) {
        updateTimes()
    }
    
    @IBOutlet weak var endTime: UIDatePicker!
    @IBAction func endTimeAction(sender: AnyObject) {
        updateTimes()
    }
    
    @IBOutlet weak var inviteLabel: UIButton!
    @IBAction func sendInvite(sender: AnyObject) {
        //this will make you a single time string so you don't need to worry about the seperate times issue
        convertBeginAndEndToString()
        
        //made this in case you needed a function. I also added your code from the old status setter at bottom
        updateServer()
        
        let alertController = UIAlertController(title: "Success", message: "Status Updated", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
       
    }
    
    func convertBeginAndEndToString() {
        finalTime = "\(plan[0]) to \(plan[1])"
        
        finalLocation = "\(plan[2])"
    }
    
    
    @IBOutlet weak var currentPlan: UILabel!
    
    func updatePlan() {
        
        if available == 1 {
            currentPlan.text = "Dining Location: " + plan[2] +
                "\nBegin time: " + plan[0]
                + "\nEnd time: " + plan[1]
        }
    }
    
    
    // MARK: - Delegates and data sources
    
    //data sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return diningData.count
    }
    
    //delegates
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let titleData = diningData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        plan[2] = diningData[row]
        updatePlan()
    }

    func updateServer() {
        
        var url:NSURL = NSURL()
        
        if (self.mealNumber == 1) {
            url = NSURL(string: "https://dev-student-apps.bowdoin.edu/mobilemeal/update1.php")!
        }
        else if (self.mealNumber == 2) {
            url = NSURL(string: "https://dev-student-apps.bowdoin.edu/mobilemeal/update2.php")!
        }
        else {
            url = NSURL(string: "https://dev-student-apps.bowdoin.edu/mobilemeal/update3.php")!
        }
        
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let data = "a=\(self.available)&b=\(self.finalTime)&c=\(self.finalLocation)&d=\(self.userID)".dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = session.uploadTaskWithRequest(request, fromData: data, completionHandler:
            {(data,response,error) in
                
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(dataString)
            }
        );
        
        task.resume()
        
    }

    
}