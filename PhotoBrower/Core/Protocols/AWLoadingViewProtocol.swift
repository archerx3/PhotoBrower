//
//  AWLoadingViewProtocol.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

enum AWError: Error {
    case errorDescription(code: String, errorMessage: String)
}

extension AWError: LocalizedError {
    public var errorMessage: String? {
        switch self {
        case .errorDescription(_, let errorMessage):
            return errorMessage
        }
    }
}

public protocol AWLoadingViewProtocol: NSObjectProtocol {
    
    /// Called by the AXPhotoViewController when progress of the image download should be shown to the user.
    ///
    /// - Parameter initialProgress: The current progress of the image download. Exists on a scale from 0..1.
    func startLoading(initialProgress: CGFloat) -> Void
    
    /// Called by the AXPhotoViewController when progress of the image download should be hidden. This usually happens when
    /// the containing view controller is moved offscreen.
    ///
    func stopLoading() -> Void
    
    /// Called by the AXPhotoViewController when the progress of an image download is updated. The optional implementation
    /// of this method should reflect the progress of the downloaded image.
    ///
    /// - Parameter progress: The progress complete of the image download. Exists on a scale from 0..1.
    func updateProgress(_ progress: CGFloat) -> Void
    
    /// Called by the AXPhotoViewController when an image download fails. The implementation of this method should display
    /// an error to the user, and optionally, offer to retry the image download.
    ///
    /// - Parameters:
    ///   - error: The error that the image download failed with.
    ///   - retryHandler: Call this handler to retry the image download.
    func showError(_ error: Error, retryHandler: @escaping ()-> Void) -> Void
    
    /// Called by the AXPhotoViewController when an image download is being retried, or the container decides to stop
    /// displaying an error to the user.
    ///
    func removeError() -> Void
    
    /// The `AXPhotosViewController` uses this method to correctly size the loading view for a constrained width.
    ///
    /// - Parameter size: The constrained size. Use the width of this value to layout subviews.
    /// - Returns: A size that fits all subviews inside a constrained width.
    func sizeThatFits(_ size: CGSize) -> CGSize
}
