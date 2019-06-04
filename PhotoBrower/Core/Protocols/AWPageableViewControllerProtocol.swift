//
//  AWPageableViewControllerProtocol.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

protocol AWPageableViewControllerProtocol: class {
    
    var pageIndex: Int { get set }
    
    func prepareForReuse()
    func prepareForRecycle()
}
