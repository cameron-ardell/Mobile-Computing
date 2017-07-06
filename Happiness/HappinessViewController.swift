//
//  HappinessViewController.swift
//  Happiness
//
//  Created by Sophia Ardell on 2/11/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import UIKit

class HappinessViewController: UIViewController, HappinessViewDataSource {

    private struct Constants {
        static let HappinessGestureScale: CGFloat = 4
    }
    
    var happiness: Int = 75 { // 0 = Sad, 100 = joyful
        didSet {
            happiness = min(max(happiness, 0), 100)
            updateUI()
        }
    }
    
    @IBAction func changeHappinness(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = sender.translationInView(faceView)
            let happinessChange = -Int(translation.y / Constants.HappinessGestureScale)
            
            if happinessChange != 0 {
                happiness += happinessChange
                sender.setTranslation(CGPointZero, inView: faceView)
            }
        default: break
        }
    }
    
    @IBOutlet weak var faceView: HappinessView! {
        didSet {
            faceView.dataSource = self
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: "scale"))
        }
    }
    
    
    func updateUI(){
        faceView.setNeedsDisplay()
    }
    
    func smilinessForHappinessView(sender: HappinessView) -> Double? {
        return Double(happiness - 50) / 50
    }
}
