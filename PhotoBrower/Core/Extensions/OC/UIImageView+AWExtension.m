//
//  UIImageView+AWExtension.m
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

#import "UIImageView+AWExtension.h"

@implementation UIImageView (AWExtension)

- (UIImageView *)aw_copy {
    UIImageView *imageView = [[[self class] alloc] init];
    imageView.image = self.image;
    imageView.highlightedImage = self.highlightedImage;
    imageView.animationImages = self.animationImages;
    imageView.highlightedAnimationImages = self.highlightedAnimationImages;
    imageView.animationDuration = self.animationDuration;
    imageView.animationRepeatCount = self.animationRepeatCount;
    imageView.highlighted = self.isHighlighted;
    imageView.tintColor = self.tintColor;
    imageView.transform = self.transform;
    imageView.frame = self.frame;
    imageView.layer.cornerRadius = self.layer.cornerRadius;
    imageView.layer.masksToBounds = self.layer.masksToBounds;
    imageView.contentMode = self.contentMode;
    return imageView;
}

@end
