//
//  AWPreviewingPhotosViewController.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import FLAnimatedImage

open class AWPreviewingPhotosViewController: UIViewController, AWNetworkIntegrationDelegate {
    
    /// The photos to display in the `PhotosPreviewingViewController`.
    open var dataSource: AWPhotosDataSource = AWPhotosDataSource() {
        didSet {
            // this can occur during `commonInit(dataSource:networkIntegration:)`
            if self.networkIntegration == nil {
                return
            }
            
            self.networkIntegration.cancelAllLoads()
            self.configure(with: dataSource.initialPhotoIndex)
        }
    }
    
    /// The `NetworkIntegration` passed in at initialization. This object is used to fetch images asynchronously from a cache or URL.
    /// - Initialized by the end of `commonInit(dataSource:networkIntegration:)`.
    public fileprivate(set) var networkIntegration: AWNetworkIntegrationProtocol!
    
    var imageView: FLAnimatedImageView {
        get {
            return self.view as! FLAnimatedImageView
        }
    }
    
    // MARK: - Initialization
    public init(dataSource: AWPhotosDataSource) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource)
    }
    
    public init(dataSource: AWPhotosDataSource,
                      networkIntegration: AWNetworkIntegrationProtocol) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        networkIntegration: networkIntegration)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func commonInit(dataSource: AWPhotosDataSource,
                                networkIntegration: AWNetworkIntegrationProtocol? = nil) {
        
        self.dataSource = dataSource
        
        var `networkIntegration` = networkIntegration
        if networkIntegration == nil {
            networkIntegration = AWKingfisherIntegration()
        }
        
        self.networkIntegration = networkIntegration
        self.networkIntegration.delegate = self
    }
    
    open override func loadView() {
        self.view = FLAnimatedImageView()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.contentMode = .scaleAspectFit
        self.configure(with: self.dataSource.initialPhotoIndex)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var newSize: CGSize
        if self.imageView.image == nil && self.imageView.animatedImage == nil {
            newSize = CGSize(width: self.imageView.frame.size.width,
                             height: self.imageView.frame.size.width * 9.0 / 16.0)
        } else {
            newSize = self.imageView.intrinsicContentSize
        }
        
        self.preferredContentSize = newSize
    }
    
    fileprivate func configure(with index: Int) {
        guard let photo = self.dataSource.photo(at: index) else { return }
        self.networkIntegration.loadPhoto(photo)
    }
    
    // MARK: - AWNetworkIntegrationDelegate
    public func networkIntegration(_ networkIntegration: AWNetworkIntegrationProtocol, loadDidFinishWith photo: AWPhotoProtocol) {
        if let animatedImage = photo.aw_animatedImage {
            photo.aw_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.imageView.animatedImage = animatedImage
                self?.view.setNeedsLayout()
            }
        } else if let imageData = photo.imageData, let animatedImage = FLAnimatedImage(animatedGIFData: imageData) {
            photo.aw_animatedImage = animatedImage
            photo.aw_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.imageView.animatedImage = animatedImage
                self?.view.setNeedsLayout()
            }
        } else if let image = photo.image {
            photo.aw_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
                self?.view.setNeedsLayout()
            }
        }
    }
    
    public func networkIntegration(_ networkIntegration: AWNetworkIntegrationProtocol, loadDidFailWith error: Error, for photo: AWPhotoProtocol) {
        guard photo.aw_loadingState != .loadingCancelled else {
            return
        }
        
        photo.aw_loadingState = .loadingFailed
        photo.aw_error = error
    }
    
    public func networkIntegration(_ networkIntegration: AWNetworkIntegrationProtocol, didUpdateLoadingProgress progress: CGFloat, for photo: AWPhotoProtocol) {
        photo.aw_progress = progress
    }
    
}
