//
//  UIView+Animations.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    class func animateCornerRadii(withDuration duration: TimeInterval, to value: CGFloat, views: [UIView], completion: ((Bool) -> Void)? = nil) {
        assert(views.count > 0, "Must call `animateCornerRadii:duration:value:views:completion:` with at least 1 view.")
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?(true)
        }
        
        for view in views {
            view.layer.masksToBounds = true
            
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.fromValue = view.layer.cornerRadius
            animation.toValue = value
            animation.duration = duration
            
            view.layer.add(animation, forKey: "CornerRadiusAnim")
            view.layer.cornerRadius = value
        }
        
        CATransaction.commit()
    }
    
}
