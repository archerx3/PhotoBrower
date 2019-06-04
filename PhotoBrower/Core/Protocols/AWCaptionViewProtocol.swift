//
//  AWCaptionViewProtocol.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

public protocol AWCaptionViewProtocol: NSObjectProtocol {
    
    /// Whether or not the `CaptionView` should animate caption info changes - using `Constants.frameAnimDuration` as
    /// the animation duration.
    var animateCaptionInfoChanges: Bool { get set }
    
    /// The `AXPhotosViewController` will call this method when a new photo is ready to have its information displayed.
    /// The implementation should update the `captionView` with the attributed parameters.
    ///
    /// - Parameters:
    ///   - attributedTitle: The attributed title of the new photo.
    ///   - attributedDescription: The attributed description of the new photo.
    ///   - attributedCredit: The attributed credit of the new photo.
    func applyCaptionInfo(attributedTitle: NSAttributedString?,
                          attributedDescription: NSAttributedString?,
                          attributedCredit: NSAttributedString?)
    
    /// The `AXPhotosViewController` uses this method to correctly size the caption view for a constrained width.
    ///
    /// - Parameter size: The constrained size. Use the width of this value to layout subviews.
    /// - Returns: A size that fits all subviews inside a constrained width.
    func sizeThatFits(_ size: CGSize) -> CGSize
}
