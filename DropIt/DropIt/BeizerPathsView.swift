//
//  BeizerPathsView.swift
//  DropIt
//
//  Created by Sophia Ardell on 4/5/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import UIKit

class BeizerPathsView: UIView {

    //violates standard for MVC, find better way
    private var bezierPaths = [String:UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String){
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }
    

}
