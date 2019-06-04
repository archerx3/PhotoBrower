//
//  AWStackableViewToolbarContainer.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation

// MARK: AWBottomStackToolbar
typealias AWBottomStackToolbarButtonBlock = (UIBarButtonItem) -> Void

class AWBottomStackToolbar: UIToolbar {
    var customLabel: UILabel!
    
    var addButtonActionBlock: AWBottomStackToolbarButtonBlock?
    var trashButtonActionBlock: AWBottomStackToolbarButtonBlock?
    
    init(frame: CGRect, customLabel: UILabel? = nil) {
        self.customLabel = customLabel
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        if self.customLabel == nil {
            
            let customLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 20)))
            customLabel.text = " "
            customLabel.textColor = .white
            customLabel.sizeToFit()
            
            self.customLabel = customLabel
        }
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        self.items = [
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(addButtonAction(_:))),
            flex,
            UIBarButtonItem(customView: self.customLabel),
            flex,
            UIBarButtonItem(barButtonSystemItem: .trash,
                            target: self,
                            action: #selector(trashButtonAction(_:))),
        ]
        
        self.backgroundColor = .clear
        self.setBackgroundImage(UIImage(),
                                forToolbarPosition: .any,
                                barMetrics: .default)
    }
}

extension AWBottomStackToolbar {
    @objc fileprivate func addButtonAction(_ sender: UIBarButtonItem) {
        if addButtonActionBlock != nil {
            addButtonActionBlock!(sender)
        }
    }
    
    @objc fileprivate func trashButtonAction(_ sender: UIBarButtonItem) {
        if trashButtonActionBlock != nil {
            trashButtonActionBlock!(sender)
        }
    }
    
}

// MARK: AWStackableViewToolbarContainer
class AWStackableViewToolbarContainer: AWStackableViewContainer {
    override init(views: [UIView], anchoredAt point: AWStackableViewContainer.AnchorPoint) {
        super.init(views: views, anchoredAt: point)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        let toolbarRect = CGRect(origin: .zero, size: CGSize(width: 320, height: 44))
        let bottomToolbar = AWBottomStackToolbar.init(frame: toolbarRect)
        
        bottomToolbar.addButtonActionBlock = { [weak self] (sender) in
            guard let `self` = self else { return }
            
            self.delegate?.stackableViewContainer(self, didExecuteActionType: .add)
        }
        
        bottomToolbar.trashButtonActionBlock = { [weak self] (sender) in
            guard let `self` = self else { return }
            
            self.delegate?.stackableViewContainer(self, didExecuteActionType: .delete)
        }
        
        self.insertSubview(bottomToolbar, at: 0) // insert custom
        
        self.toolbar = bottomToolbar
    }
}
