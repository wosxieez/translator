//
//  CircleView.swift
//  Translator
//
//  Created by coco on 13/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class CircleView: UIView
{
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect)
    {
        let radius:CGFloat = bounds.width / 2;
        print(radius, center);
        
        UIColor.white.set();
        let path:UIBezierPath = UIBezierPath();
        path.lineWidth = 2;
        path.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius - 5, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true);
        path.stroke();
        
        UIColor.white.set();
        let path2:UIBezierPath = UIBezierPath();
        path2.lineWidth = 4;
        path2.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius - 10, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true);
        path2.stroke();
        
    }
    
}
