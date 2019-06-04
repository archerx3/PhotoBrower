//
//  AWCustomLoadingView.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation
import DRPLoadingSpinner

class AWCustomLoadingView: AWLoadingView {
    
    fileprivate lazy var _indicatorView = DRPLoadingSpinner()
    override var indicatorView: UIView {
        get {
            return _indicatorView
        }
    }
    
    override func startLoading(initialProgress: CGFloat) {
        if _indicatorView.superview == nil {
            self.addSubview(_indicatorView)
            self.setNeedsLayout()
        }
        
        if !_indicatorView.isAnimating {
            _indicatorView.startAnimating()
        }
    }
    
    override func stopLoading() {
        if _indicatorView.isAnimating {
            _indicatorView.stopAnimating()
        }
    }
    
}
