//
//  GraphView.swift
//  calculator
//
//  Created by Sophie Ardell on 4/26/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import UIKit

//gives a y value given a x value
protocol GraphViewDataSource: class {
    func y(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    //basically just put this in because there was something similar in Professor
    weak var dataSource: GraphViewDataSource?
    
    //set scale to a value I thought seemed good initially
    @IBInspectable var scale: CGFloat = 50.0 { didSet { setNeedsDisplay() } }
    
    //more generic constants!
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    var color: UIColor = UIColor.cyanColor() { didSet { setNeedsDisplay() } }
    
    //make origin variable point on screen
    var origin: CGPoint = CGPoint() {
        //once origin is assigned, set that origin has not been reset, and redraw graph
        didSet {
            resetOrigin = false
            setNeedsDisplay()
        }
    }
    
    //indicator that origin has shifted
    private var resetOrigin: Bool = true {
        //if origin has been be reassigned, redraw picture
        didSet {
            if resetOrigin {
                setNeedsDisplay()
            }
        }
    }

    //keeping things vague so every time things are reset, axes still work
    //runs once view is established
    override func drawRect(rect: CGRect) {
        //if origin hasn't been set another way (like by a gesture), make it the center
        if resetOrigin {
            origin = center
        }
        
        //calls AxesDraw function generically
        AxesDrawer(contentScaleFactor: contentScaleFactor)
            .drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
        
        //now need to draw the actual function from calculator
        /*need to create path with color and width, then go over all the pixels based on function
         and how axes are currently set and current scale*/
        color.set()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        
        var firstVal = true
        var point = CGPoint()
        
        //go through all possible x values in graph
        for index in 0...Int(bounds.size.width * contentScaleFactor) {
            
            //adjust x coordinate for scale
            point.x = CGFloat(index) / contentScaleFactor
            
            //get output for y value on graph based on x value relative to origin and scale
            //since that's the actual numerical output (but not where I'll draw it)
            if let y = dataSource?.y((point.x - origin.x) / scale) {
                
                //makes sure function is continuous, and make sure it isn't
                //being flagged as not normal for being 0
                if !y.isNormal && !y.isZero {
                    firstVal = true //since need to redraw line after this
                    continue
                }
                
                //set y-coordinate on grid relative to scale and distance from origin
                point.y = origin.y - y * scale
                
                //need to move to inital point because started with empty UIBezierPath
                if firstVal {
                    firstVal = false
                    path.moveToPoint(point)
                }
                //can just add lines to points after initial point is added
                else {
                    path.addLineToPoint(point)
                }
            }
            
        }
        
        path.stroke()
    }
    
    //
    //gesture detetection
    //
    
    //pinching will just modify scale variable
    func zoom(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    //panning changes coordinate system
    func move(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        //stop tracking panning
        case .Ended: fallthrough
        //need to update origin based on movement0
        case .Changed:
            let translation = gesture.translationInView(self)
            origin.x += translation.x
            origin.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
        
    }
    
    //double tapping will just change origin to that point
    func center(gesture: UITapGestureRecognizer) {
        
        //only move if user is done tapping (ensures double tap)
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
            
        }
    }

}
