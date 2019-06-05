//
//  AWPhotos.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

/// A simple wrapper class for `AWPhotoProtocol`.
open class AWPhoto: NSObject, AWPhotoProtocol {
    
    public init(attributedTitle: NSAttributedString? = nil,
                      attributedDescription: NSAttributedString? = nil,
                      attributedCredit: NSAttributedString? = nil,
                      imageData: Data? = nil,
                      image: UIImage? = nil,
                      url: URL? = nil,
                      identifier: String) {
        
        self.attributedTitle = attributedTitle
        self.attributedDescription = attributedDescription
        self.attributedCredit = attributedCredit
        self.imageData = imageData
        self.image = image
        self.url = url
        self.identifier = identifier
        
        super.init()
    }
    
    /// The attributed title of the image that will be displayed in the photo's `overlay`.
    public var attributedTitle: NSAttributedString?
    
    /// The attributed description of the image that will be displayed in the photo's `overlay`.
    public var attributedDescription: NSAttributedString?
    
    /// The attributed credit of the image that will be displayed in the photo's `overlay`.
    public var attributedCredit: NSAttributedString?
    
    /// The image data. If this value is present, it will be prioritized over `image`.
    /// Provide animated GIF data to this property.
    public var imageData: Data?
    
    /// The image to be displayed. If this value is present, it will be prioritized over `URL`.
    public var image: UIImage?
    
    /// The URL of the image. If present, this value will be passed to a `NetworkIntegration` to be downloaded.
    public var url: URL?
    
    public var identifier: String
    
    public func copyPhoto() -> AWPhotoProtocol {
        let copyPhoto = AWPhoto(attributedTitle: self.attributedTitle,
                                attributedDescription: self.attributedDescription,
                                attributedCredit: self.attributedCredit,
                                imageData: self.imageData,
                                image: self.image,
                                url: self.url,
                                identifier: self.identifier)
        
        return copyPhoto
    }
}
