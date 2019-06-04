//
//  AWButton.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation

class AWButton: StateButton {
    public init() {
        super.init(frame: .zero)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        self.controlStateAnimationTimingFunction = CAMediaTimingFunction(name: .linear)
        self.controlStateAnimationDuration = 0.1
        self.setBorderWidth(1.0, for: .normal)
        self.setBorderColor(.white, for: .normal)
        self.setAlpha(1.0, for: .normal)
        self.setAlpha(0.3, for: .highlighted)
        self.setTransformScale(1.0, for: .normal)
        self.setTransformScale(0.95, for: .highlighted)
    }
}
