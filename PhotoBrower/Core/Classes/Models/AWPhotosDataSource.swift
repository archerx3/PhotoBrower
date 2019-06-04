//
//  AWPhotosDataSource.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

open class AWPhotosDataSource: NSObject {
    
    public enum AWPhotosPrefetchBehavior: Int {
        case conservative = 0
        case regular      = 2
        case aggressive   = 4
    }
    
    /// The fetching behavior that the `PhotosViewController` should take action with.
    /// Setting this property to `conservative`, only the current photo will be loaded.
    /// Setting this property to `regular` (default), the current photo, the previous photo, and the next photo will be loaded.
    /// Setting this property to `aggressive`, the current photo, the previous two photos, and the next two photos will be loaded.
    fileprivate(set) var prefetchBehavior: AWPhotosPrefetchBehavior
    
    /// The photos to display in the PhotosViewController.
    fileprivate var photos: [AWPhotoProtocol]
    
    // The initial photo index to display upon presentation.
    fileprivate(set) var initialPhotoIndex: Int = 0
    
    // MARK: - Initialization
    public init(photos: [AWPhotoProtocol], initialPhotoIndex: Int, prefetchBehavior: AWPhotosPrefetchBehavior) {
        self.photos = photos
        self.prefetchBehavior = prefetchBehavior
        
        if photos.count > 0 {
            assert(photos.count > initialPhotoIndex, "Invalid initial photo index provided.")
            self.initialPhotoIndex = initialPhotoIndex
        }
        
        super.init()
    }
    
    public convenience override init() {
        self.init(photos: [], initialPhotoIndex: 0, prefetchBehavior: .regular)
    }
    
    public convenience init(photos: [AWPhotoProtocol]) {
        self.init(photos: photos, initialPhotoIndex: 0, prefetchBehavior: .regular)
    }
    
    public convenience init(photos: [AWPhotoProtocol], initialPhotoIndex: Int) {
        self.init(photos: photos, initialPhotoIndex: initialPhotoIndex, prefetchBehavior: .regular)
    }
    
    // MARK: - DataSource
    public var numberOfPhotos: Int {
        return self.photos.count
    }
    
    public func photo(at index: Int) -> AWPhotoProtocol? {
        if index < self.photos.count {
            return self.photos[index]
        }
        
        return nil
    }
    
}
