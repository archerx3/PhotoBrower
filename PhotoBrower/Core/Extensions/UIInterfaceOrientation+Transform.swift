//
//  UIInterfaceOrientation+Transform.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//


extension UIInterfaceOrientation {
    
    func by(transforming transform: CGAffineTransform) -> UIInterfaceOrientation {
        let angle: Float = atan2f(Float(transform.b), Float(transform.a))
        var multiplier: Int = Int(roundf(angle / (Float.pi / 2)))
        var orientation = self
        
        if multiplier < 0 {
            while multiplier < 0 {
                switch orientation {
                case .landscapeLeft:
                    orientation = .portraitUpsideDown
                case .landscapeRight:
                    orientation = .portrait
                case .portraitUpsideDown:
                    orientation = .landscapeRight
                default:
                    orientation = .landscapeLeft
                }
                
                multiplier += 1
            }
        } else if multiplier > 0 {
            while multiplier > 0 {
                switch orientation {
                case .landscapeLeft:
                    orientation = .portrait
                case .landscapeRight:
                    orientation = .portraitUpsideDown
                case .portraitUpsideDown:
                    orientation = .landscapeLeft
                default:
                    orientation = .landscapeRight
                }
                
                multiplier -= 1
            }
        }
        
        return orientation
    }
    
}
