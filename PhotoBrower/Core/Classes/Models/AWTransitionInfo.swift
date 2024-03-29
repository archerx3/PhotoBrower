//
//  AWTransitionInfo.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

open class AWTransitionInfo: NSObject {
    
    /// This value determines whether or not the user can dismiss the `PhotosViewController` by panning vertically.
    fileprivate(set) var interactiveDismissalEnabled: Bool = true
    
    /// The view the the transition controller should use for contextual animation during the presentation.
    /// If the reference view that is provided is not currently visible, contextual animation will not occur.
    fileprivate(set) weak var startingView: UIImageView?
    
    /// The view the the transition controller should use for contextual animation during the dismissal.
    /// If the reference view that is provided is not currently visible, contextual animation will not occur.
    fileprivate(set) weak var endingView: UIImageView?
    
    /// Internal closure to be called upon dismissal. This will resolve the `endingView` variable.
    var resolveEndingViewClosure: ((_ photo: AWPhotoProtocol, _ index: Int) -> Void)?
    
    /// The damping ratio for the presentation animation as it approaches its quiescent state.
    /// To smoothly decelerate the animation without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation.
    /// Defaults to 1.
    public var presentationSpringDampingRatio: CGFloat = 1
    
    /// The damping ratio for the dismissal animation as it approaches its quiescent state.
    /// To smoothly decelerate the animation without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation.
    /// Defaults to 1.
    public var dismissalSpringDampingRatio: CGFloat = 1
    
    /// The fading backdrop that is displayed while the photo viewer is presenting/dismissing.
    /// This closure will be called during presentation and dismissal. Defaults to a black backdrop view.
    public var fadingBackdropView: () -> UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    
    /// The duration of the transition.
    public var duration: TimeInterval = 0.3
    
    public init(interactiveDismissalEnabled: Bool, startingView: UIImageView?, endingView: ((_ photo: AWPhotoProtocol, _ index: Int) -> UIImageView?)?) {
        super.init()
        self.commonInit(interactiveDismissalEnabled: interactiveDismissalEnabled, startingView: startingView, endingView: endingView)
    }
    
    public convenience init(startingView: UIImageView?, endingView: ((_ photo: AWPhotoProtocol, _ index: Int) -> UIImageView?)?) {
        self.init(interactiveDismissalEnabled: true, startingView: startingView, endingView: endingView)
    }
    
    public convenience override init() {
        self.init(interactiveDismissalEnabled: true, startingView: nil, endingView: nil)
    }
    
    fileprivate func commonInit(interactiveDismissalEnabled: Bool, startingView: UIImageView?, endingView: ((_ photo: AWPhotoProtocol, _ index: Int) -> UIImageView?)?) {
        
        self.interactiveDismissalEnabled = interactiveDismissalEnabled
        
        if let startingView = startingView {
            guard startingView.bounds != .zero else {
                assertionFailure("'startingView' has invalid geometry: \(startingView)")
                return
            }
            
            self.startingView = startingView
        }
        
        if let endingView = endingView {
            self.resolveEndingViewClosure = { [weak self] (photo, index) in
                guard let `self` = self else { return }
                
                if let endingView = endingView(photo, index) {
                    guard endingView.bounds != .zero else {
                        self.endingView = nil
                        assertionFailure("'endingView' has invalid geometry: \(endingView)")
                        return
                    }
                    
                    self.endingView = endingView
                } else {
                    self.endingView = nil
                }
            }
        }
    }
}
