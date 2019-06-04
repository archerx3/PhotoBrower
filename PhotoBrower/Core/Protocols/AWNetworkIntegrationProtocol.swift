//
//  AWNetworkIntegrationProtocol.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

let AWNetworkIntegrationErrorDomain = "AWNetworkIntegrationErrorDomain"
let AWNetworkIntegrationFailedToLoadErrorCode = 6

public protocol AWNetworkIntegrationProtocol: AnyObject, NSObjectProtocol {
    
    var delegate: AWNetworkIntegrationDelegate? { get set }
    
    /// This function should load a provided photo, calling all necessary `AWNetworkIntegrationDelegate` delegate methods.
    ///
    /// - Parameter photo: The photo to load.
    func loadPhoto(_ photo: AWPhotoProtocol)
    
    /// This function should cancel the load (if possible) for the provided photo.
    ///
    /// - Parameter photo: The photo load to cancel.
    func cancelLoad(for photo: AWPhotoProtocol)
    
    /// This function should cancel all current photo loads.
    func cancelAllLoads()
    
}

public protocol AWNetworkIntegrationDelegate: AnyObject, NSObjectProtocol {
    
    /// Called when a `AWPhoto` successfully finishes loading.
    ///
    /// - Parameters:
    ///   - networkIntegration: The `NetworkIntegration` that was performing the load.
    ///   - photo: The related `Photo`.
    /// - Note: This method is expected to be called on a background thread. Be mindful of this when retrieving items from a memory cache.
    func networkIntegration(_ networkIntegration: AWNetworkIntegrationProtocol,
                            loadDidFinishWith photo: AWPhotoProtocol)
    
    /// Called when a `AWPhoto` fails to load.
    ///
    /// - Parameters:
    ///   - networkIntegration: The `NetworkIntegration` that was performing the load.
    ///   - error: The error that the load failed with.
    ///   - photo: The related `Photo`.
    /// - Note: This method is expected to be called on a background thread.
    func networkIntegration(_ networkIntegration: AWNetworkIntegrationProtocol,
                            loadDidFailWith error: Error,
                            for photo: AWPhotoProtocol)
    
    /// Called when a `AWPhoto`'s loading progress is updated.
    ///
    /// - Parameters:
    ///   - networkIntegration: The `NetworkIntegration` that is performing the load.
    ///   - progress: The progress of the `AWPhoto` load represented as a percentage. Exists on a scale from 0..1.
    ///   - photo: The related `AWPhoto`.
    /// - Note: This method is expected to be called on a background thread.
    func networkIntegration(_ networkIntegration: AWNetworkIntegrationProtocol,
                            didUpdateLoadingProgress progress: CGFloat,
                            for photo: AWPhotoProtocol)
    
}
