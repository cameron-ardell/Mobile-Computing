//
//  BreakoutBehavior.swift
//  breakouot
//
//  Created by Sophia M. Ardell on 5/1/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {

    //initalizing gravity with already existing version in iOS
    let gravity = UIGravityBehavior()
    
    lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        
        //every time balls move, check to see if one hit the bottom
        lazyCollider.action = {
            for ball in self.balls {
                
                //if a ball hit the bottom, remove it
                if CGRectIntersectsRect(ball.frame, self.collider.boundaryWithIdentifier("GameOver")!.bounds) {
                    self.removeBall(ball)
                }
                
            }
        }
        
        
        //makes outer edges boundaries, but waits until they are initialized
        lazyCollider.translatesReferenceBoundsIntoBoundary = true
        
       
        
        return lazyCollider
    }()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazyBallBehavior = UIDynamicItemBehavior()
        lazyBallBehavior.allowsRotation = false
        lazyBallBehavior.elasticity = 1.0
        lazyBallBehavior.friction = 0
        lazyBallBehavior.resistance = 0
        
        return lazyBallBehavior
    }()
    
    
    override init() {
        super.init()
        //addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
    }
    
    
    func addBall(ball: UIView) {
        //knows about animator it's in
        dynamicAnimator?.referenceView?.addSubview(ball)
        //gravity.addItem(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: UIView) {
        //gravity.removeItem(ball)
        
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        //need to get rid of ball from display too, knows what view it's in
        ball.removeFromSuperview()
    }
    
    //count the amount of balls on screen
    var balls:[UIView] {
        get {
            //makes sure to only return the list length of items that are actually seperate views
            //don't want to count bricks, though I really don't plan to allocate them to this behavior...
            return ballBehavior.items.filter{$0 is UIView}.map{$0 as! UIView}
        }
    }
    
    //adding ball to screen with instaneous behavior (instead of continuous) with random angle
    func pushBall(ball: UIView) {
        let push = UIPushBehavior(items: [ball], mode: .Instantaneous)
        push.magnitude = 1.0
        
        push.angle = CGFloat(Double(arc4random()) * M_PI * 2 / Double(UINT32_MAX))
        
        //action is weak so it will be released
        //removes effect immediately after finishing
        push.action = { [weak push] in
            if !push!.active {
                self.removeChildBehavior(push!)
            }
        }
        addChildBehavior(push)
    }
    
    //adds barier for both when the game is lost, and for the paddle (both need collision detectors)
    func addBarier(named name: NSCopying, path: UIBezierPath) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
}
