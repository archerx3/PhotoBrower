//
//  AWPhotoProtocol+Internal.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import FLAnimatedImage.FLAnimatedImage

enum AWPhotoLoadingState {
    case notLoaded, loading, loaded, loadingCancelled, loadingFailed
}

fileprivate struct AssociationKeys {
    static var error: UInt8 = 0
    static var progress: UInt8 = 0
    static var loadingState: UInt8 = 0
    static var animatedImage: UInt8 = 0
}

// MARK: - Internal AWPhotoProtocol extension to be used by the framework.
extension AWPhotoProtocol {
    
    var aw_progress: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociationKeys.progress) as? CGFloat ?? 0
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociationKeys.progress, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var aw_error: Error? {
        get {
            return objc_getAssociatedObject(self, &AssociationKeys.error) as? Error
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociationKeys.error, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var aw_loadingState: AWPhotoLoadingState {
        get {
            return objc_getAssociatedObject(self, &AssociationKeys.loadingState) as? AWPhotoLoadingState ?? .notLoaded
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociationKeys.loadingState, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var aw_animatedImage: FLAnimatedImage? {
        get {
            return objc_getAssociatedObject(self, &AssociationKeys.animatedImage) as? FLAnimatedImage
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociationKeys.animatedImage, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var aw_isReducible: Bool {
        get {
            return self.url != nil
        }
    }
    
}
