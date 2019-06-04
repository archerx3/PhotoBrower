//
//  AWPhotosTransitionAnimator.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation
import UIKit

class AWPhotosTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let fadeInOutTransitionRatio: Double = 1/3
    
    weak var delegate: AWPhotosTransitionAnimatorDelegate?
    
    let transitionInfo: AWTransitionInfo
    var fadeView: UIView?
    
    init(transitionInfo: AWTransitionInfo) {
        self.transitionInfo = transitionInfo
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionInfo.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError("Override in subclass.")
    }
}

protocol AWPhotosTransitionAnimatorDelegate: class {
    func transitionAnimator(_ animator: AWPhotosTransitionAnimator, didCompletePresentationWith transitionView: UIImageView)
    func transitionAnimator(_ animator: AWPhotosTransitionAnimator, didCompleteDismissalWith transitionView: UIImageView)
    func transitionAnimatorDidCancelDismissal(_ animator: AWPhotosTransitionAnimator)
}
