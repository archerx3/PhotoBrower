//
//  AWStackableViewContainer.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation
import UIKit

public typealias AWStackableViewContainerSetupBlock = ((AWStackableViewContainer) -> Void)
public typealias AWStackableViewContainerUpdateBlock = ((AWStackableViewContainer, AWPhotoProtocol, Int, Int) -> Void)

public class AWStackableViewContainer: UIView {
    
    enum AnchorPoint: Int {
        case top, bottom
    }
    
    enum ActionType: Int {
        case add = 1, modify = 0, delete = -1
    }
    
    weak var delegate: AWStackableViewContainerDelegate?
    
    var navigationBar: UINavigationBar?
    var toolbar: UIToolbar?
    
    public var stackableContainerSetupBlock: AWStackableViewContainerSetupBlock? {
        didSet {
            if self.stackableContainerSetupBlock != nil {
                self.stackableContainerSetupBlock!(self)
            }
        }
    }
    
    public var stackableContainerUpdateBlock: AWStackableViewContainerUpdateBlock?
    
    /// The inset of the contents of the `StackableViewContainer`.
    /// For internal use only.
    var contentInset: UIEdgeInsets = .zero
    
    fileprivate(set) var anchorPoint: AWStackableViewContainer.AnchorPoint
    
    init(views: [UIView], anchoredAt point: AWStackableViewContainer.AnchorPoint) {
        self.anchorPoint = point
        super.init(frame: .zero)
        views.forEach({ self.addSubview($0) })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.computeSize(for: self.frame.size, applySizingLayout: true)
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.computeSize(for: size, applySizingLayout: false)
    }
    
    @discardableResult
    fileprivate func computeSize(for constrainedSize: CGSize, applySizingLayout: Bool) -> CGSize {
        var yOffset: CGFloat = 0
        let xOffset: CGFloat = self.contentInset.left
        var constrainedInsetSize = constrainedSize
        constrainedInsetSize.width -= (self.contentInset.left + self.contentInset.right)
        
        let subviews = (self.anchorPoint == .top) ? self.subviews : self.subviews.reversed()
        for subview in subviews {
            let size = subview.sizeThatFits(constrainedInsetSize)
            var frame: CGRect
            
            if yOffset == 0 && size.height > 0 {
                yOffset = self.contentInset.top
            }
            
            // special cases, UIToolbar + UINavigationBar are not to be trifled with in iOS 11
            var forceLayout: Bool
            if isToolbarOrNavigationBar(subview) {
                frame = CGRect(x: xOffset, y: yOffset, width: constrainedInsetSize.width, height: size.height)
                forceLayout = false
            } else {
                frame = CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: size)
                forceLayout = true
            }
            
            yOffset += frame.size.height
            
            if applySizingLayout {
                subview.frame = frame
                if forceLayout {
                    subview.setNeedsLayout()
                }
                subview.layoutIfNeeded()
            }
        }
        
        if (yOffset - self.contentInset.top) > 0 {
            yOffset += self.contentInset.bottom
        }
        
        return CGSize(width: constrainedSize.width, height: yOffset)
    }
    
    // MARK: - AWStackableViewContainerDelegate
    override public func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        self.delegate?.stackableViewContainer(self, didAddSubview: subview)
    }
    
    override public func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        self.delegate?.stackableViewContainer(self, willRemoveSubview: subview)
    }
    
    // MARK: - Helpers
    private func isToolbarOrNavigationBar(_ view: UIView) -> Bool {
        return view is UIToolbar || view is UINavigationBar
    }
    
}

protocol AWStackableViewContainerDelegate: class {
    
    func stackableViewContainer(_ stackableViewContainer: AWStackableViewContainer, didAddSubview: UIView)
    func stackableViewContainer(_ stackableViewContainer: AWStackableViewContainer, willRemoveSubview: UIView)
    
    func stackableViewContainer(_ stackableViewContainer: AWStackableViewContainer, didExecuteAction:AWStackableViewContainer.ActionType)
}
