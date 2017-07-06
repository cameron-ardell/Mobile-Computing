//
//  DropItBehavior.swift
//  DropIt
//
//  Created by Sophia Ardell on 4/5/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import UIKit

class DropItBehavior: UIDynamicBehavior {
    //UI gravity behavior, already exists in iOS
    let gravity = UIGravityBehavior()
    lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        
        //basically saying the outer edge of the view is a boundary
        //this is why we made it lazy, since we needed to know what those boundaries were first
        lazyCollider.translatesReferenceBoundsIntoBoundary = true
        return lazyCollider
    }()
    
    //item that has properties that are settable
    lazy var dropBehavior: UIDynamicItemBehavior = {
        let lazyDropBehavior = UIDynamicItemBehavior()
        lazyDropBehavior.allowsRotation = true
        lazyDropBehavior.elasticity = 0.75
        return lazyDropBehavior
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(dropBehavior)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addDrop(drop: UIView) {
        //knows about animator it's in
        dynamicAnimator?.referenceView?.addSubview(drop)
        gravity.addItem(drop)
        collider.addItem(drop)
        dropBehavior.addItem(drop)
    }
    
    
    //useful to remove things you put in view as well
    func removeDrop(drop: UIView) {
        gravity.removeItem(drop)
        collider.removeItem(drop)
        dropBehavior.removeItem(drop)
        //need to get rid of it from the display as well
        //UIView itself knows what it's in, don't need to do referenceVIew
        drop.removeFromSuperview()
    }
    
   
}
