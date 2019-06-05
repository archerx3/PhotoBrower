//
//  AWPhotoViewController.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation
import UIKit

import FLAnimatedImage

public class AWPhotoViewController: UIViewController, AWPageableViewControllerProtocol, AWZoomingImageViewDelegate {
    
    public weak var delegate: AWPhotoViewControllerDelegate?
    public var pageIndex: Int = 0
    
    fileprivate(set) var loadingView: AWLoadingViewProtocol?
    
    var zoomingImageView: AWZoomingImageView {
        get {
            return self.view as! AWZoomingImageView
        }
    }
    
    fileprivate var photo: AWPhotoProtocol?
    fileprivate weak var notificationCenter: NotificationCenter?
    
    public init(loadingView: AWLoadingViewProtocol, notificationCenter: NotificationCenter) {
        self.loadingView = loadingView
        self.notificationCenter = notificationCenter
        
        super.init(nibName: nil, bundle: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(photoLoadingProgressDidUpdate(_:)),
                                       name: .photoLoadingProgressUpdate,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(photoImageDidUpdate(_:)),
                                       name: .photoImageUpdate,
                                       object: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.notificationCenter?.removeObserver(self)
    }
    
    public override func loadView() {
        self.view = AWZoomingImageView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.zoomingImageView.zoomScaleDelegate = self
        
        if let loadingView = self.loadingView as? UIView {
            self.view.addSubview(loadingView)
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var adjustedSize = self.view.bounds.size
        if #available(iOS 11.0, tvOS 11.0, *) {
            adjustedSize.width -= (self.view.safeAreaInsets.left + self.view.safeAreaInsets.right)
            adjustedSize.height -= (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom)
        }
        
        let loadingViewSize = self.loadingView?.sizeThatFits(adjustedSize) ?? .zero
        (self.loadingView as? UIView)?.frame = CGRect(origin: CGPoint(x: floor((self.view.bounds.size.width - loadingViewSize.width) / 2),
                                                                      y: floor((self.view.bounds.size.height - loadingViewSize.height) / 2)),
                                                      size: loadingViewSize)
    }
    
    public func applyPhoto(_ photo: AWPhotoProtocol) {
        self.photo = photo
        
        weak var weakSelf = self
        func resetImageView() {
            weakSelf?.zoomingImageView.image = nil
            weakSelf?.zoomingImageView.animatedImage = nil
        }
        
        self.loadingView?.removeError()
        
        switch photo.aw_loadingState {
        case .loading, .notLoaded, .loadingCancelled:
            resetImageView()
            self.loadingView?.startLoading(initialProgress: photo.aw_progress)
        case .loadingFailed:
            resetImageView()
            let error = photo.aw_error ?? NSError()
            self.loadingView?.showError(error, retryHandler: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.photoViewController(self, retryDownloadFor: photo)
                self.loadingView?.removeError()
                self.loadingView?.startLoading(initialProgress: photo.aw_progress)
            })
        case .loaded:
            guard photo.image != nil || photo.aw_animatedImage != nil else {
                assertionFailure("Must provide valid `UIImage` in \(#function)")
                return
            }
            
            self.loadingView?.stopLoading()
            
            if let animatedImage = photo.aw_animatedImage {
                self.zoomingImageView.animatedImage = animatedImage
            } else if let image = photo.image {
                self.zoomingImageView.image = image
            }
        }
        
        self.view.setNeedsLayout()
    }
    
    // MARK: - AWPageableViewControllerProtocol
    func prepareForReuse() {
        self.zoomingImageView.image = nil
        self.zoomingImageView.animatedImage = nil
    }
    
    func prepareForRecycle() {
        
    }
    
    // MARK: - AWZoomingImageViewDelegate
    func zoomingImageView(_ zoomingImageView: AWZoomingImageView, maximumZoomScaleFor imageSize: CGSize) -> CGFloat {
        return self.delegate?.photoViewController(self,
                                                  maximumZoomScaleForPhotoAt: self.pageIndex,
                                                  minimumZoomScale: zoomingImageView.minimumZoomScale,
                                                  imageSize: imageSize) ?? .leastNormalMagnitude
    }
    
    // MARK: - Notifications
    @objc fileprivate func photoLoadingProgressDidUpdate(_ notification: Notification) {
        guard let photo = notification.object as? AWPhotoProtocol else {
            assertionFailure("Photos must conform to the AWPhoto protocol.")
            return
        }
        
        guard photo === self.photo, let progress = notification.userInfo?[AWPhotosViewControllerNotification.ProgressKey] as? CGFloat else {
            return
        }
        
        self.loadingView?.updateProgress(progress)
    }
    
    @objc fileprivate func photoImageDidUpdate(_ notification: Notification) {
        guard let photo = notification.object as? AWPhotoProtocol else {
            assertionFailure("Photos must conform to the AWPhoto protocol.")
            return
        }
        
        guard photo === self.photo, let userInfo = notification.userInfo else {
            return
        }
        
        if userInfo[AWPhotosViewControllerNotification.AnimatedImageKey] != nil || userInfo[AWPhotosViewControllerNotification.ImageKey] != nil {
            self.applyPhoto(photo)
        } else if let referenceView = userInfo[AWPhotosViewControllerNotification.ReferenceViewKey] as? FLAnimatedImageView {
            self.zoomingImageView.imageView.aw_syncFrames(with: referenceView)
        } else if let error = userInfo[AWPhotosViewControllerNotification.ErrorKey] as? Error {
            self.loadingView?.showError(error, retryHandler: { [weak self] in
                guard let `self` = self, let photo = self.photo else { return }
                self.delegate?.photoViewController(self, retryDownloadFor: photo)
                self.loadingView?.removeError()
                self.loadingView?.startLoading(initialProgress: photo.aw_progress)
                self.view.setNeedsLayout()
            })
            
            self.view.setNeedsLayout()
        }
    }
}

public protocol AWPhotoViewControllerDelegate: AnyObject, NSObjectProtocol {
    
    func photoViewController(_ photoViewController: AWPhotoViewController, retryDownloadFor photo: AWPhotoProtocol)
    
    func photoViewController(_ photoViewController: AWPhotoViewController,
                             maximumZoomScaleForPhotoAt index: Int,
                             minimumZoomScale: CGFloat,
                             imageSize: CGSize) -> CGFloat
    
}
