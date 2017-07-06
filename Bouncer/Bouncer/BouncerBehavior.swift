//
//  BouncerBehavior.swift
//  Bouncer
//
//  Created by Sophia Ardell on 4/12/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import UIKit

class BouncerBehavior: UIDynamicBehavior {
    
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
    lazy var blockBehavior: UIDynamicItemBehavior = {
        let lazyBlockBehavior = UIDynamicItemBehavior()
        lazyBlockBehavior.allowsRotation = true
        lazyBlockBehavior.elasticity = 0.85
        lazyBlockBehavior.friction = 0
        lazyBlockBehavior.resistance = 0
        return lazyBlockBehavior
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(blockBehavior)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addBlock(block: UIView) {
        //knows about animator it's in
        dynamicAnimator?.referenceView?.addSubview(block)
        gravity.addItem(block)
        collider.addItem(block)
        blockBehavior.addItem(block)
    }
    
    
    //useful to remove things you put in view as well
    func removeBlock(block: UIView) {
        gravity.removeItem(block)
        collider.removeItem(block)
        blockBehavior.removeItem(block)
        //need to get rid of it from the display as well
        //UIView itself knows what it's in, don't need to do referenceVIew
        block.removeFromSuperview()
    }
    


}
