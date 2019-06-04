//
//  UIImageView+AWExtension.h
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (AWExtension)

/**
 Copy a UIImageView's with its base attributes
 
 @return A copy of the UIImageView
 @note Does not conform to NSCopying (may conflict with another definition)
 */
- (__kindof UIImageView *_Nonnull)aw_copy;

@end

NS_ASSUME_NONNULL_END
