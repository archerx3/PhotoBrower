//
//  AWPhotosViewController.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

import FLAnimatedImage

public class AWPhotosViewController: UIViewController,
                                   UIPageViewControllerDelegate,
                                   UIPageViewControllerDataSource,
                                   UIGestureRecognizerDelegate,
                                   AWPhotoViewControllerDelegate,
                                   AWNetworkIntegrationDelegate,
                                   AWPhotosTransitionControllerDelegate {
    
    /// The close bar button item that is initially set in the overlay's toolbar. Any 'target' or 'action' provided to this button will be overwritten.
    /// Overriding this is purely for customizing the look and feel of the button.
    /// Alternatively, you may create your own `UIBarButtonItem`s and directly set them _and_ their actions on the `overlayView` property.
    public var closeBarButtonItem: UIBarButtonItem {
        get {
            return UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        }
    }
    
    /// The action bar button item that is initially set in the overlay's toolbar. Any 'target' or 'action' provided to this button will be overwritten.
    /// Overriding this is purely for customizing the look and feel of the button.
    /// Alternatively, you may create your own `UIBarButtonItem`s and directly set them _and_ their actions on the `overlayView` property.
    public var actionBarButtonItem: UIBarButtonItem {
        get {
            return UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        }
    }
    
    /// The internal tap gesture recognizer that is used to initiate and pan interactive dismissals.
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    
    fileprivate var aw_prefersStatusBarHidden: Bool = false
    public override var prefersStatusBarHidden: Bool {
        get {
            return super.prefersStatusBarHidden || self.aw_prefersStatusBarHidden
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    public weak var delegate: AWPhotosViewControllerDelegate?
    
    /// The underlying `OverlayView` that is used for displaying photo captions, titles, and actions.
    public var overlayView: AWOverlayView!
    
    /// The photos to display in the PhotosViewController.
    public var dataSource = AWPhotosDataSource() {
        didSet {
            // this can occur during `commonInit(dataSource:pagingConfig:transitionInfo:networkIntegration:)`
            // if that's the case, this logic will be applied in `viewDidLoad()`
            if self.pageViewController == nil || self.networkIntegration == nil {
                return
            }
            
            self.pageViewController.dataSource = (self.dataSource.numberOfPhotos > 1) ? self : nil
            self.networkIntegration.cancelAllLoads()
            self.configurePageViewController()
        }
    }
    
    /// The configuration object applied to the internal pager at initialization.
    public fileprivate(set) var pagingConfig = AWPagingConfig()
    
    /// The `AWTransitionInfo` passed in at initialization. This object is used to define functionality for the presentation and dismissal
    /// of the `PhotosViewController`.
    public fileprivate(set) var transitionInfo = AWTransitionInfo()
    
    /// The `NetworkIntegration` passed in at initialization. This object is used to fetch images asynchronously from a cache or URL.
    /// - Initialized by the end of `commonInit(dataSource:pagingConfig:transitionInfo:networkIntegration:)`.
    public fileprivate(set) var networkIntegration: AWNetworkIntegrationProtocol!
    
    /// The underlying UIPageViewController that is used for swiping horizontally and vertically.
    /// - Important: `AWPhotosViewController` is this page view controller's `UIPageViewControllerDelegate`, `UIPageViewControllerDataSource`.
    ///              Changing these values will result in breakage.
    /// - Note: Initialized by the end of `commonInit(dataSource:pagingConfig:transitionInfo:networkIntegration:)`.
    public fileprivate(set) var pageViewController: UIPageViewController!
    
    /// The internal tap gesture recognizer that is used to hide/show the overlay interface.
    public let singleTapGestureRecognizer = UITapGestureRecognizer()
    
    /// The view controller containing the photo currently being shown.
    public var currentPhotoViewController: AWPhotoViewController? {
        get {
            return self.orderedViewControllers.filter({ $0.pageIndex == currentPhotoIndex }).first
        }
    }
    
    /// The index of the photo currently being shown.
    public fileprivate(set) var currentPhotoIndex: Int = 0 {
        didSet {
            self.updateOverlay(for: currentPhotoIndex)
        }
    }
    
    // MARK: - Private/internal variables
    fileprivate enum SwipeDirection {
        case none, left, right
    }
    
    /// If the `PhotosViewController` is being presented in a fullscreen container, this value is set when the `PhotosViewController`
    /// is added to a parent view controller to allow `PhotosViewController` to be its transitioning delegate.
    fileprivate weak var containerViewController: UIViewController? {
        didSet {
            oldValue?.transitioningDelegate = nil
            
            if let containerViewController = self.containerViewController {
                containerViewController.transitioningDelegate = self.transitionController
                self.transitioningDelegate = nil
            } else {
                self.transitioningDelegate = self.transitionController
            }
        }
    }
    
    fileprivate var isSizeTransitioning = false
    fileprivate var isFirstAppearance = true
    
    fileprivate var orderedViewControllers = [AWPhotoViewController]()
    fileprivate var recycledViewControllers = [AWPhotoViewController]()
    
    fileprivate var transitionController: AWPhotosTransitionController?
    fileprivate let notificationCenter = NotificationCenter()
    
    // MARK: - Initialization
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.commonInit()
    }
    
    public init(dataSource: AWPhotosDataSource?) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource)
    }
    
    public init(dataSource: AWPhotosDataSource?,
                pagingConfig: AWPagingConfig?) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig)
    }
    
    public init(pagingConfig: AWPagingConfig?,
                transitionInfo: AWTransitionInfo?) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo)
    }
    
    public init(dataSource: AWPhotosDataSource?,
                pagingConfig: AWPagingConfig?,
                transitionInfo: AWTransitionInfo?) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo)
    }
    
    public init(dataSource: AWPhotosDataSource?,
                pagingConfig: AWPagingConfig?,
                transitionInfo: AWTransitionInfo?,
                overlay: AWOverlayView? = AWOverlayView(),
                delegate: AWPhotosViewControllerDelegate? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        overlay:overlay,
                        delegate: delegate)
    }
    
    public init(networkIntegration: AWNetworkIntegrationProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(networkIntegration: networkIntegration)
    }
    
    public init(dataSource: AWPhotosDataSource?,
                networkIntegration: AWNetworkIntegrationProtocol) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        networkIntegration: networkIntegration)
    }
    
    public init(dataSource: AWPhotosDataSource?,
                pagingConfig: AWPagingConfig?,
                networkIntegration: AWNetworkIntegrationProtocol) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        networkIntegration: networkIntegration)
    }
    
    public init(pagingConfig: AWPagingConfig?,
                transitionInfo: AWTransitionInfo?,
                networkIntegration: AWNetworkIntegrationProtocol) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration)
    }
    
    public init(dataSource: AWPhotosDataSource?,
                      pagingConfig: AWPagingConfig?,
                      transitionInfo: AWTransitionInfo?,
                      networkIntegration: AWNetworkIntegrationProtocol,
                      delegate: AWPhotosViewControllerDelegate? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration,
                        delegate: delegate)
    }
    
    public init(dataSource: AWPhotosDataSource?,
                pagingConfig: AWPagingConfig?,
                transitionInfo: AWTransitionInfo?,
                networkIntegration: AWNetworkIntegrationProtocol,
                overlay: AWOverlayView? = AWOverlayView(),
                delegate: AWPhotosViewControllerDelegate? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration,
                        overlay: overlay,
                        delegate: delegate)
    }
    
    public init(from previewingPhotosViewController: AWPreviewingPhotosViewController,
                delegate: AWPhotosViewControllerDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: previewingPhotosViewController.dataSource,
                        networkIntegration: previewingPhotosViewController.networkIntegration,
                        delegate: delegate)
        
        if #available(iOS 9.0, *) {
            self.loadViewIfNeeded()
        } else {
            let _ = self.view
        }
        
        self.currentPhotoViewController?.zoomingImageView.imageView.aw_syncFrames(with: previewingPhotosViewController.imageView)
    }
    
    public init(from previewingPhotosViewController: AWPreviewingPhotosViewController,
                pagingConfig: AWPagingConfig?,
                delegate: AWPhotosViewControllerDelegate? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: previewingPhotosViewController.dataSource,
                        pagingConfig: pagingConfig,
                        networkIntegration: previewingPhotosViewController.networkIntegration,
                        delegate: delegate)
        
        if #available(iOS 9.0, *) {
            self.loadViewIfNeeded()
        } else {
            let _ = self.view
        }
        
        self.currentPhotoViewController?.zoomingImageView.imageView.aw_syncFrames(with: previewingPhotosViewController.imageView)
    }
    
    public init(from previewingPhotosViewController: AWPreviewingPhotosViewController,
                pagingConfig: AWPagingConfig?,
                transitionInfo: AWTransitionInfo?,
                delegate: AWPhotosViewControllerDelegate? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: previewingPhotosViewController.dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: previewingPhotosViewController.networkIntegration,
                        delegate: delegate)
        
        if #available(iOS 9.0, *) {
            self.loadViewIfNeeded()
        } else {
            let _ = self.view
        }
        
        self.currentPhotoViewController?.zoomingImageView.imageView.aw_syncFrames(with: previewingPhotosViewController.imageView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // init to be used internally by the library
    @nonobjc init(dataSource: AWPhotosDataSource? = nil,
                  pagingConfig: AWPagingConfig? = nil,
                  transitionInfo: AWTransitionInfo? = nil,
                  networkIntegration: AWNetworkIntegrationProtocol? = nil,
                  delegate: AWPhotosViewControllerDelegate? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration,
                        delegate: delegate)
    }
    
    fileprivate func commonInit(dataSource: AWPhotosDataSource? = nil,
                                pagingConfig: AWPagingConfig? = nil,
                                transitionInfo: AWTransitionInfo? = nil,
                                networkIntegration: AWNetworkIntegrationProtocol? = nil,
                                overlay: AWOverlayView? = AWOverlayView(),
                                delegate: AWPhotosViewControllerDelegate? = nil) {
        
        if let dataSource = dataSource {
            self.dataSource = dataSource
        }
        
        if let pagingConfig = pagingConfig {
            self.pagingConfig = pagingConfig
        }
        
        if let transitionInfo = transitionInfo {
            self.transitionInfo = transitionInfo
            
            if transitionInfo.interactiveDismissalEnabled {
                self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWithGestureRecognizer(_:)))
                self.panGestureRecognizer?.maximumNumberOfTouches = 1
                self.panGestureRecognizer?.delegate = self
            }
        }
        
        var `networkIntegration` = networkIntegration
        if networkIntegration == nil {
            networkIntegration = AWKingfisherIntegration()
        }
        
        self.overlayView = overlay
        self.overlayView.bottomStackActionBlock = { [weak self] (anchorPoint, actionType) in
            
            guard let `self` = self else { return }
            
            guard let photo = self.dataSource.photo(at: self.currentPhotoIndex) else { return }
            
            var anchorPointString = "bottom"
            switch anchorPoint {
            case .top:
                anchorPointString = "top"
            default:
                break
            }
            
            var actionTypeString = "add"
            switch actionType {
            case .modify:
                actionTypeString = "modify"
            case .delete:
                actionTypeString = "delete"
            default:
                break
            }
            
            print("Did execute \(actionTypeString) action on \(anchorPointString) stackable view!")
            
            if anchorPoint == .bottom {
                self.delegate?.photosViewController(self,
                                                    didExecuteActionType: actionType,
                                                    on: self.overlayView.bottomStackContainer,
                                                    for: photo)
            } else if anchorPoint == .top {
                
            }
        }
        
        self.networkIntegration = networkIntegration
        self.networkIntegration.delegate = self
        
        self.delegate = delegate
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                       navigationOrientation: self.pagingConfig.navigationOrientation,
                                                       options: [.interPageSpacing: self.pagingConfig.interPhotoSpacing])
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = (self.dataSource.numberOfPhotos > 1) ? self : nil
        self.pageViewController.scrollView.addContentOffsetObserver(self)
        self.configurePageViewController()
        
        self.singleTapGestureRecognizer.numberOfTapsRequired = 1
        self.singleTapGestureRecognizer.addTarget(self, action: #selector(didSingleTapWithGestureRecognizer(_:)))
        
        self.overlayView.tintColor = .white
        self.overlayView.setShowInterface(false, animated: false)
        
        let closeBarButtonItem = self.closeBarButtonItem
        closeBarButtonItem.target = self
        closeBarButtonItem.action = #selector(closeAction(_:))
        self.overlayView.leftBarButtonItem = closeBarButtonItem
        
        let actionBarButtonItem = self.actionBarButtonItem
        actionBarButtonItem.target = self
        actionBarButtonItem.action = #selector(shareAction(_:))
        self.overlayView.rightBarButtonItem = actionBarButtonItem
    }
    
    deinit {
        self.recycledViewControllers.removeLifeycleObserver(self)
        self.orderedViewControllers.removeLifeycleObserver(self)
        self.pageViewController.scrollView.removeContentOffsetObserver(self)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.recycledViewControllers.removeLifeycleObserver(self)
        self.recycledViewControllers.removeAll()
        
        self.reduceMemoryForPhotos(at: self.currentPhotoIndex)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        self.transitionController = AWPhotosTransitionController(transitionInfo: self.transitionInfo)
        self.transitionController?.delegate = self
        
        if let panGestureRecognizer = self.panGestureRecognizer {
            self.pageViewController.view.addGestureRecognizer(panGestureRecognizer)
        }
        
        if let containerViewController = self.containerViewController {
            containerViewController.transitioningDelegate = self.transitionController
        } else {
            self.transitioningDelegate = self.transitionController
        }
        
        if self.pageViewController.view.superview == nil {
            self.pageViewController.view.addGestureRecognizer(self.singleTapGestureRecognizer)
            
            self.addChild(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)
            self.pageViewController.didMove(toParent: self)
        }
        
        if self.overlayView.superview == nil {
            self.view.addSubview(self.overlayView)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isFirstAppearance {
            let visible: Bool = true
            self.overlayView.setShowInterface(visible, animated: true, alongside: { [weak self] in
                guard let `self` = self else { return }
                
                self.updateStatusBarAppearance(show: visible)
                
                self.overlayView(self.overlayView, visibilityWillChange: visible)
            })
            self.isFirstAppearance = false
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.isSizeTransitioning = true
        coordinator.animate(alongsideTransition: nil) { [weak self] (context) in
            self?.isSizeTransitioning = false
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.pageViewController.view.frame = self.view.bounds
        self.overlayView.frame = self.view.bounds
        self.overlayView.performAfterShowInterfaceCompletion { [weak self] in
            // if being dismissed, let's just return early rather than update insets
            guard let `self` = self, !self.isBeingDismissed else { return }
            self.updateOverlayInsets()
        }
    }
    
    public override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if parent is UINavigationController {
            assertionFailure("Do not embed `PhotosViewController` in a navigation stack.")
            return
        }
        
        self.containerViewController = parent
    }
    
    // MARK: - PhotosViewControllerTransitionAnimatorDelegate
    func transitionController(_ transitionController: AWPhotosTransitionController, didCompletePresentationWith transitionView: UIImageView) {
        guard let photo = self.dataSource.photo(at: self.currentPhotoIndex) else { return }
        
        self.notificationCenter.post(name: .photoImageUpdate,
                                     object: photo,
                                     userInfo: [AWPhotosViewControllerNotification.ReferenceViewKey: transitionView])
    }
    
    func transitionController(_ transitionController: AWPhotosTransitionController, didCompleteDismissalWith transitionView: UIImageView) {
        // empty impl
    }
    
    func transitionControllerDidCancelDismissal(_ transitionController: AWPhotosTransitionController) {
        // empty impl
    }
    
    // MARK: - Dismissal
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
            return
        }
        
        self.delegate?.photosViewControllerWillDismiss(self)
        super.dismiss(animated: flag) { [unowned self] in
            let canceled = (self.view.window != nil)
            
            if canceled {
                self.transitionController?.forceNonInteractiveDismissal = false
               
                self.panGestureRecognizer?.isEnabled = true
            } else {
                self.delegate?.photosViewControllerDidDismiss(self)
            }
            
            completion?()
        }
    }
    
    // MARK: - Navigation
    
    /// Convenience method to programmatically navigate to a photo
    ///
    /// - Parameters:
    ///   - photoIndex: The index of the photo to navigate to
    ///   - animated: Whether or not to animate the transition
    public func navigateToPhotoIndex(_ photoIndex: Int, animated: Bool) {
        if photoIndex < 0 || photoIndex > (self.dataSource.numberOfPhotos - 1) {
            return
        }
        
        guard let photoViewController = self.makePhotoViewController(for: photoIndex) else { return }
        
        let forward = (photoIndex > self.currentPhotoIndex)
        self.pageViewController.setViewControllers([photoViewController],
                                                   direction: forward ? .forward : .reverse,
                                                   animated: animated,
                                                   completion: nil)
        self.loadPhotos(at: photoIndex)
        self.currentPhotoIndex = photoIndex
    }
    
    // MARK: - Page VC Configuration
    fileprivate func configurePageViewController() {
        func configure(with viewController: UIViewController, pageIndex: Int) {
            self.pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
            self.currentPhotoIndex = pageIndex
            
            self.overlayView.titleView?.tweenBetweenLowIndex(pageIndex, highIndex: pageIndex + 1, percent: 0)
        }
        
        guard let photoViewController = self.makePhotoViewController(for: self.dataSource.initialPhotoIndex) else {
            configure(with: UIViewController(), pageIndex: 0)
            return
        }
        
        configure(with: photoViewController, pageIndex: photoViewController.pageIndex)
        self.loadPhotos(at: self.dataSource.initialPhotoIndex)
    }
    
    // MARK: - Overlay
    fileprivate func updateOverlay(for photoIndex: Int) {
        guard let photo = self.dataSource.photo(at: photoIndex) else { return }
        
        self.willUpdate(overlayView: self.overlayView, for: photo, at: photoIndex, totalNumberOfPhotos: self.dataSource.numberOfPhotos)
        
        if self.dataSource.numberOfPhotos > 1 {
            self.overlayView.internalTitle = String.localizedStringWithFormat(NSLocalizedString("%d of %d", comment: ""), photoIndex + 1, self.dataSource.numberOfPhotos)
        } else {
            self.overlayView.internalTitle = nil
        }
        
        self.overlayView.updateCaptionView(photo: photo)
    }
    
    fileprivate func updateOverlayInsets() {
        var contentInset: UIEdgeInsets
        if #available(iOS 11.0, tvOS 11.0, *) {
            contentInset = self.view.safeAreaInsets
        } else {
            contentInset = UIEdgeInsets(
                top: (UIApplication.shared.statusBarFrame.size.height > 0) ? 20 : 0,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
        
        self.overlayView.contentInset = contentInset
    }
    
    // MARK: - Gesture recognizers
    @objc fileprivate func didSingleTapWithGestureRecognizer(_ sender: UITapGestureRecognizer) {
        let show = (self.overlayView.alpha == 0)
        self.overlayView.setShowInterface(show, animated: true, alongside: { [weak self] in
            guard let `self` = self else { return }
            
            self.updateStatusBarAppearance(show: show)
            
            self.overlayView(self.overlayView, visibilityWillChange: show)
        })
    }
    
    @objc fileprivate func didPanWithGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.transitionController?.forceNonInteractiveDismissal = false
            self.dismiss(animated: true, completion: nil)
        }
        
        self.transitionController?.didPanWithGestureRecognizer(sender, in: self.containerViewController ?? self)
    }
    
    fileprivate func updateStatusBarAppearance(show: Bool) {
        self.aw_prefersStatusBarHidden = !show
        self.setNeedsStatusBarAppearanceUpdate()
        if show {
            UIView.performWithoutAnimation { [weak self] in
                self?.updateOverlayInsets()
                self?.overlayView.setNeedsLayout()
                self?.overlayView.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Default bar button actions
    @objc public func shareAction(_ barButtonItem: UIBarButtonItem) {
        guard let photo = self.dataSource.photo(at: self.currentPhotoIndex) else { return }
        
        if self.handleActionButtonTapped(photo: photo) {
            return
        }
        
        var anyRepresentation: Any?
        if let imageData = photo.imageData {
            anyRepresentation = imageData
        } else if let image = photo.image {
            anyRepresentation = image
        }
        
        guard let uAnyRepresentation = anyRepresentation else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [uAnyRepresentation], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [weak self] (activityType, completed, returnedItems, activityError) in
            guard let `self` = self else { return }
            
            if completed, let activityType = activityType {
                self.actionCompleted(activityType: activityType, for: photo)
            }
        }
        
        activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        self.present(activityViewController, animated: true)
    }
    
    @objc public func closeAction(_ sender: UIBarButtonItem) {
        self.transitionController?.forceNonInteractiveDismissal = true
        self.dismiss(animated: true)
    }
    
    // MARK: - Loading helpers
    fileprivate func loadPhotos(at index: Int) {
        
        func cancelLoad(_ photo: AWPhotoProtocol) {
            self.networkIntegration.cancelLoad(for: photo)
            photo.aw_loadingState = .loadingFailed
            
            let error = AWError.errorDescription(code: "-999", errorMessage: "Cancel Load")
            photo.aw_error = error
            
            DispatchQueue.main.async { [weak self] in
                self?.notificationCenter.post(name: .photoImageUpdate,
                                              object: photo,
                                              userInfo: [
                                                AWPhotosViewControllerNotification.ErrorKey: error,
                                                AWPhotosViewControllerNotification.LoadingStateKey: AWPhotoLoadingState.loadingFailed
                    ])
            }
        }
        
        let numberOfPhotosToLoad = self.dataSource.prefetchBehavior.rawValue
        let startIndex = (((index - (numberOfPhotosToLoad / 2)) >= 0) ? (index - (numberOfPhotosToLoad / 2)) : 0)
        let indexes = startIndex...(startIndex + numberOfPhotosToLoad)
        
        for index in indexes {
            guard let photo = self.dataSource.photo(at: index) else { return }
            
            if photo.aw_loadingState == .notLoaded || photo.aw_loadingState == .loadingCancelled {
                photo.aw_loadingState = .loading
                if let delegate = self.delegate {
                    var maybeUpdatePhoto = photo.copyPhoto()
                    var didUpdate = false
                    
                    let canLoad = delegate.photosViewController(self,
                                                                canLoad: &maybeUpdatePhoto,
                                                                didUpdate: &didUpdate)
                    
                    if canLoad {
                        if didUpdate {
                            self.dataSource.updatePhoto(maybeUpdatePhoto, at: index)
                            if self.currentPhotoIndex == index { self.overlayView.updateCaptionView(photo: maybeUpdatePhoto) }
                            self.networkIntegration.loadPhoto(maybeUpdatePhoto)
                        } else {
                            self.networkIntegration.loadPhoto(photo)
                        }
                    } else {
                        if didUpdate {
                            self.dataSource.updatePhoto(maybeUpdatePhoto, at: index)
                            if self.currentPhotoIndex == index { self.overlayView.updateCaptionView(photo: maybeUpdatePhoto) }
                        }
                        
                        cancelLoad(photo)
                    }
                } else {
                    self.networkIntegration.loadPhoto(photo)
                }
            } else if photo.aw_loadingState == .loading {
                if let delegate = self.delegate {
                    var maybeUpdatePhoto = photo.copyPhoto()
                    var didUpdate = false
                    
                    let canLoad = delegate.photosViewController(self,
                                                                canLoad: &maybeUpdatePhoto,
                                                                didUpdate: &didUpdate)
                    
                    if canLoad {
                        if didUpdate {
                            self.networkIntegration.cancelLoad(for: photo)
                            
                            self.dataSource.updatePhoto(maybeUpdatePhoto, at: index)
                            if self.currentPhotoIndex == index { self.overlayView.updateCaptionView(photo: maybeUpdatePhoto) }
                            self.networkIntegration.loadPhoto(maybeUpdatePhoto)
                        }
                    } else {
                        if didUpdate {
                            self.dataSource.updatePhoto(maybeUpdatePhoto, at: index)
                            if self.currentPhotoIndex == index { self.overlayView.updateCaptionView(photo: maybeUpdatePhoto) }
                        }
                        
                        cancelLoad(photo)
                    }
                } else {
                    self.networkIntegration.loadPhoto(photo)
                }
            }
        }
    }
    
    fileprivate func reduceMemoryForPhotos(at index: Int) {
        let numberOfPhotosToLoad = self.dataSource.prefetchBehavior.rawValue
        let lowerIndex = (index - (numberOfPhotosToLoad / 2) - 1 >= 0) ? index - (numberOfPhotosToLoad / 2) - 1: NSNotFound
        let upperIndex = (index + (numberOfPhotosToLoad / 2) + 1 < self.dataSource.numberOfPhotos) ? index + (numberOfPhotosToLoad / 2) + 1 : NSNotFound
        
        weak var weakSelf = self
        func reduceMemory(for photo: AWPhotoProtocol) {
            guard let `self` = weakSelf else { return }
            
            if photo.aw_loadingState == .loading {
                self.networkIntegration.cancelLoad(for: photo)
                photo.aw_loadingState = .loadingCancelled
            } else if photo.aw_loadingState == .loaded && photo.aw_isReducible {
                photo.imageData = nil
                photo.image = nil
                photo.aw_animatedImage = nil
                photo.aw_loadingState = .notLoaded
            }
        }
        
        if lowerIndex != NSNotFound, let photo = self.dataSource.photo(at: lowerIndex) {
            reduceMemory(for: photo)
        }
        
        if upperIndex != NSNotFound, let photo = self.dataSource.photo(at: upperIndex) {
            reduceMemory(for: photo)
        }
    }
    
    // MARK: - Reuse / Factory
    fileprivate func makePhotoViewController(for pageIndex: Int) -> AWPhotoViewController? {
        guard let photo = self.dataSource.photo(at: pageIndex) else { return nil }
        
        var photoViewController: AWPhotoViewController
        
        if self.recycledViewControllers.count > 0 {
            photoViewController = self.recycledViewControllers.removeLast()
            photoViewController.prepareForReuse()
        } else {
            guard let loadingView = self.makeLoadingView(for: pageIndex) else { return nil }
            
            photoViewController = AWPhotoViewController(loadingView: loadingView, notificationCenter: self.notificationCenter)
            photoViewController.addLifecycleObserver(self)
            photoViewController.delegate = self
            
            self.singleTapGestureRecognizer.require(toFail: photoViewController.zoomingImageView.doubleTapGestureRecognizer)
        }
        
        photoViewController.pageIndex = pageIndex
        photoViewController.applyPhoto(photo)
        
        let insertionIndex = self.orderedViewControllers.insertionIndex(of: photoViewController, isOrderedBefore: { $0.pageIndex < $1.pageIndex })
        self.orderedViewControllers.insert(photoViewController, at: insertionIndex.index)
        
        return photoViewController
    }
    
    fileprivate func makeLoadingView(for pageIndex: Int) -> AWLoadingViewProtocol? {
        guard let loadingViewType = self.pagingConfig.loadingViewClass as? UIView.Type else {
            assertionFailure("`loadingViewType` must be a UIView.")
            return nil
        }
        
        return loadingViewType.init() as? AWLoadingViewProtocol
    }
    
    // MARK: - Recycling
    fileprivate func recyclePhotoViewController(_ photoViewController: AWPhotoViewController) {
        if self.recycledViewControllers.contains(photoViewController) {
            return
        }
        
        if let index = self.orderedViewControllers.firstIndex(of: photoViewController) {
            self.orderedViewControllers.remove(at: index)
        }
        
        self.recycledViewControllers.append(photoViewController)
    }
    
    // MARK: - KVO
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &PhotoViewControllerLifecycleContext {
            self.lifecycleContextDidUpdate(object: object, change: change)
        } else if context == &PhotoViewControllerContentOffsetContext {
            self.contentOffsetContextDidUpdate(object: object, change: change)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func lifecycleContextDidUpdate(object: Any?, change: [NSKeyValueChangeKey : Any]?) {
        guard let photoViewController = object as? AWPhotoViewController else { return }
        
        if change?[.newKey] is NSNull {
            self.recyclePhotoViewController(photoViewController)
        }
    }
    
    fileprivate func contentOffsetContextDidUpdate(object: Any?, change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = object as? UIScrollView, !self.isSizeTransitioning else { return }
        
        var percent: CGFloat
        if self.pagingConfig.navigationOrientation == .horizontal {
            percent = (scrollView.contentOffset.x - scrollView.frame.size.width) / scrollView.frame.size.width
        } else {
            percent = (scrollView.contentOffset.y - scrollView.frame.size.height) / scrollView.frame.size.height
        }
        
        var horizontalSwipeDirection: SwipeDirection = .none
        if percent > 0 {
            horizontalSwipeDirection = .right
        } else if percent < 0 {
            horizontalSwipeDirection = .left
        }
        
        let layoutDirection: UIUserInterfaceLayoutDirection
        if #available(iOS 9.0, tvOS 9.0, *) {
            layoutDirection = UIView.userInterfaceLayoutDirection(for: self.pageViewController.view.semanticContentAttribute)
        } else {
            layoutDirection = .leftToRight
        }
        
        let swipePercent: CGFloat
        if horizontalSwipeDirection == .left {
            if layoutDirection == .leftToRight {
                swipePercent = 1 - abs(percent)
            } else {
                swipePercent = abs(percent)
            }
        } else {
            if layoutDirection == .leftToRight {
                swipePercent = abs(percent)
            } else {
                swipePercent = 1 - abs(percent)
            }
        }
        
        var lowIndex: Int = NSNotFound
        var highIndex: Int = NSNotFound
        
        let viewControllers = self.computeVisibleViewControllers(in: scrollView)
        if horizontalSwipeDirection == .left {
            guard let viewController = viewControllers.first else { return }
            
            if viewControllers.count > 1 {
                lowIndex = viewController.pageIndex
                if lowIndex < self.dataSource.numberOfPhotos {
                    highIndex = lowIndex + 1
                }
            } else {
                highIndex = viewController.pageIndex
            }
        } else if horizontalSwipeDirection == .right {
            guard let viewController = viewControllers.last else { return }
            
            if viewControllers.count > 1 {
                highIndex = viewController.pageIndex
                if highIndex > 0 {
                    lowIndex = highIndex - 1
                }
            } else {
                lowIndex = viewController.pageIndex
            }
        }
        
        guard lowIndex != NSNotFound && highIndex != NSNotFound else {
            return
        }
        
        if swipePercent < 0.5 && self.currentPhotoIndex != lowIndex  {
            self.currentPhotoIndex = lowIndex
            
            if let photo = self.dataSource.photo(at: lowIndex) {
                self.didNavigateTo(photo: photo, at: lowIndex)
            }
        } else if swipePercent > 0.5 && self.currentPhotoIndex != highIndex {
            self.currentPhotoIndex = highIndex
            
            if let photo = self.dataSource.photo(at: highIndex) {
                self.didNavigateTo(photo: photo, at: highIndex)
            }
        }
        
        self.overlayView.titleView?.tweenBetweenLowIndex(lowIndex, highIndex: highIndex, percent: percent)
    }
    
    fileprivate func computeVisibleViewControllers(in referenceView: UIScrollView) -> [AWPhotoViewController] {
        var visibleViewControllers = [AWPhotoViewController]()
        
        for viewController in self.orderedViewControllers {
            if viewController.view.frame.equalTo(.zero) {
                continue
            }
            
            let origin = CGPoint(x: viewController.view.frame.origin.x - (self.pagingConfig.navigationOrientation == .horizontal ?
                (self.pagingConfig.interPhotoSpacing / 2) : 0),
                                 y: viewController.view.frame.origin.y - (self.pagingConfig.navigationOrientation == .vertical ?
                                    (self.pagingConfig.interPhotoSpacing / 2) : 0))
            let size = CGSize(width: viewController.view.frame.size.width + ((self.pagingConfig.navigationOrientation == .horizontal) ?
                self.pagingConfig.interPhotoSpacing : 0),
                              height: viewController.view.frame.size.height + ((self.pagingConfig.navigationOrientation == .vertical) ?
                                self.pagingConfig.interPhotoSpacing : 0))
            let conversionRect = CGRect(origin: origin, size: size)
            
            if let fromView = viewController.view.superview, referenceView.convert(conversionRect, from: fromView).intersects(referenceView.bounds) {
                visibleViewControllers.append(viewController)
            }
        }
        
        return visibleViewControllers
    }
    
    // MARK: - UIPageViewControllerDataSource
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first as? AWPhotoViewController else { return }
        self.loadPhotos(at: viewController.pageIndex)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.first as? AWPhotoViewController else { return }
        self.reduceMemoryForPhotos(at: viewController.pageIndex)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let uViewController = viewController as? AWPhotoViewController else {
            assertionFailure("Paging VC must be a subclass of `AWPhotoViewController`.")
            return nil
        }
        
        return self.pageViewController(pageViewController, viewControllerAt: uViewController.pageIndex - 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let uViewController = viewController as? AWPhotoViewController else {
            assertionFailure("Paging VC must be a subclass of `AWPhotoViewController`.")
            return nil
        }
        
        return self.pageViewController(pageViewController, viewControllerAt: uViewController.pageIndex + 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAt index: Int) -> UIViewController? {
        guard index >= 0 && self.dataSource.numberOfPhotos > index else {
            return nil
        }
        
        return self.makePhotoViewController(for: index)
    }
    
    // MARK: - AWPhotoViewControllerDelegate
    public func photoViewController(_ photoViewController: AWPhotoViewController, retryDownloadFor photo: AWPhotoProtocol) {
        guard photo.aw_loadingState != .loading && photo.aw_loadingState != .loaded else { return }
        photo.aw_error = nil
        photo.aw_loadingState = .loading
        self.networkIntegration.loadPhoto(photo)
    }
    
    public func photoViewController(_ photoViewController: AWPhotoViewController,
                                    maximumZoomScaleForPhotoAt index: Int,
                                    minimumZoomScale: CGFloat,
                                    imageSize: CGSize) -> CGFloat {
        guard let photo = self.dataSource.photo(at: index) else { return .leastNormalMagnitude }
        return self.maximumZoomScale(for: photo, minimumZoomScale: minimumZoomScale, imageSize: imageSize)
    }
    
    // MARK: - AWPhotosViewControllerDelegate calls
    
    /// Called when the `AWPhotosViewController` navigates to a new photo. This is defined as when the swipe percent between pages
    /// is greater than the threshold (>0.5).
    ///
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - photo: The `AWPhoto` that was navigated to.
    ///   - index: The `index` in the dataSource of the `AWPhoto` being transitioned to.
    public func didNavigateTo(photo: AWPhotoProtocol, at index: Int) {
        self.delegate?.photosViewController(self, didNavigateTo: photo, at: index)
    }
    
    /// Called when the `AWPhotosViewController` is configuring its `OverlayView` for a new photo. This should be used to update the
    /// the overlay's title or any other overlay-specific properties.
    ///
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - overlayView: The `AWOverlayView` that is being updated.
    ///   - photo: The `AWPhoto` the overlay is being configured for.
    ///   - index: The index of the `AWPhoto` that the overlay is being configured for.
    ///   - totalNumberOfPhotos: The total number of photos in the current `dataSource`.
    public func willUpdate(overlayView: AWOverlayView, for photo: AWPhotoProtocol, at index: Int, totalNumberOfPhotos: Int) {
        if let updateBlock = overlayView.topStackContainer.stackableContainerUpdateBlock {
            updateBlock(overlayView.bottomStackContainer, photo, index, self.dataSource.numberOfPhotos)
        }
        
        if let updateBlock = overlayView.bottomStackContainer.stackableContainerUpdateBlock {
            updateBlock(overlayView.bottomStackContainer, photo, index, self.dataSource.numberOfPhotos)
        }
        
        self.delegate?.photosViewController(self,
                                            willUpdate: overlayView,
                                            for: photo,
                                            at: index,
                                            totalNumberOfPhotos: totalNumberOfPhotos)
    }
    
    /// Called when the `AWPhotoViewController` will show/hide its `OverlayView`. This method will be called inside of an
    /// animation context, so perform any coordinated animations here.
    ///
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - overlayView: The `AWOverlayView` whose visibility is changing.
    ///   - visible: A boolean that denotes whether or not the overlay will be visible or invisible.
    public func overlayView(_ overlayView: AWOverlayView, visibilityWillChange visible: Bool) {
        self.delegate?.photosViewController(self,
                                            overlayView: overlayView,
                                            visibilityWillChange: visible)
    }
    
    /// If implemented and returns a valid zoom scale for the photo (valid meaning >= the photo's minimum zoom scale), the underlying
    /// zooming image view will adopt the returned `maximumZoomScale` instead of the default calculated by the library. A good implementation
    /// of this method will use a combination of the provided `minimumZoomScale` and `imageSize` to extrapolate a `maximumZoomScale` to return.
    /// If the `minimumZoomScale` is returned (ie. `minimumZoomScale` == `maximumZoomScale`), zooming will be disabled for this image.
    ///
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - photo: The `Photo` that the zoom scale will affect.
    ///   - minimumZoomScale: The minimum zoom scale that is calculated by the library. This value cannot be changed.
    ///   - imageSize: The size of the image that belongs to the `AWPhoto`.
    /// - Returns: A "maximum" zoom scale that >= `minimumZoomScale`.
    public func maximumZoomScale(for photo: AWPhotoProtocol, minimumZoomScale: CGFloat, imageSize: CGSize) -> CGFloat {
        return self.delegate?.photosViewController(self,
                                                   maximumZoomScaleFor: photo,
                                                   minimumZoomScale: minimumZoomScale,
                                                   imageSize: imageSize) ?? .leastNormalMagnitude
    }
    
    /// Called when the action button is tapped for a photo. If you override this and fail to call super, the corresponding
    /// delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - photo: The related `AWPhoto`.
    ///
    /// - Returns:
    ///   true if the action button tap was handled, false if the default action button behavior
    ///   should be invoked.
    public func handleActionButtonTapped(photo: AWPhotoProtocol) -> Bool {
        if let result = self.delegate?.photosViewController(self, didHandleActionButtonTappedFor: photo) {
            return result
        }
        
        return false
    }
    
    /// Called when an action button action is completed. If you override this and fail to call super, the corresponding
    /// delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - photo: The related `AWPhoto`.
    /// - Note: This is only called for the default action.
    public func actionCompleted(activityType: UIActivity.ActivityType, for photo: AWPhotoProtocol) {
        self.delegate?.photosViewController(self, actionCompletedWith: activityType, for: photo)
    }
    
    // MARK: - AWNetworkIntegrationDelegate
    public func networkIntegration(_ networkIntegration: AWNetworkIntegrationProtocol, loadDidFinishWith photo: AWPhotoProtocol) {
        if let animatedImage = photo.aw_animatedImage {
            photo.aw_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.notificationCenter.post(name: .photoImageUpdate,
                                              object: photo,
                                              userInfo: [
                                                AWPhotosViewControllerNotification.AnimatedImageKey: animatedImage,
                                                AWPhotosViewControllerNotification.LoadingStateKey: AWPhotoLoadingState.loaded
                    ])
            }
        } else if let imageData = photo.imageData, let animatedImage = FLAnimatedImage(animatedGIFData: imageData) {
            photo.aw_animatedImage = animatedImage
            photo.aw_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.notificationCenter.post(name: .photoImageUpdate,
                                              object: photo,
                                              userInfo: [
                                                AWPhotosViewControllerNotification.AnimatedImageKey: animatedImage,
                                                AWPhotosViewControllerNotification.LoadingStateKey: AWPhotoLoadingState.loaded
                    ])
            }
        } else if let image = photo.image {
            photo.aw_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.notificationCenter.post(name: .photoImageUpdate,
                                              object: photo,
                                              userInfo: [
                                                AWPhotosViewControllerNotification.ImageKey: image,
                                                AWPhotosViewControllerNotification.LoadingStateKey: AWPhotoLoadingState.loaded
                    ])
            }
        }
    }
    
    public func networkIntegration(_ networkIntegration: AWNetworkIntegrationProtocol, loadDidFailWith error: Error, for photo: AWPhotoProtocol) {
        guard photo.aw_loadingState != .loadingCancelled else {
            return
        }
        
        photo.aw_loadingState = .loadingFailed
        photo.aw_error = error
        DispatchQueue.main.async { [weak self] in
            self?.notificationCenter.post(name: .photoImageUpdate,
                                          object: photo,
                                          userInfo: [
                                            AWPhotosViewControllerNotification.ErrorKey: error,
                                            AWPhotosViewControllerNotification.LoadingStateKey: AWPhotoLoadingState.loadingFailed
                ])
        }
    }
    
    public func networkIntegration(_ networkIntegration: AWNetworkIntegrationProtocol, didUpdateLoadingProgress progress: CGFloat, for photo: AWPhotoProtocol) {
        photo.aw_progress = progress
        DispatchQueue.main.async { [weak self] in
            self?.notificationCenter.post(name: .photoLoadingProgressUpdate,
                                          object: photo,
                                          userInfo: [AWPhotosViewControllerNotification.ProgressKey: progress])
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let currentPhotoIndex = self.currentPhotoIndex
        let dataSource = self.dataSource
        let zoomingImageView = self.currentPhotoViewController?.zoomingImageView
        let pagingConfig = self.pagingConfig
        
        guard !(zoomingImageView?.isScrollEnabled ?? true)
            && (pagingConfig.navigationOrientation == .horizontal
                || (pagingConfig.navigationOrientation == .vertical
                    && (currentPhotoIndex == 0 || currentPhotoIndex == dataSource.numberOfPhotos - 1))) else {
                        return false
        }
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)
            
            let isVertical = abs(velocity.y) > abs(velocity.x)
            guard isVertical else {
                return false
            }
            
            if pagingConfig.navigationOrientation == .horizontal {
                return true
            } else {
                if currentPhotoIndex == 0 {
                    return velocity.y > 0
                } else {
                    return velocity.y < 0
                }
            }
        }
        
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

// MARK: - Convenience extensions
fileprivate var PhotoViewControllerLifecycleContext: UInt8 = 0
fileprivate extension Array where Element: UIViewController {
    
    func removeLifeycleObserver(_ observer: NSObject) -> Void {
        self.forEach({ ($0 as UIViewController).removeLifecycleObserver(observer) })
    }
    
}

fileprivate extension UIViewController {
    
    func addLifecycleObserver(_ observer: NSObject) -> Void {
        self.addObserver(observer, forKeyPath: #keyPath(parent), options: .new, context: &PhotoViewControllerLifecycleContext)
    }
    
    func removeLifecycleObserver(_ observer: NSObject) -> Void {
        self.removeObserver(observer, forKeyPath: #keyPath(parent), context: &PhotoViewControllerLifecycleContext)
    }
    
}

fileprivate extension UIPageViewController {
    
    var scrollView: UIScrollView {
        get {
            guard let scrollView = self.view.subviews.filter({ $0 is UIScrollView }).first as? UIScrollView else {
                fatalError("Unable to locate the underlying `UIScrollView`")
            }
            
            return scrollView
        }
    }
    
}

fileprivate var PhotoViewControllerContentOffsetContext: UInt8 = 0
fileprivate extension UIScrollView {
    
    func addContentOffsetObserver(_ observer: NSObject) -> Void {
        self.addObserver(observer, forKeyPath: #keyPath(contentOffset), options: .new, context: &PhotoViewControllerContentOffsetContext)
    }
    
    func removeContentOffsetObserver(_ observer: NSObject) -> Void {
        self.removeObserver(observer, forKeyPath: #keyPath(contentOffset), context: &PhotoViewControllerContentOffsetContext)
    }
    
}

// MARK: - AWPhotosViewControllerDelegate
public protocol AWPhotosViewControllerDelegate: AnyObject, NSObjectProtocol {
    
    /// Called when the `AWPhotosViewController` navigates to a new photo. This is defined as when the swipe percent between pages
    /// is greater than the threshold (>0.5).
    ///
    /// - Parameters:
    ///   - photosViewController: The `AWPhotosViewController` that is navigating.
    ///   - photo: The `AWPhoto` that was navigated to.
    ///   - index: The `index` in the dataSource of the `AWPhoto` being transitioned to.
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              didNavigateTo photo: AWPhotoProtocol,
                              at index: Int)
    
    /// Called when networkIntegration try to load Photo in method 'loadPhotos(at index:)'
    ///
    /// - Parameters:
    ///   - photosViewController: The `AWPhotosViewController` that is navigating.
    ///   - photo: The `AWPhoto` that will try to load.
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              canLoad photo: inout AWPhotoProtocol,
                              didUpdate: inout Bool) -> Bool
    
    /// Called when the `AWPhotosViewController` is configuring its `OverlayView` for a new photo. This should be used to update the
    /// the overlay's title or any other overlay-specific properties.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AWPhotosViewController` that is updating the overlay.
    ///   - overlayView: The `AWOverlayView` that is being updated.
    ///   - photo: The `AWPhoto` the overlay is being configured for.
    ///   - index: The index of the `AWPhoto` that the overlay is being configured for.
    ///   - totalNumberOfPhotos: The total number of photos in the current `dataSource`.
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              willUpdate overlayView: AWOverlayView,
                              for photo: AWPhotoProtocol,
                              at index: Int,
                              totalNumberOfPhotos: Int)
    
    /// Called when the `AWPhotoViewController` will show/hide its `OverlayView`. This method will be called inside of an
    /// animation context, so perform any coordinated animations here.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AWPhotosViewController` that is updating the overlay visibility.
    ///   - overlayView: The `AWOverlayView` whose visibility is changing.
    ///   - visible: A boolean that denotes whether or not the overlay will be visible or invisible.
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              overlayView: AWOverlayView,
                              visibilityWillChange visible: Bool)
    
    /// If implemented and returns a valid zoom scale for the photo (valid meaning >= the photo's minimum zoom scale), the underlying
    /// zooming image view will adopt the returned `maximumZoomScale` instead of the default calculated by the library. A good implementation
    /// of this method will use a combination of the provided `minimumZoomScale` and `imageSize` to extrapolate a `maximumZoomScale` to return.
    /// If the `minimumZoomScale` is returned (ie. `minimumZoomScale` == `maximumZoomScale`), zooming will be disabled for this image.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AWPhotosViewController` that is updating the photo's zoom scale.
    ///   - photo: The `AWPhoto` that the zoom scale will affect.
    ///   - minimumZoomScale: The minimum zoom scale that is calculated by the library. This value cannot be changed.
    ///   - imageSize: The size of the image that belongs to the `AWPhoto`.
    /// - Returns: A "maximum" zoom scale that >= `minimumZoomScale`.
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              maximumZoomScaleFor photo: AWPhotoProtocol,
                              minimumZoomScale: CGFloat,
                              imageSize: CGSize) -> CGFloat
    
    /// Called when the action button is tapped for a photo. If no implementation is provided, will fall back to default action.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AWPhotosViewController` handling the action.
    ///   - photo: The related `Photo`.
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              didHandleActionButtonTappedFor photo: AWPhotoProtocol) -> Bool
    
    /// Called when an action button action is completed.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AWPhotosViewController` that handled the action.
    ///   - photo: The related `AWPhoto`.
    /// - Note: This is only called for the default action.
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              actionCompletedWith activityType: UIActivity.ActivityType,
                              for photo: AWPhotoProtocol)
    
    /// Called when an action button action on stackableViewContainer is completed.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AWPhotosViewController` that handled the action.
    ///   - didExecuteActionType: Action Type
    ///   - stackableViewContainer: Action Button super view
    ///   - photo: The related `AWPhoto`.
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              didExecuteActionType: AWStackableViewContainer.ActionType,
                              on stackableViewContainer: AWStackableViewContainer,
                              for photo: AWPhotoProtocol)
    
    /// Called just before the `AWPhotosViewController` begins its dismissal
    ///
    /// - Parameter photosViewController: The view controller being dismissed
    func photosViewControllerWillDismiss(_ photosViewController: AWPhotosViewController)
    
    /// Called after the `AWPhotosViewController` completes its dismissal
    ///
    /// - Parameter photosViewController: The dismissed view controller
    func photosViewControllerDidDismiss(_ photosViewController: AWPhotosViewController)
}

// MARK: - Notification definitions
// Keep Obj-C land happy
public class AWPhotosViewControllerNotification: NSObject {
    static let ProgressUpdate = Notification.Name.photoLoadingProgressUpdate.rawValue
    static let ImageUpdate = Notification.Name.photoImageUpdate.rawValue
    static let ImageKey = "AWPhotosViewControllerImage"
    static let AnimatedImageKey = "AWPhotosViewControllerAnimatedImage"
    static let ReferenceViewKey = "AWPhotosViewControllerReferenceView"
    static let LoadingStateKey = "AWPhotosViewControllerLoadingState"
    static let ProgressKey = "AWPhotosViewControllerProgress"
    static let ErrorKey = "AWPhotosViewControllerError"
}

public extension Notification.Name {
    static let photoLoadingProgressUpdate = Notification.Name("AWPhotoLoadingProgressUpdateNotification")
    static let photoImageUpdate = Notification.Name("AWPhotoImageUpdateNotification")
}
