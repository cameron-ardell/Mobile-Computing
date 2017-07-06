//
//  GraphViewController.swift
//  calculator
//
//  Created by Sophia M. Ardell on 4/24/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    private var brain = CalculatorBrain()
    

    @IBOutlet weak var graphingView: GraphView! {
        didSet {
            graphingView.dataSource = self
            
            //can just add gesture recognizers for first 2 requirements of part 11
            graphingView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphingView, action: "zoom:"))
            graphingView.addGestureRecognizer(UIPanGestureRecognizer(target: graphingView, action: "move:"))
            
            //need to assess number of taps for 11c
            let tap = UITapGestureRecognizer(target: graphingView, action: "center:")
            tap.numberOfTapsRequired = 2
            graphingView.addGestureRecognizer(tap)
            
        }
    }

    
    //evaluate (if possible) based on last math function inputted in calculator
    func y(x: CGFloat) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        if let y = brain.evaluate() {
            return CGFloat(y)
        }
        return nil
    }
    
    /*since calculator brain needs to be private,
     need to get output from calculator using
     program function in brain code to pass it
     between views and into this view's brain*/
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return brain.program
        }
        set {
            brain.program = newValue
        }
    }

}
