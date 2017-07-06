//
//  BreakoutViewController.swift
//  breakouot
//
//  Created by Sophia M. Ardell on 5/1/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    //how many bricks can be in a row
    var bricksPerRow = 10
    
    //will initialize with init method
    let breakOutBehavior = BreakoutBehavior()
    
    
    //lazy var for animator since we don't need it until views are loaded
    lazy var animator : UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    
    var brickSize: CGSize {
        let size = gameView.bounds.size.width / CGFloat(bricksPerRow)
        //wanted bricks to be rectangular
        return CGSize(width: size, height: size*0.75)
    }
    
    struct Constants {
        //ball constants
        static let BallRadius: CGFloat = 18.0
        static let BallSize: CGFloat = 36.0
        static let BallColor = UIColor.purpleColor()
        
        //paddle constants
        static let PaddleSize: CGSize = CGSize(width: 75.0, height: 20.0)
        static let PaddleCornerRadius: CGFloat = 5.0
        static let PaddleColor = UIColor.cyanColor()
        
        //brick constants
        static let BrickSpacing: CGFloat = 0.05
        static let BrickColumns = 10
        static let BrickRows = 8
        static let BrickTotalWidth: CGFloat = 1.0
        static let BrickTotalHeight: CGFloat = 0.25
    }
    
    struct Pathnames {
        static let GameOver = "GameOver"
        static let PaddlePath = "Paddle"
        
    }
    

    //makes ball pretty
    func makeBall() -> UIView {
        let ball = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.BallSize, height: Constants.BallSize)))
        ball.backgroundColor = Constants.BallColor
        ball.layer.cornerRadius = Constants.BallRadius
        ball.layer.borderColor = UIColor.whiteColor().CGColor
        ball.layer.borderWidth = 2.0
        ball.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        ball.layer.shadowOpacity = 0.5
        return ball
    }
    
    
    //makes paddle pretty
    lazy var paddle: UIView = {
        let paddle = UIView(frame: CGRect(origin: CGPoint(x: -1, y: -1), size: Constants.PaddleSize))
        paddle.backgroundColor = Constants.PaddleColor
        paddle.layer.cornerRadius = Constants.PaddleCornerRadius
        paddle.layer.borderColor = UIColor.whiteColor().CGColor
        paddle.layer.borderWidth = 2.0
        paddle.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        paddle.layer.shadowOpacity = 0.5
        
        
        self.gameView.addSubview(paddle)
        return paddle
        
    }()
    
    
    //brick things
    //would I have lost points if I had named this "bricktionary"?
    private var bricks = [Int: Brick]()
    
    private struct Brick {
        var relativeFrame: CGRect
        var view: UIView
        var action: BrickAction
    }
    
    func layBricks() {
        for (index, brick) in bricks {
            brick.view.frame.origin.x = brick.relativeFrame.origin.x * gameView.bounds.width
            brick.view.frame.origin.y = brick.relativeFrame.origin.y * gameView.bounds.height
            brick.view.frame.size.width = brick.relativeFrame.width * gameView.bounds.width
            brick.view.frame.size.height = brick.relativeFrame.height * gameView.bounds.height
            brick.view.frame = CGRectInset(brick.view.frame, Constants.BrickSpacing, Constants.BrickSpacing)
            breakOutBehavior.addBarrier(UIBezierPath(roundedRect: brick.view.frame, cornerRadius: Constants.BrickCornerRadius), named: index)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakOutBehavior)
        gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addBall:"))
        
        gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panPaddle:"))

       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    

    @IBOutlet weak var gameView: UIView!
    
    
    //potential to add ball when screen is tapped
    func addBall(gesture: UITapGestureRecognizer) {
        
        if gesture.state == .Ended {
            //if there are no balls on the screen, add a ball
            if breakOutBehavior.balls.count == 0 {
                let ball = makeBall()
                placeBall(ball)
                breakOutBehavior.addBall(ball)
            }
            //gives most recently added ball a new random orientation
            breakOutBehavior.pushBall(breakOutBehavior.balls.last!)
        }
    }
    
    //moves paddle when pan gesture is activated
    func panPaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            case .Ended: fallthrough
            case .Changed:
                placePaddle(gesture.translationInView(gameView))
                gesture.setTranslation(CGPointZero, inView: gameView)
            default: break
        }
        
    }
    
    

    

    //puts ball on top of paddle
    func placeBall(ball: UIView) {
        var center = paddle.center
        center.y -= Constants.PaddleSize.height / 2 + Constants.BallRadius
        ball.center = center
    }
    
    //moves paddle around by changing its origin, ideally not moving it off screen
    func placePaddle(change: CGPoint) {
        var paddleOrigin = paddle.frame.origin
        
        /*get whichever value is smaller, new location of paddle's left side or location of paddle's left side
        if it was all the way on the right side of the screen while still being fully visible, which will keep it
        from going off the right side. Then take the maximum of the paddle's new location of its left side and 0 so it
        does not go off the left side of the screen.*/
        paddleOrigin.x = max(min(paddleOrigin.x + change.x, gameView.bounds.maxX - Constants.PaddleSize.width), 0.0)
        
        paddle.frame.origin = paddleOrigin
        //update collision barrier around paddle as well
        addPaddleBarrier()
    }
    
    //puts paddle back in middle of bottom of screen
    func resetPaddle() {
        paddle.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.maxY - Constants.PaddleSize.height)
        addPaddleBarrier()
    }
    
    //puts collision barrier around paddle so ball can react to it
    func addPaddleBarrier() {
        breakOutBehavior.addBarier(named: Pathnames.PaddlePath, path: UIBezierPath(roundedRect: paddle.frame, cornerRadius: Constants.PaddleCornerRadius))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bound = gameView.bounds
        
        //makes sure that by the time the middle of the ball hits the barrier, it's gone
        let rectangle = CGRect(x: bound.minX, y: bound.maxY , width: bound.maxX, height: 0)
        let beizerPath = UIBezierPath(rect: rectangle)
        
        breakOutBehavior.addBarier(named: Pathnames.GameOver, path: beizerPath)
        
        //makes sure ball doesn't get lost as screen is rotating
        for ball in breakOutBehavior.balls {
            if !CGRectContainsRect(gameView.bounds, ball.frame) {
                placeBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
        
        //make sure paddle is in game
        if !CGRectContainsRect(gameView.bounds, paddle.frame) {
            resetPaddle()
        }

    }

}
