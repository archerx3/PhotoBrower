//
//  AWOverlayTitleViewProtocol.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

public protocol AWOverlayTitleViewProtocol: NSObjectProtocol {
    
    /// This method is called by the `AWOverlayView`'s toolbar in order to size the view appropriately for display.
    func sizeToFit() -> Void
    
    /// Called when swipe progress between photos is updated. This method can be implemented to update your [progressive]
    /// title view with a new position.
    ///
    /// - Parameters:
    ///   - low: The low photo index that is being swiped. (high - 1)
    ///   - high: The high photo index that is being swiped. (low + 1)
    ///   - percent: The percent swiped between the two indexes.
    func tweenBetweenLowIndex(_ low: Int, highIndex high: Int, percent: CGFloat)
}
