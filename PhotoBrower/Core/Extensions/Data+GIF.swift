//
//  Data+GIF.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import ImageIO
import MobileCoreServices

extension Data {
    
    func containsGIF() -> Bool {
        let sourceData = self as CFData
        
        let options: [String: Any] = [kCGImageSourceShouldCache as String: false]
        guard let source = CGImageSourceCreateWithData(sourceData, options as CFDictionary?),
            let sourceContainerType = CGImageSourceGetType(source) else {
                return false
        }
        
        return UTTypeConformsTo(sourceContainerType, kUTTypeGIF)
    }
    
}
