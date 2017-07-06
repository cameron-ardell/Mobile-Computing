//
//  HappinessView.swift
//  Happiness
//
//  Created by Sophia Ardell on 2/11/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import UIKit


protocol HappinessViewDataSource: class {
    func smilinessForHappinessView(sender: HappinessView) -> Double?
}


@IBDesignable
class HappinessView: UIView {
    
    weak var dataSource: HappinessViewDataSource?

    var faceCenter : CGPoint {
        return convertPoint(center, fromView: superview) // center is in my superview's coordinate system
    }
    
    var faceRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) * scale / 2
    }
    
    
    @IBInspectable var lineWidth : CGFloat = 3 { didSet { setNeedsDisplay() } }
    
    @IBInspectable var color : UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    
    @IBInspectable var scale: CGFloat = 0.40 { didSet { setNeedsDisplay() } }
    
    
    
    private struct Scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
        static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMouthWidthRatio: CGFloat = 1
        static let FaceRadiusToMouthHeightRatio: CGFloat = 3
        static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
    }
    
    private enum Eye { case Left, Right }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    
    private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath {
        let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
        let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
        let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
        
        let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight
        
        let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticalOffset)
        let end = CGPoint(x: start.x + mouthWidth, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    
    private func bezierPathForEye(whichEye: Eye) -> UIBezierPath {
        let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetRatio
        let eyeHorizontalOffset = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeVerticalOffset
        switch whichEye {
        case .Left: eyeCenter.x -= eyeHorizontalOffset / 2
        case .Right: eyeCenter.x += eyeHorizontalOffset / 2
        }
        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.lineWidth = lineWidth
        return path
    }
    
    
    // Only override drawRect: if you perform custom drawing,
    // An empty implementation adversely affects performance during animation
    override func drawRect(rect: CGRect) {
        //Drawing code
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        
        facePath.lineWidth =  lineWidth
        color.set()
        facePath.stroke()
        
        bezierPathForEye(.Left).stroke()
        bezierPathForEye(.Right).stroke()
        
        let smilePercent = dataSource?.smilinessForHappinessView(self) ?? 0.0
        let smilePath = bezierPathForSmile(smilePercent)
        smilePath.stroke()
    }
    
}
