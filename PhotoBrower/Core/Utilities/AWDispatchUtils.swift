//
//  AWDispatchUtils.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

import Foundation

struct AWDispatchUtils {
    
    static func executeInBackground(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            DispatchQueue.global().async(execute: block)
        } else {
            block()
        }
    }
    
    static func onBackgroundThread(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            DispatchQueue.global().async {
                block()
            }
        } else {
            block()
        }
    }
    
    static func onMainThread(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
