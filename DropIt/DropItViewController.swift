//
//  DropItViewController.swift
//  DropIt
//
//  Created by Sophia Ardell on 4/5/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import UIKit

class DropItViewController: UIViewController, UIDynamicAnimatorDelegate {

    //how many squares can be in a row
    var dropsPerRow = 10
    //will intiliaze with init method
    let dropItBehavior = DropItBehavior()
    
    //to keep track of last dropped square so you can grab it
    var lastDroppedView: UIView?
    
    struct Pathnames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    //lazy var doesn't initailize at normal time for class properties to be initialized
    //it's only initialized when someone calls on it
    //this is good for this since we don't need it until views are loaded
    //just don't access animator until gameView is set, e.g. not until viewDidLoad
    lazy var animator : UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    
    //optional since relying on gestures that I use
    var attachment: UIAttachmentBehavior? {
        willSet {
            if attachment != nil {
                animator.removeBehavior(attachment!)
                gameView.setPath(nil, named: Pathnames.Attachment)
            }
        }
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment?.action = { [unowned self] in
                    if let attachedView = self.attachment?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint(self.attachment!.anchorPoint)
                        path.addLineToPoint(attachedView.center)
                        self.gameView.setPath(path, named: Pathnames.Attachment)
                    }
                }
            }
        }
    }
    
    
    //when dynamic animator pauses, this will active
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    
    //calculate size of squares based on how many per row
    //CGSize holds height and width
    var dropSize: CGSize {
        let size = gameView.bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    @IBOutlet weak var gameView: BeizerPathsView!
    
    //when we tap, we want our game to generate a square at the top of
    //randomly one of the 10 colums
    @IBAction func drop(sender: UITapGestureRecognizer) {
        drop()
    }
    
    
    @IBAction func grabDrop(sender: UIPanGestureRecognizer) {
        let gesturePoint = sender.locationInView(gameView)
        
        switch sender.state {
        case .Began:
            if let viewToAttachTo = lastDroppedView {
                attachment = UIAttachmentBehavior(item: viewToAttachTo, attachedToAnchor: gesturePoint)
                lastDroppedView = nil
            }
        case .Changed:
            attachment?.anchorPoint = gesturePoint
        case .Ended:
            attachment = nil
        default:
            break
        }
    }
    
    
    func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        let dropView = UIView(frame: frame)
        dropView.backgroundColor = UIColor.random
        gameView.addSubview(dropView)
        dropItBehavior.addDrop(dropView)
        //to update most recent drop for grabbing purposes
        lastDroppedView = dropView

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///makes sure only adding behaviors once safe since animator lazy var
        animator.addBehavior(dropItBehavior)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = dropSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX - barrierSize.width/2, y: gameView.bounds.midY-barrierSize.height/2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        dropItBehavior.addBarrier(path, named: Pathnames.MiddleBarrier)
        gameView.setPath(path, named: Pathnames.MiddleBarrier)
    }
    
    func removeCompletedRow() {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
        
        repeat {
            dropFrame.origin.y -= dropSize.height
            dropFrame.origin.x = 0
            var dropsFound = [UIView]()
            //start with assumption row is complete, then check
            var rowIsComplete = true
            for _ in 0..<dropsPerRow {
                if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent:  nil) {
                    if hitView.superview == gameView {
                        dropsFound.append(hitView)
                    } else {
                       rowIsComplete = false
                    }
                    dropFrame.origin.x += dropSize.width
                    if rowIsComplete {
                        dropsToRemove += dropsFound
                    }
                }
            }
        } while dropsToRemove.count == 0 && dropFrame.origin.y > 0
        for drop in dropsToRemove {
            dropItBehavior.removeDrop(drop)
        }
        
    }

}


private extension CGFloat {
    //takes biggest number, amount of columns in this case
    static func random(max: Int) -> CGFloat {
        //arc4random turns something into UInt32
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random() % 6 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        case 5: return UIColor.yellowColor()
        case 6: return UIColor.brownColor()
        default: return UIColor.blackColor()
        }
    }
}