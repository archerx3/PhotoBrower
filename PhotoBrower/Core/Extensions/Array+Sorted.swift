//
//  Array+Sorted.swift
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

extension Array {
    
    func insertionIndex(of element: Element, isOrderedBefore: (Element, Element) -> Bool) -> (index: Int, alreadyExists: Bool) {
        var lowIndex = 0
        var highIndex = self.count - 1
        
        while lowIndex <= highIndex {
            let midIndex = (lowIndex + highIndex) / 2
            if isOrderedBefore(self[midIndex], element) {
                lowIndex = midIndex + 1
            } else if isOrderedBefore(element, self[midIndex]) {
                highIndex = midIndex - 1
            } else {
                return (midIndex, true)
            }
        }
        
        return (lowIndex, false)
    }
    
}
