//
//  RandomizeViewController.swift
//  testingTables
//
//  Created by Sophia M. Ardell on 5/2/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class RandomizeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DiningChoice.dataSource = self
        DiningChoice.delegate = self
        updatePlan()
        
        inviteLabel.setTitle(typeOfInvite, forState: UIControlState.Normal)
        
        inviteLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        
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
        
        

        // Do any additional setup after loading the view.
    }
    
    var typeOfInvite: String = "Randomize!"
    let timeFormatter = NSDateFormatter()
    var currentTime: String = "fuck this"

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
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
    
    
    let diningData = ["Moulton", "Thorne", "Pub", "either dining hall"]
    
    var plan: [String] = ["11:45 PM","11:45 PM","Moulton","1"]
    
    
    @IBOutlet weak var DiningChoice: UIPickerView!
    
    
    @IBOutlet weak var beginTime: UIDatePicker!
    @IBAction func beginTimeAction(sender: AnyObject) {
    
       updateTimes()
        
        
    }
    
    
    @IBOutlet weak var endTime: UIDatePicker!
    @IBAction func endTimeAction(sender: AnyObject) {
        updateTimes()
        
  
    }
    
    
    @IBOutlet weak var stepperValue: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBAction func stepperAction(sender: AnyObject) {
        stepperValue.text = "\(Int(stepper.value))"
        plan[3] = stepperValue.text!
        updatePlan()
    }
    
    
    
    @IBOutlet weak var inviteLabel: UIButton!
    @IBAction func sendInvite(sender: AnyObject) {
        actualSend()
    }
   
    func actualSend() -> [String] {
        return plan
    }
   
    
    
    @IBOutlet weak var currentPlan: UILabel!
    
    func updatePlan() {
        currentPlan.text = "Dining Location: " + plan[2] +
            "\nBegin time: " + plan[0]
            + "\nEnd time: " + plan[1] + "\nMax people: "
            + plan[3]
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
    
    
 

}
