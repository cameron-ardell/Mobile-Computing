//
//  BreakoutViewController.swift
//  breakouot
//
//  Created by Sophia M. Ardell on 5/1/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
    
    
    //will initialize with init method
    let breakOutBehavior = BreakoutBehavior()
    
    //boolean that indicates if game has being restarted manually instead of from win so deleting
    //last brick doesn't trigger the "You won!" alert
    var resetManually : Bool = false;
    
    
    //lazy var for animator since we don't need it until views are loaded
    lazy var animator : UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    
    
    //view that the game loads on
     @IBOutlet weak var gameView: UIView!

    
    //all the breakout numbers needed later
    struct Constants {
        //ball constants
        static var BallRadius: CGFloat = 18.0
        static var BallSize: CGFloat = 36.0
        static let BallColor = UIColor.cyanColor()
        
        //paddle constants
        static var PaddleSize: CGSize = CGSize(width: 100.0, height: 20.0)
        static let PaddleCornerRadius: CGFloat = 5.0
        static let PaddleColor = UIColor.blueColor()
        
        //brick constants
        static let BrickVerticalSpacing: CGFloat = 0.05
        static let BrickSpacing: CGFloat = 5.0
        static let BrickColumns = 3
        static let BrickRows = 3
        //picked width and height based on what seemed like a good ratio
        static let BrickTotalWidth: CGFloat = 1.0
        static let BrickTotalHeight: CGFloat = 0.33
        static let BrickCornerRadius: CGFloat = 2.5
         static let BrickColors = [ UIColor.greenColor(), UIColor.magentaColor(), UIColor.orangeColor()]
        
        //power up constants
        static let PowerUpRadius: CGFloat = 12.0
        static let PowerUpSize: CGFloat = 24.0
        static let PowerUpColor = UIColor.yellowColor()
    }
    
    
    //names for beizer path drawings
    struct Pathnames {
        static let GameOver = "GameOver"
        static let PaddlePath = "Paddle"
        static let PowerUpPath = "PowerUp"
        
    }
    
    
    //
    //
    // MARK - drawing parts of the game
    //
    //

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
    
    
    //make power up symbol pretty (power up symbols drop from special bricks when hit)
    func makePowerUp() -> UIView {
        let powerUp = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.PowerUpSize, height: Constants.PowerUpSize)))
        powerUp.backgroundColor = Constants.PowerUpColor
        powerUp.layer.cornerRadius = Constants.PowerUpRadius
        powerUp.layer.borderColor = UIColor.whiteColor().CGColor
        powerUp.layer.borderWidth = 2.0
        powerUp.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        powerUp.layer.shadowOpacity = 0.5
        return powerUp
    }
    
    
    
    
    //
    //
    // MARK - brick things
    //
    //
    
    //would I have lost points if I had named this "bricktionary"?
    //..anyways, it has all the bricks in it
    private var bricks = [Int: Brick]()
    
    //making the brick objects
    private struct Brick {
        //bricks can store information about themselves without retaining information about screen
        var relativeFrame: CGRect
        var view: UIView
        var action: BrickAction
    }
    
    //leaves space to do other things to the bricks
    private typealias BrickAction = ((Int) -> Void)?
    
    
    //generic function to place bricks in any size phone, regardless of orientation and keeps scale, makes sure barrier
    //moves with them (plus keeps fun rounded edges)
    //this assumes the view has already loaded and brick objects exist in the already relatively correct positions,
    // (so this is really just a scaling function)
    func layBricks() {
        //goes over dictionary using key-list pairs
        for (index, brick) in bricks {
            brick.view.frame.origin.x = brick.relativeFrame.origin.x * gameView.bounds.width
            brick.view.frame.origin.y = brick.relativeFrame.origin.y * gameView.bounds.height
            brick.view.frame.size.width = brick.relativeFrame.width * gameView.bounds.width
            brick.view.frame.size.height = brick.relativeFrame.height * gameView.bounds.height
            brick.view.frame = CGRectInset(brick.view.frame, Constants.BrickSpacing, Constants.BrickSpacing)
            breakOutBehavior.addBarrier(named: index, path: UIBezierPath(roundedRect: brick.view.frame, cornerRadius: Constants.BrickCornerRadius))
        }
    }
   
    
    //sets up bricks if none are loaded
    func addBricks() {
        
        var action: BrickAction = nil
        
       // var colorIndex: Int = 0
        
        //if there are still bricks on the screen, don't add more
        if bricks.count > 0 { return }
        
        //how much to adjust each brick from the last one if the row or column changed
        let dX = Constants.BrickTotalWidth / CGFloat(Constants.BrickColumns)
        let dY = Constants.BrickTotalHeight / CGFloat(Constants.BrickRows)
        
        //layout for each brick
        var frame = CGRect(origin: CGPointZero, size: CGSize(width: dX, height: dY))
        
        //goes through every row and column of bricks
        for row in 0...Constants.BrickRows-1 {
            for column in 0...Constants.BrickColumns-1 {
                
                frame.origin.x = dX * CGFloat(column)
                frame.origin.y = dY * CGFloat(row) + Constants.BrickVerticalSpacing
                
                //now have everything needed to make a view
                let brick = UIView(frame: frame)
                
                //now just need to make brick view look good
                brick.backgroundColor = Constants.BrickColors[row % Constants.BrickColors.count]
                brick.layer.cornerRadius = Constants.BrickCornerRadius
                brick.layer.borderColor = UIColor.whiteColor().CGColor
                brick.layer.borderWidth = 1.0
                
                //potentially change brick to be one with power up
                let random1 = Int(arc4random_uniform(6))
                let random2 = Int(arc4random_uniform(6))
                
                //yellow brick color indicates will give power up
                if random1 == random2 {
                    brick.backgroundColor = UIColor.yellowColor()
                }
                
                //add new brick subview to game
                gameView.addSubview(brick)
                
                //different things that are supposed to happen depending on brick type
                action = { index in
                    
                    //the "easy" brick (1 hit to kill)
                    if brick.backgroundColor == Constants.BrickColors[Constants.BrickColors.count - 1] {
                        self.killBrickAt(index)
                    }
                    //the "hard" brick (3 hits to kill, changes color each hit)
                    else if brick.backgroundColor == Constants.BrickColors[0]{
                        NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(BreakoutViewController.changeHardBrickColor), userInfo: index, repeats: false)
                    }
                    //special brick that will cause power up symbol to fall (1 hit to kill)
                    else if brick.backgroundColor == UIColor.yellowColor(){
                        self.sendPowerUp(index)
                    }
                    //the "medium" bricks (2 hits to kill, changes color after 1 hit)
                    else {
                        NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(BreakoutViewController.changeMediumBrickColor), userInfo: index, repeats: false)
                    }
                }
                
                //make a brick object to add to dictionary
                bricks[row * Constants.BrickColumns + column] = Brick(relativeFrame: frame, view: brick, action: action)
            }
        }
    }
    
    
    
    //changes brick color from hard to medium color
    func changeHardBrickColor(timer: NSTimer) {
        
        //need to make sure item is a brick before animating
        if let index = timer.userInfo as? Int {
            if let brick = bricks[index] {
                UIView.animateWithDuration(0.5, animations: {() -> Void in
                    brick.view.backgroundColor = Constants.BrickColors[1]}, completion: nil)
            }
        }
    }
    
    
    //changes brick from second to last (third) color
    func changeMediumBrickColor(timer: NSTimer) {
        
         //need to make sure item is a brick before animating
        if let index = timer.userInfo as? Int {
            if let brick = bricks[index] {
                UIView.animateWithDuration(0.5, animations: {() -> Void in
                    brick.view.backgroundColor = Constants.BrickColors[2]}, completion: nil)
            }
        }
    }
    
    
    //gets rid of a specific brick
    private func killBrickAt(index: Int) {
        //get rid of barrier around brick
        breakOutBehavior.removeBarrier(named: index)
        
        if let brick = bricks[index] {
            UIView.transitionWithView(brick.view, duration: 0.2, options: .TransitionFlipFromBottom,
                        animations: { brick.view.alpha = 0.0},
                        completion: { (finished: Bool) -> () in
                                        self.breakOutBehavior.removeBrick(brick.view)
                                        brick.view.removeFromSuperview()
                            
                                        //check to see if there's any bricks left (so player won)
                                        if self.bricks.count == 0 && self.resetManually == false {
                                            self.resetGame()
                                        }
            })
        }
        //get rid of brick item in brickionary
        bricks.removeValueForKey(index)
    }
    
    
    //used to control what happens during collisions, really only made this for bricks
    func collisionBehavior(behvior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint ) {
        
        //only bricks have integer identifiers, so only relevant here
        if let index = identifier as? Int {
            
            //if this is a special brick, do that thing instead of dying
            if let action = bricks[index]?.action {
                action(index)
            } else {
                //otherwise, remove the brick
                killBrickAt(index)
            }
        }
    }
    
    
    
    
    //
    //
    // MARK - power up stuff
    //
    //
    
    //before brick is killed, power up token added to game
    func sendPowerUp(index: Int) {
        
        if let brick = bricks[index] {
            if self.breakOutBehavior.powerUps.count == 0 {
                let powerUp = makePowerUp()
                placePowerUp(powerUp, coord: brick.view.frame.origin, index: index)
                breakOutBehavior.addPowerUp(powerUp)
                
                //need to wait to check if the paddle touched the power up symbol since takes a bit to fall
                NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(BreakoutViewController.checkActivation), userInfo: nil, repeats: false)
            }
            else {
                killBrickAt(index)
            }
        }
    }
    
    //spawns power up token where brick died
    func placePowerUp(powerUp: UIView, coord: CGPoint, index: Int) {
        killBrickAt(index)
        powerUp.center = coord
    }
    
    
    //checks if power up ability should be deployed
    func checkActivation(timer: NSTimer) {
        if breakOutBehavior.activatePowerUp == true {
            breakOutBehavior.activatePowerUp = false
            assignPowerUp()
        }
    }
    
    
    //randomly selects one of three possible power up abilities to activate
    func assignPowerUp() {
        let random = Int(arc4random_uniform(3))
        switch random {
        case 0:
            addBall()
        case 1:
            increasePaddle()
        case 2:
            decreasePaddle()
        default: break
        }
    }
    
    
    //power up: adds another ball to game
    func addBall() {
        let ball = makeBall()
        ball.backgroundColor = UIColor.orangeColor()
        placeBall(ball)
        breakOutBehavior.addBall(ball)
        breakOutBehavior.pushBall(breakOutBehavior.balls.last!)
    }
    
    //power up: increases paddle size by 25% unless the paddle is bigger than 45% of the screen
    func increasePaddle() {
        if paddle.frame.size.width <= gameView.bounds.width * 0.45 {
            paddle.frame.size.width *= 1.25
            placePaddle(CGPointZero)
        }
    }
    
    //power up: decreases paddle size by 25% unless the paddle is smaller than 10% of the screen
    func decreasePaddle() {
        if paddle.frame.size.width >= gameView.bounds.width * 0.1 {
            paddle.frame.size.width *= 0.75
            placePaddle(CGPointZero)
        }
    }
    
    
    
    
    //
    //
    // MARK - all of the overrides and game reset alert
    //
    //
    
    //adds animator with programmed behaviors, gestures, adds bricks, creates collision delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakOutBehavior)
        gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BreakoutViewController.addBall(_:))))
        gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(BreakoutViewController.panPaddle(_:))))
        gameView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(BreakoutViewController.restartGame(_:))))
        addBricks()
        breakOutBehavior.brickCollisionDelegate = self
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    
    //add the frame that detects the paddle missed ball, makes sure ball is present, paddle is present,
    //then adjust brick views to specific screen
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bound = gameView.bounds
        
        //makes sure that by the time the middle of the ball hits the barrier, it's gone
        let rectangle = CGRect(x: bound.minX, y: bound.maxY , width: bound.maxX, height: 0)
        let beizerPath = UIBezierPath(rect: rectangle)
        //adds game over detector
        breakOutBehavior.addBarrier(named: Pathnames.GameOver, path: beizerPath)
        
        
        //makes sure ball doesn't get lost as screen is rotating
        for ball in breakOutBehavior.balls {
            if !CGRectContainsRect(gameView.bounds, ball.frame) {
                placeBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
        

        //area over which it is okay to have the paddle
        let whereIsPaddle = CGRect(x: 0, y: bound.maxY - BreakoutViewController.Constants.PaddleSize.height , width: bound.maxX, height: BreakoutViewController.Constants.PaddleSize.height)
        
        
        //make sure paddle is in game
        if !CGRectContainsRect(whereIsPaddle, paddle.frame) {
            resetPaddle()
        }
        
        //makes sure bricks (and their barriers) have the latest orientation
        layBricks()
 
    }
    
    
    //if player has beat the game
    func resetGame() {
        
        //don't want balls or anymore power ups
        for ball in breakOutBehavior.balls {
            breakOutBehavior.removeBall(ball)
        }
        for powerUps in breakOutBehavior.powerUps {
            breakOutBehavior.removePowerUp(powerUps)
        }
        
        //creates the single action for the alert (restarting the game)
        let playAgain = UIAlertAction(title: "Play Again?", style: .Default, handler:  { (action) in
            self.addBricks()
            self.paddle.frame.size.width = Constants.PaddleSize.width
            self.placePaddle(CGPointZero)
        })
        
        //creates actual alert with prompt, don't need any actions after
        let alert = UIAlertController(title: "You won!", message: "", preferredStyle: .Alert)
        alert.addAction(playAgain)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    //if player wants to restart and/or pause the game, can do by doing a long tap on the device
    func restartGame(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .Ended {
            
            //makes balls stop moving while game is paused
            self.breakOutBehavior.ballBehavior.anchored = true
            //this only works if animation hasn't started
            self.breakOutBehavior.powerUpBehavior.anchored = true
            
            
            //gives user option to restart, which it will do something similar to the resetGame function, but
            //first needs to eliminate the remaining bricks. Otherwise, game is not affected and game resumes
            let tapAlert = UIAlertController(title: "Game Paused", message: "Do you want to restart?", preferredStyle: UIAlertControllerStyle.Alert)
            tapAlert.addAction(UIAlertAction(title: "No", style: .Destructive, handler: nil))
            
            tapAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
                
                self.resetManually = true
                
                for ball in self.breakOutBehavior.balls {
                    self.breakOutBehavior.removeBall(ball)
                }
                for powerUps in self.breakOutBehavior.powerUps {
                    self.breakOutBehavior.removePowerUp(powerUps)
                }
                
                //created var for the loop just in case I create an indexing issue as I delete things
                let oldNumBricks = self.bricks.count
                for i in 0...oldNumBricks {
                    self.killBrickAt(i)
                }
                
                //regular new game features
                self.addBricks()
                self.paddle.frame.size.width = Constants.PaddleSize.width
                self.placePaddle(CGPointZero)
                
                self.resetManually = false
            }))
            //once menu dissappears, balls need to be unanchored either way
            self.presentViewController(tapAlert, animated: true, completion: {
                self.breakOutBehavior.ballBehavior.anchored = false
                self.breakOutBehavior.powerUpBehavior.anchored = false
            })
        }
    }
    

    
    
    
    //
    //
    // MARK - adding ball(s) and paddles to screen
    //
    //
    
    
    //potential to add ball when screen is tapped
    //ball that is on the screen will always recieve a push when tap occurs
    func addBall(gesture: UITapGestureRecognizer) {
        
        if gesture.state == .Ended {
            //if there are no balls on the screen, add a ball
            //also accounts for balls that went out of bounds during rotation
            if breakOutBehavior.balls.count == 0 ||  (breakOutBehavior.balls.count == 1 && (breakOutBehavior.balls.last!.center.x > gameView.bounds.maxX + Constants.BallSize ||
                breakOutBehavior.balls.last!.center.y > gameView.bounds.maxY + Constants.BallSize)) {
                
                //if there was another ball that was off screen, remove it
                if breakOutBehavior.balls.count == 1 {
                    breakOutBehavior.removeBall(breakOutBehavior.balls.last!)
                }
                
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
        paddleOrigin.x = max(min(paddleOrigin.x + change.x, gameView.bounds.maxX - paddle.frame.width), 0.0)
        
        paddle.frame.origin = paddleOrigin
        //update collision barrier around paddle as well
        addPaddleBarrier()
        
    }
    
    
    //puts paddle back in middle of bottom of screen
    func resetPaddle() {
        
        //for when paddle isn't on screen
        if !CGRectContainsRect(gameView.bounds, paddle.frame) {
            paddle.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.maxY - Constants.PaddleSize.height)
        }
        
        //kept having an issue where paddle would float in middle of screen, needed to account for that
        else {
            paddle.center = CGPoint(x: paddle.center.x, y: gameView.bounds.maxY - Constants.PaddleSize.height)
        }
        addPaddleBarrier()
    }
    
    
    //puts collision barrier around paddle so ball can react to it
    func addPaddleBarrier() {
        self.breakOutBehavior.addBarrier(named: Pathnames.PaddlePath, path: UIBezierPath(roundedRect: paddle.frame, cornerRadius: Constants.PaddleCornerRadius))
    }
    


}
