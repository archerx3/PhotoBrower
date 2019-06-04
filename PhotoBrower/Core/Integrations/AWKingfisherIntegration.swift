//
//  AWKingfisherIntegration.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Kingfisher

class AWKingfisherIntegration: NSObject, AWNetworkIntegrationProtocol {
    
    weak public var delegate: AWNetworkIntegrationDelegate?
    
    fileprivate var retrieveImageTasks: [Int: DownloadTask] = [:]
    
    public func loadPhoto(_ photo: AWPhotoProtocol) {
        if photo.imageData != nil || photo.image != nil {
            AWDispatchUtils.executeInBackground { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.networkIntegration(self, loadDidFinishWith: photo)
            }
            return
        }
        
        guard let url = photo.url else { return }
        
        let progress: DownloadProgressBlock = { [weak self] (receivedSize, totalSize) in
            AWDispatchUtils.executeInBackground { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.networkIntegration(self, didUpdateLoadingProgress: CGFloat(receivedSize) / CGFloat(totalSize), for: photo)
            }
        }
        
        let completion: ((Result<RetrieveImageResult, KingfisherError>) -> Void) = { [weak self] (result) in
            guard let `self` = self else { return }
            
            self.retrieveImageTasks[photo.hash] = nil
            
            switch result {
            case .success(let retrieveImageResult):
                if let imageData = retrieveImageResult.image.kf.gifRepresentation() {
                    photo.imageData = imageData
                    AWDispatchUtils.executeInBackground { [weak self] in
                        guard let `self` = self else { return }
                        self.delegate?.networkIntegration(self, loadDidFinishWith: photo)
                    }
                } else {
                    photo.image = retrieveImageResult.image
                    AWDispatchUtils.executeInBackground { [weak self] in
                        guard let `self` = self else { return }
                        self.delegate?.networkIntegration(self, loadDidFinishWith: photo)
                    }
                }
            case .failure(let error):
                let error = NSError(
                    domain: AWNetworkIntegrationErrorDomain,
                    code: AWNetworkIntegrationFailedToLoadErrorCode,
                    userInfo: ["description": error.errorDescription ?? ""]
                )
                AWDispatchUtils.executeInBackground { [weak self] in
                    guard let `self` = self else { return }
                    self.delegate?.networkIntegration(self, loadDidFailWith: error, for: photo)
                }
            }
        }
        
        let task = KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: progress, completionHandler: completion)
        self.retrieveImageTasks[photo.hash] = task
    }
    
    func cancelLoad(for photo: AWPhotoProtocol) {
        guard let downloadTask = self.retrieveImageTasks[photo.hash] else { return }
        downloadTask.cancel()
    }
    
    func cancelAllLoads() {
        self.retrieveImageTasks.forEach({ $1.cancel() })
        self.retrieveImageTasks.removeAll()
    }
    
}
