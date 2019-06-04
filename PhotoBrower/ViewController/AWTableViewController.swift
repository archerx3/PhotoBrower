//
//  AWTableViewController.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation
import FLAnimatedImage
import Kingfisher

class AWTableViewController: UITableViewController, AWPhotosViewControllerDelegate, UIViewControllerPreviewingDelegate {
    
    let ReuseIdentifier = "AWReuseIdentifier"
    
    var previewingContext: UIViewControllerPreviewing?
    
    weak var photosViewController: AWPhotosViewController?
    
    let photos = [
        AWPhoto(attributedTitle: NSAttributedString(
            string: "IMG-20161012-WA0000.jpg"),
                attributedDescription: NSAttributedString(string: "QmbZEXnNgyrsNUVSStAYB8DMZKexbmS8JbaRG7FyKTrpk1"),
                url: URL(string: "https://beta.axel.network/ipfs/QmVXvma8DXZwLh5NSTXzrGXxbXfAZyJmAXqusjVP6GRasV"),
                identifier: "QmVXvma8DXZwLh5NSTXzrGXxbXfAZyJmAXqusjVP6GRasV")
        ,
        AWPhoto(attributedTitle: NSAttributedString(string: "IMG_0367.JPG"),
                attributedDescription: NSAttributedString(string: "Qmb8WTyc4P2eVsMeq1ByD13eFw6ocZpXpCZt82UGxp9spy"),
                url: URL(string: "https://beta.axel.network/ipfs/Qmb8WTyc4P2eVsMeq1ByD13eFw6ocZpXpCZt82UGxp9spy"),
                identifier: "Qmb8WTyc4P2eVsMeq1ByD13eFw6ocZpXpCZt82UGxp9spy")
        ,
        AWPhoto(attributedTitle: NSAttributedString(string: "IMG_1445.PSD"),
                attributedDescription: NSAttributedString(string: "QmYgRRaQaTgs5Wgyz7cXrrYhCYCuTYiVTVLr3x1bEUMJm3"),
                url: URL(string: "https://beta.axel.network/ipfs/QmYgRRaQaTgs5Wgyz7cXrrYhCYCuTYiVTVLr3x1bEUMJm3"),
                identifier: "QmYgRRaQaTgs5Wgyz7cXrrYhCYCuTYiVTVLr3x1bEUMJm3")
        ,
        AWPhoto(attributedTitle: NSAttributedString(string: "IMG_1742.JPG"),
                attributedDescription: NSAttributedString(string: "QmegXU2Tpx6gVcnKCcH3qLTA6au422okw3S12p1yX7wjz6"),
                url: URL(string: "https://beta.axel.network/ipfs/QmegXU2Tpx6gVcnKCcH3qLTA6au422okw3S12p1yX7wjz6"),
                identifier: "QmegXU2Tpx6gVcnKCcH3qLTA6au422okw3S12p1yX7wjz6")
        ,
        AWPhoto(attributedTitle: NSAttributedString(string: "IMG_2346.JPG"),
                attributedDescription: NSAttributedString(string: "QmQyVW2E3d7rEWPjUxaxq8mb7dKrKWXDW41YZUkLjUxNVk"),
                url: URL(string: "https://beta.axel.network/ipfs/QmQyVW2E3d7rEWPjUxaxq8mb7dKrKWXDW41YZUkLjUxNVk"),
                identifier: "QmQyVW2E3d7rEWPjUxaxq8mb7dKrKWXDW41YZUkLjUxNVk")
        ,
        AWPhoto(attributedTitle: NSAttributedString(string: "IMG_2369.JPG"),
                attributedDescription: NSAttributedString(string: "QmWTwtf24Hwk9BoeZ9QspQo8QSiV72wR7VE6if5EfkzvRB"),
                url: URL(string: "https://beta.axel.network/ipfs/QmWTwtf24Hwk9BoeZ9QspQo8QSiV72wR7VE6if5EfkzvRB"),
                identifier: "QmWTwtf24Hwk9BoeZ9QspQo8QSiV72wR7VE6if5EfkzvRB")
        ,
        AWPhoto(attributedTitle: NSAttributedString(string: "new,share,upload showing under shared by me.JPG"),
                attributedDescription: NSAttributedString(string: "QmcCpG46FhrHro34CURXTeuy4c85RNd2RPyAj1ofFopRE6"),
                url: URL(string:"https://beta.axel.network/ipfs/QmcCpG46FhrHro34CURXTeuy4c85RNd2RPyAj1ofFopRE6"),
                identifier: "QmcCpG46FhrHro34CURXTeuy4c85RNd2RPyAj1ofFopRE6")
//        ,
//        AWPhoto(attributedTitle: NSAttributedString(
//            string: "Niagara Falls"),
//                image: UIImage(named: "niagara-falls"
//            )
//        ),
//        AWPhoto(attributedTitle: NSAttributedString(string: "The Flash Poster",
//                                                    attributes:[
//                                                        .font: UIFont.italicSystemFont(ofSize: 24),
//                                                        .paragraphStyle: {
//                                                            let style = NSMutableParagraphStyle()
//                                                            style.alignment = .right
//                                                            return style
//                                                        }()
//                    ]), attributedDescription: NSAttributedString(string: "Season 3",
//                                                                  attributes:[
//                                                                    .paragraphStyle: {
//                                                                        let style = NSMutableParagraphStyle()
//                                                                        style.alignment = .right
//                                                                        return style
//                                                                    }()
//                        ]), attributedCredit: NSAttributedString(string: "Vignette",
//                                                                 attributes:[
//                                                                    .paragraphStyle: {
//                                                                        let style = NSMutableParagraphStyle()
//                                                                        style.alignment = .right
//                                                                        return style
//                                                                    }()
//                            ]), url: URL(string: "https://goo.gl/T4oZudY")),
//        AWPhoto(attributedTitle: NSAttributedString(string: "Tall Building"),
//                attributedDescription: NSAttributedString(string: "... And subsequently tall image"),
//                attributedCredit: NSAttributedString(string: "Wikipedia"),
//                image: UIImage(named: "burj-khalifa")),
//        AWPhoto(attributedTitle: NSAttributedString(string: "The Flash: Rebirth"),
//                attributedDescription: NSAttributedString(string: "Comic Book"),
//                attributedCredit: NSAttributedString(string: "DC Comics"),
//                url: URL(string: "https://goo.gl/9wgyAo")),
//        AWPhoto(attributedTitle: NSAttributedString(string: "The Flash has a cute smile"),
//                attributedDescription: nil,
//                attributedCredit: NSAttributedString(string: "Giphy"),
//                url: URL(string: "https://media.giphy.com/media/IOEcl8A8iLIUo/giphy.gif")),
//        AWPhoto(attributedTitle: NSAttributedString(string: "The Flash slinging a rocket"),
//                attributedDescription: nil,
//                attributedCredit: NSAttributedString(string: "Giphy"),
//                url: URL(string: "https://media.giphy.com/media/lXiRDbPcRYfUgxOak/giphy.gif"))
    ]
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 9.0, *) {
            if self.traitCollection.forceTouchCapability == .available {
                if self.previewingContext == nil {
                    self.previewingContext = self.registerForPreviewing(with: self, sourceView: self.tableView)
                }
            } else if let previewingContext = self.previewingContext {
                self.unregisterForPreviewing(withContext: previewingContext)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier)
        self.tableView.estimatedRowHeight = 350
        self.tableView.rowHeight = 350
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.size.height,
                                                            left: 0,
                                                            bottom: 0,
                                                            right: 0)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 300.0
        
        if let _ = self.photos[indexPath.row].identifier {
            height = 44.0
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier) else { return UITableViewCell() }
        
        if let id = self.photos[indexPath.row].identifier {
            cell.textLabel!.text = id
        } else if cell.contentView.viewWithTag(666) == nil {
            // sample project worst practices top kek
            let imageView = FLAnimatedImageView()
            imageView.tag = 666
            imageView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            imageView.layer.cornerRadius = 20
            imageView.layer.masksToBounds = true
            imageView.contentMode = UIView.ContentMode(rawValue: Int(arc4random_uniform(UInt32(13))))!;
            cell.contentView.addSubview(imageView)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let imageView = cell.contentView.viewWithTag(666) as? FLAnimatedImageView else { return }
        
        self.cancelLoad(at: indexPath, for: imageView)
        self.loadContent(at: indexPath, into: imageView)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let imageView = cell?.contentView.viewWithTag(666) as? FLAnimatedImageView
        
        var transitionInfo: AWTransitionInfo? = nil
        
        if imageView != nil, imageView?.image != nil {
            transitionInfo = AWTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (photo, index) -> UIImageView? in
                guard let `self` = self else { return nil }
                
                let indexPath = IndexPath(row: index, section: 0)
                guard let cell = self.tableView.cellForRow(at: indexPath) else { return nil }
                
                // adjusting the reference view attached to our transition info to allow for contextual animation
                return cell.contentView.viewWithTag(666) as? FLAnimatedImageView
            }
        }
        
        let dataSource = AWPhotosDataSource(photos: self.photos, initialPhotoIndex: indexPath.row)
        let pagingConfig = AWPagingConfig(loadingViewClass: AWCustomLoadingView.self)
        
        
        let overlayView = AWOverlayView.init(bottomStackContainer: AWStackableViewToolbarContainer.init(views: [], anchoredAt: .bottom))
        
        if let bottomStackContainer = overlayView.bottomStackContainer as? AWStackableViewToolbarContainer {
            bottomStackContainer.stackableContainerSetupBlock = { (container) in
                if let toolbar = container.toolbar as? AWBottomStackToolbar {
                    toolbar.customLabel.text = "0"
                }
            }
            
            bottomStackContainer.stackableContainerUpdateBlock = { (container, photo, index, total) in
                if let toolbar = container.toolbar as? AWBottomStackToolbar {
                    toolbar.customLabel.text = "\(index + 1)"
                    toolbar.customLabel.sizeToFit()
                }
            }
        }
        
        let photosViewController = AWPhotosViewController(dataSource: dataSource,
                                                           pagingConfig: pagingConfig,
                                                           transitionInfo: transitionInfo,
                                                           overlay: overlayView)
        
        photosViewController.delegate = self
        
        self.present(photosViewController, animated: true)
        self.photosViewController = photosViewController
    }
    
    // MARK: - AWPhotosViewControllerDelegate
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              didNavigateTo photo: AWPhotoProtocol,
                              at index: Int) {
        
    }
    
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              willUpdate overlayView: AWOverlayView,
                              for photo: AWPhotoProtocol,
                              at index: Int,
                              totalNumberOfPhotos: Int) {
    }
    
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              overlayView: AWOverlayView,
                              visibilityWillChange visible: Bool) {
        
    }
    
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              maximumZoomScaleFor photo: AWPhotoProtocol,
                              minimumZoomScale: CGFloat,
                              imageSize: CGSize) -> CGFloat {
        return 0
    }
    
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              handleActionButtonTappedFor photo: AWPhotoProtocol) {
        
    }
    
    func photosViewController(_ photosViewController: AWPhotosViewController,
                              actionCompletedWith activityType: UIActivity.ActivityType,
                              for photo: AWPhotoProtocol) {
        
    }
    
    func photosViewControllerWillDismiss(_ photosViewController: AWPhotosViewController) {
        
    }
    
    func photosViewControllerDidDismiss(_ photosViewController: AWPhotosViewController) {
        
    }
    
    // MARK: - Loading
    func loadContent(at indexPath: IndexPath, into imageView: FLAnimatedImageView) {
        
        func layoutImageView(with result: Any?) {
            let maxSize: CGFloat = 280
            var imageViewSize: CGSize
            if let animatedImage = result as? FLAnimatedImage {
                imageViewSize = (animatedImage.size.width > animatedImage.size.height) ?
                    CGSize(width: maxSize,height: (maxSize * animatedImage.size.height / animatedImage.size.width)) :
                    CGSize(width: maxSize * animatedImage.size.width / animatedImage.size.height, height: maxSize)
                
                AWDispatchUtils.onMainThread {
                    imageView.frame.size = imageViewSize
                    if let superview = imageView.superview {
                        imageView.center = superview.center
                    }
                }
            } else if let image = result as? UIImage {
                imageViewSize = (image.size.width > image.size.height) ?
                    CGSize(width: maxSize, height: (maxSize * image.size.height / image.size.width)) :
                    CGSize(width: maxSize * image.size.width / image.size.height, height: maxSize)
                
                AWDispatchUtils.onMainThread {
                    imageView.frame.size = imageViewSize
                    if let superview = imageView.superview {
                        imageView.center = superview.center
                    }
                }
            }
        }
        
        if let imageData = self.photos[indexPath.row].imageData {
            AWDispatchUtils.onBackgroundThread {
                let image = FLAnimatedImage(animatedGIFData: imageData)
                AWDispatchUtils.onMainThread {
                    imageView.animatedImage = image
                    layoutImageView(with: image)
                }
            }
        } else if let image = self.photos[indexPath.row].image {
            AWDispatchUtils.onMainThread {
                imageView.image = image
                layoutImageView(with: image)
            }
        } else if let url = self.photos[indexPath.row].url {
            let option: KingfisherOptionsInfo = [.downloadPriority(0.9), .backgroundDecode]
            
            print("-- ImageViewer begin try to load image url: \(url.absoluteString)")
            
            let progress: DownloadProgressBlock = { /*[weak self]*/ (receivedSize, totalSize) in
//                AWDispatchUtils.executeInBackground { [weak self] in
//                    guard let `self` = self else { return }
//                }
                print("-- ImageViewer loading imageURL: \(url.absoluteString),\n expectedSize: \(totalSize), downloaded: \(receivedSize)")
            }
            
            let completion: ((Result<RetrieveImageResult, KingfisherError>) -> Void) = { /*[weak self]*/ (result) in
                //guard let `self` = self else { return }
                
                switch result {
                case .success(let retrieveImageResult):
                    print("-- ImageViewer finished loading imageURL: \(url.absoluteString) successfully!")
                    layoutImageView(with: retrieveImageResult.image)
                case .failure(let err):
                    print("-- ImageViewer finished loading imageURL: \(url.absoluteString), error: \(err)")
                }
            }
            
            imageView.kf.setImage(with: url, placeholder: nil, options: option, progressBlock: progress, completionHandler: completion)
        }
    }
    
    func cancelLoad(at indexPath: IndexPath, for imageView: FLAnimatedImageView) {
        imageView.kf.cancelDownloadTask()
        imageView.animatedImage = nil
        imageView.image = nil
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location),
            let cell = self.tableView.cellForRow(at: indexPath),
            let imageView = cell.contentView.viewWithTag(666) as? FLAnimatedImageView else {
                return nil
        }
        
        previewingContext.sourceRect = self.tableView.convert(imageView.frame, from: imageView.superview)
        
        let dataSource = AWPhotosDataSource(photos: self.photos, initialPhotoIndex: indexPath.row)
        let previewingPhotosViewController = AWPreviewingPhotosViewController(dataSource: dataSource)
        
        return previewingPhotosViewController
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let previewingPhotosViewController = viewControllerToCommit as? AWPreviewingPhotosViewController {
            self.present(AWPhotosViewController(from: previewingPhotosViewController), animated: false)
        }
    }
}
