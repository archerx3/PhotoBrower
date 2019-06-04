//
//  FLAnimatedImageView+AWExtensions.h
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

@import FLAnimatedImage.FLAnimatedImageView;

NS_ASSUME_NONNULL_BEGIN

@interface FLAnimatedImageView (AWExtensions)

/**
 Syncs the sender's frames with the `imageView` passed in.
 
 @param imageView The `imageView` to inherit from.
 */
- (void)aw_syncFramesWithImageView:(nullable FLAnimatedImageView *)imageView;

@end

NS_ASSUME_NONNULL_END
