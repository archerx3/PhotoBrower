//
//  FLAnimatedImageView+AWExtensions.m
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

@import FLAnimatedImage;

#import "FLAnimatedImageView+AWExtensions.h"
#import "UIImageView+AWExtension.h"

@interface FLAnimatedImageView ()

/**
 Unfortunately, FLAnimatedImageView does not allow for setting the current frame index, however, it should work just fine
 when the requested frame is already cached.
 Internal use only.
 */
@property NSUInteger currentFrameIndex;

/**
 Unfortunately, FLAnimatedImageView does not allow for setting the current frame, however, it should work just fine
 when the requested frame is already cached.
 Internal use only.
 */
@property UIImage *currentFrame;

/**
 When the requested internal frame is not cached, set this property for display ASAP.
 Internal use only.
 */
@property BOOL needsDisplayWhenImageBecomesAvailable;

@end

@implementation FLAnimatedImageView (AWExtensions)

- (UIImageView *)aw_copy {
    FLAnimatedImageView *imageView = [super aw_copy];
    imageView.animatedImage = self.animatedImage;
    imageView.currentFrame = self.currentFrame;
    imageView.currentFrameIndex = self.currentFrameIndex;
    imageView.runLoopMode = self.runLoopMode;
    return imageView;
}

- (void)aw_syncFramesWithImageView:(FLAnimatedImageView *)imageView {
    if (!self.animatedImage || !imageView.animatedImage || ![self.animatedImage.data isEqualToData:imageView.animatedImage.data]) {
        return;
    }
    
    self.currentFrameIndex = imageView.currentFrameIndex;
    self.currentFrame = imageView.currentFrame;
    self.needsDisplayWhenImageBecomesAvailable = YES;
    [self.layer setNeedsDisplay];
}

@end
