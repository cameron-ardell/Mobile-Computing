//
//  ViewController.swift
//  calculator
//
//  Created by Sophia Ardell on 2/7/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//


import UIKit


class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var Screen: UILabel!
    @IBOutlet weak var history: UILabel!


    var userIsTheMiddleOfTypingANumber = false
    var viewingHistory = true
    
    private var brain = CalculatorBrain()
    
    
    
    //basically copied format from Professor application
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        if let hvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "plot graph":
                    //set title according to if there is anything in the brain description
                    hvc.title = brain.description == "" ? "Graph" :
                        brain.description.componentsSeparatedByString(", ").last
                    //so information can be shared between views
                    hvc.program = brain.program
                default:
                    break
                }
            }
        }
    }

    
    
    @IBAction func Digit(sender: UIButton) {
        let number = sender.currentTitle!
        
        //cocatenate if already typing number
        if userIsTheMiddleOfTypingANumber{
            
            /*if the button pressed is a . and there isn't already a . include it in the
            display value, or if the button pressed isn't a ., include it. If pi is pressed
            then it shouldn't be included if someone is already in the middle of typing*/
            if (number == "." && Screen.text?.rangeOfString(".")  == nil) || (number != "." ) {
                Screen.text = Screen.text! + number
            }
            
        }
        // otherwise, establish as new number
        else {
            if number != "."{
                Screen.text = number
            }
            //accounts for values between 0 and 1 so looks better on screen
            else {
                Screen.text = "0."
            }
            
            userIsTheMiddleOfTypingANumber = true
            //makes sure history shows most recent version
            history.text = brain.description != "?" ? brain.description : ""
        }

    }
    
    //deletes last character in display text
    @IBAction func backspace(sender: UIButton) {
        
        //get displayText
        if let displayText = Screen.text {
            
            /*if the current digit is negative and there is still at least one character besides negative sign,
            or not all characters were deleted yet*/
            if ((displayText.characters.count > 1) && (displayText.rangeOfString("-") != nil) ) || (!displayText.isEmpty) {
                
                //Screen.text!.removeAtIndex(Screen.text!.endIndex.predecessor())
                Screen.text = String(Screen.text!.characters.dropLast())
                
                //if number was negative and deleted everything but negative symbol, or all the characters were cleared
                if ((Screen.text!.characters.count == 1) && (Screen.text!.rangeOfString("-") != nil)) || Screen.text!.isEmpty {
                    Screen.text = ""
                } else {
                    userIsTheMiddleOfTypingANumber = true
                }
                
            }
        
        }
        
    }
    
    
    //deletes all history and resets calculator
    @IBAction func Clear(sender: UIButton) {
        
        displayValue = nil
        
        brain.killEverything()
        
        history.text = "No history."
    }
    
  
    
    
    //for all mathematical operations
    @IBAction func Operation(sender: UIButton) {
        
        if let operation = sender.currentTitle {
        
            addToHistory(operation)
            
            if userIsTheMiddleOfTypingANumber {
                
                Enter()
                 
                //don't know if this block needed since made into unary operator
                if operation == "±" {
                    let displayText = Screen.text!
                    if displayText.rangeOfString("-") != nil {
                        Screen.text = String(Screen.text!.characters.dropFirst())
                    } else {
                        Screen.text = "-" + displayText
                    }
                    return
                }
                
                
            }
            if let result = brain.performOperation(operation) {
                displayValue = result
                addToHistory(String(displayValue!))
            } else {
                displayValue = nil
            }
        }
    
    }

    //to save what is on display value as a variable
    @IBAction func SaveVariable(sender: UIButton) {
        
        //set new symbol for variable as last item in button pushed
        //good for both M, and general applications
        if let variable = (sender.currentTitle!).characters.last {
            
            //if the value is valid, store it as a variable
            if displayValue != nil {
                brain.setVariable("\(variable)", value: displayValue!)
                
                //evaluate brain as instructions specified
                if let result = brain.evaluate() {
                    displayValue = result
                } else {
                    displayValue = nil
                }
            }
        }
        //reset userIsTheMiddleOfTypingANumber, as instructions specified
        userIsTheMiddleOfTypingANumber = false
    }
    
    
    //puts variable onto the stack, regardless if it is defined
    @IBAction func pushVariable(sender: UIButton) {
        if userIsTheMiddleOfTypingANumber {
            Enter()
        }
        if let result = brain.pushOperand(sender.currentTitle!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    
    
    

    //adds item to history and operand stack, updates display value
    @IBAction func Enter() {
        userIsTheMiddleOfTypingANumber = false
        
        if displayValue != nil {
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        
        addToHistory(String(displayValue!))

    }
    
    //adds to history display label
    func addToHistory(value: String) {
        //if no items inputted to calculator yet
        if history.text! == "No history." {
            history.text = value
        }
        //otherwise add item to history
        else {
            history.text = history.text! + " " + value
        }
    }
    
    
    
    
    //to change display value
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(Screen.text!)?.doubleValue
        }
        set {
            //since I set things to nil in a lot of places if intended function doesn't work
            if (newValue != nil) {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = .DecimalStyle
                //just because screen is only so big
                numberFormatter.maximumSignificantDigits = 10
                Screen.text = numberFormatter.stringFromNumber(newValue!)
                
            } else {
                Screen.text = " "
            }
            
            userIsTheMiddleOfTypingANumber = false
            history.text = brain.description + " ="
        }
    }


}

