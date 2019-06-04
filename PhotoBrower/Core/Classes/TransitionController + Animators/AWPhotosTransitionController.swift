//
//  AWPhotosTransitionController.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation
import UIKit

import FLAnimatedImage

class AWPhotosTransitionController: NSObject, UIViewControllerTransitioningDelegate, AWPhotosTransitionAnimatorDelegate {
    
    fileprivate static let supportedModalPresentationStyles: [UIModalPresentationStyle] =  [.fullScreen,
                                                                                            .currentContext,
                                                                                            .custom,
                                                                                            .overFullScreen,
                                                                                            .overCurrentContext]
    
    weak var delegate: AWPhotosTransitionControllerDelegate?
    
    /// Custom animator for presentation.
    fileprivate var presentationAnimator: AWPhotosPresentationAnimator?
    
    /// Custom animator for dismissal.
    fileprivate var dismissalAnimator: AWPhotosDismissalAnimator?
    
    /// If this flag is `true`, the transition controller will ignore any user gestures and instead trigger an immediate dismissal.
    var forceNonInteractiveDismissal = false
    
    /// The transition configuration passed in at initialization. The controller uses this object to apply customization to the transition.
    let transitionInfo: AWTransitionInfo
    
    fileprivate var supportsContextualPresentation: Bool {
        get {
            return (self.transitionInfo.startingView != nil)
        }
    }
    
    fileprivate var supportsContextualDismissal: Bool {
        get {
            return (self.transitionInfo.endingView != nil)
        }
    }
    
    fileprivate var supportsInteractiveDismissal: Bool {
        get {
            return self.transitionInfo.interactiveDismissalEnabled
        }
    }
    
    init(transitionInfo: AWTransitionInfo) {
        self.transitionInfo = transitionInfo
        super.init()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var photosViewController: AWPhotosViewController
        if let dismissed = dismissed as? AWPhotosViewController {
            photosViewController = dismissed
        } else if let childViewController = dismissed.children.filter({ $0 is AWPhotosViewController }).first as? AWPhotosViewController {
            photosViewController = childViewController
        } else {
            assertionFailure("Could not find AWPhotosViewController in container's children.")
            return nil
        }
        
        guard let photo = photosViewController.dataSource.photo(at: photosViewController.currentPhotoIndex) else { return nil }
        
        // resolve transitionInfo's endingView
        self.transitionInfo.resolveEndingViewClosure?(photo, photosViewController.currentPhotoIndex)
        
        if !type(of: self).supportedModalPresentationStyles.contains(photosViewController.modalPresentationStyle) {
            return nil
        }
        
        if !self.supportsContextualDismissal && !self.supportsInteractiveDismissal {
            return nil
        }
        
        self.dismissalAnimator = self.dismissalAnimator ?? AWPhotosDismissalAnimator(transitionInfo: self.transitionInfo)
        self.dismissalAnimator?.delegate = self
        
        return self.dismissalAnimator
    }
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        var photosViewController: AWPhotosViewController
        if let presented = presented as? AWPhotosViewController {
            photosViewController = presented
        } else if let childViewController = presented.children.filter({ $0 is AWPhotosViewController }).first as? AWPhotosViewController {
            photosViewController = childViewController
        } else {
            assertionFailure("Could not find AWPhotosViewController in container's children.")
            return nil
        }
        
        if !type(of: self).supportedModalPresentationStyles.contains(photosViewController.modalPresentationStyle) {
            return nil
        }
        
        if !self.supportsContextualPresentation {
            return nil
        }
        
        self.presentationAnimator = AWPhotosPresentationAnimator(transitionInfo: self.transitionInfo)
        self.presentationAnimator?.delegate = self
        
        return self.presentationAnimator
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !self.supportsInteractiveDismissal || self.forceNonInteractiveDismissal {
            return nil
        }
        
        self.dismissalAnimator = self.dismissalAnimator ?? AWPhotosDismissalAnimator(transitionInfo: self.transitionInfo)
        self.dismissalAnimator?.delegate = self
        
        return self.dismissalAnimator
    }
    
    // MARK: - Interaction handling
    public func didPanWithGestureRecognizer(_ sender: UIPanGestureRecognizer, in viewController: UIViewController) {
        self.dismissalAnimator?.didPanWithGestureRecognizer(sender, in: viewController)
    }
    
    // MARK: - AWPhotosTransitionAnimatorDelegate
    func transitionAnimator(_ animator: AWPhotosTransitionAnimator, didCompletePresentationWith transitionView: UIImageView) {
        self.delegate?.transitionController(self, didCompletePresentationWith: transitionView)
        self.presentationAnimator = nil
    }
    
    func transitionAnimator(_ animator: AWPhotosTransitionAnimator, didCompleteDismissalWith transitionView: UIImageView) {
        self.delegate?.transitionController(self, didCompleteDismissalWith: transitionView)
        self.dismissalAnimator = nil
    }
    
    func transitionAnimatorDidCancelDismissal(_ animator: AWPhotosTransitionAnimator) {
        self.delegate?.transitionControllerDidCancelDismissal(self)
        self.dismissalAnimator = nil
    }
    
}

protocol AWPhotosTransitionControllerDelegate: class {
    func transitionController(_ transitionController: AWPhotosTransitionController, didCompletePresentationWith transitionView: UIImageView)
    func transitionController(_ transitionController: AWPhotosTransitionController, didCompleteDismissalWith transitionView: UIImageView)
    func transitionControllerDidCancelDismissal(_ transitionController: AWPhotosTransitionController)
}
