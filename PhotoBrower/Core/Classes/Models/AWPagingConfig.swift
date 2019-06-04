//
//  AWPagingConfig.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

fileprivate let DefaultHorizontalSpacing: CGFloat = 20

open class AWPagingConfig: NSObject {
    
    /// Navigation configuration to be applied to the internal pager of the `PhotosViewController`.
    fileprivate(set) var navigationOrientation: UIPageViewController.NavigationOrientation
    
    /// Space between photos, measured in points. Applied to the internal pager of the `PhotosViewController` at initialization.
    fileprivate(set) var interPhotoSpacing: CGFloat
    
    /// The loading view class which will be instantiated instead of the default `AWLoadingView`.
    fileprivate(set) var loadingViewClass: AWLoadingViewProtocol.Type = AWLoadingView.self
    
    public init(navigationOrientation: UIPageViewController.NavigationOrientation,
                interPhotoSpacing: CGFloat,
                loadingViewClass: AWLoadingViewProtocol.Type? = nil) {
        
        self.navigationOrientation = navigationOrientation
        self.interPhotoSpacing = interPhotoSpacing
        
        super.init()
        
        if let loadingViewClass = loadingViewClass {
            guard loadingViewClass is UIView.Type else {
                assertionFailure("`loadingViewClass` must be a UIView.")
                return
            }
            
            self.loadingViewClass = loadingViewClass
        }
    }
    
    public convenience override init() {
        self.init(navigationOrientation: .horizontal, interPhotoSpacing: DefaultHorizontalSpacing, loadingViewClass: nil)
    }
    
    public convenience init(navigationOrientation: UIPageViewController.NavigationOrientation) {
        self.init(navigationOrientation: navigationOrientation, interPhotoSpacing: DefaultHorizontalSpacing, loadingViewClass: nil)
    }
    
    public convenience init(interPhotoSpacing: CGFloat) {
        self.init(navigationOrientation: .horizontal, interPhotoSpacing: interPhotoSpacing, loadingViewClass: nil)
    }
    
    public convenience init(loadingViewClass: AWLoadingViewProtocol.Type?) {
        self.init(navigationOrientation: .horizontal, interPhotoSpacing: DefaultHorizontalSpacing, loadingViewClass: loadingViewClass)
    }
    
}
