//
//  AWStateButton.m
//  PhotoBrower
//
//  Created by archer.chen on 6/3/19.
//  Copyright © 2019 CA. All rights reserved.
//

#import "AWStateButton.h"

static NSString *_Nonnull AWStateButtonTintColorKey            = @"AWStateButtonTintColor";
static NSString *_Nonnull AWStateButtonBackgroundColorKey      = @"AWStateButtonBackgroundColor";
static NSString *_Nonnull AWStateButtonAlphaKey                = @"AWStateButtonAlpha";
static NSString *_Nonnull AWStateButtonTitleAlphaKey           = @"AWStateButtonTitleAlpha";
static NSString *_Nonnull AWStateButtonImageAlphaKey           = @"AWStateButtonImageAlpha";
static NSString *_Nonnull AWStateButtonCornerRadiusKey         = @"AWStateButtonCornerRadius";
static NSString *_Nonnull AWStateButtonBorderColorKey          = @"AWStateButtonBorderColor";
static NSString *_Nonnull AWStateButtonBorderWidthKey          = @"AWStateButtonBorderWidth";
static NSString *_Nonnull AWStateButtonTransformRotationXKey   = @"AWStateButtonTransformRotationX";
static NSString *_Nonnull AWStateButtonTransformRotationYKey   = @"AWStateButtonTransformRotationY";
static NSString *_Nonnull AWStateButtonTransformRotationZKey   = @"AWStateButtonTransformRotationZ";
static NSString *_Nonnull AWStateButtonTransformScaleKey       = @"AWStateButtonTransformScale";
static NSString *_Nonnull AWStateButtonShadowColorKey          = @"AWStateButtonShadowColor";
static NSString *_Nonnull AWStateButtonShadowOpacityKey        = @"AWStateButtonShadowOpacity";
static NSString *_Nonnull AWStateButtonShadowOffsetKey         = @"AWStateButtonShadowOffset";
static NSString *_Nonnull AWStateButtonShadowRadiusKey         = @"AWStateButtonShadowRadius";
static NSString *_Nonnull AWStateButtonShadowPathKey           = @"AWStateButtonShadowPath";

static NSString *_Nonnull AWAnimationDictionaryKey    = @"AWAnimationDictionary";
static NSString *_Nonnull AWStateBlockKey             = @"AWStateBlock";

static NSString *_Nonnull AWAnimationDictionaryAnimationKey               = @"AWAnimation";
static NSString *_Nonnull AWAnimationDictionaryAnimationLayerKeyPathKey   = @"AWAnimationLayerKeyPath";

static NSString *_Nonnull AWAnimationDefaultLayerKeyPath = @"layer";

typedef NSDictionary<NSString *, id> * AWAnimationDictionary;
typedef NSMutableDictionary<NSString *, NSArray<CAAnimation *> *> * AWAnimationKeyPathDictionary;
typedef void(^AWStateBlock)(void);

@interface AWStateButton ()

@property (nonnull) NSDictionary<NSString *, NSMutableDictionary<NSNumber *, id> *> *stateDictionary;

@end

@implementation AWStateButton

#pragma mark - Initialization
+ (instancetype)button {
    return [super buttonWithType:UIButtonTypeCustom];
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    [NSException raise:@"AWUnsupportedFactoryMethodException" format:@"Use +[AWStateButton button] instead."];
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.animateControlStateChanges = YES;
    self.controlStateAnimationDuration = 0.2;
    self.controlStateAnimationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    
    NSArray<NSString *> *keys = @[ AWStateButtonTintColorKey,
                                   AWStateButtonBackgroundColorKey,
                                   AWStateButtonAlphaKey,
                                   AWStateButtonTitleAlphaKey,
                                   AWStateButtonImageAlphaKey,
                                   AWStateButtonCornerRadiusKey,
                                   AWStateButtonBorderColorKey,
                                   AWStateButtonBorderWidthKey,
                                   AWStateButtonTransformRotationXKey,
                                   AWStateButtonTransformRotationYKey,
                                   AWStateButtonTransformRotationZKey,
                                   AWStateButtonTransformScaleKey,
                                   AWStateButtonShadowColorKey,
                                   AWStateButtonShadowOpacityKey,
                                   AWStateButtonShadowOffsetKey,
                                   AWStateButtonShadowRadiusKey ];
    
    NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, id> *> *stateDictionary = [NSMutableDictionary dictionary];
    for (NSString *key in keys) {
        stateDictionary[key] = [NSMutableDictionary dictionary];
    }
    
    self.stateDictionary = [stateDictionary copy];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self updateButtonStateWithoutAnimation];
    }
}

#pragma mark - Control state updates
- (void)setSelected:(BOOL)selected {
    BOOL updateButtonState = (self.isSelected != selected);
    
    [super setSelected:selected];
    
    if (updateButtonState) {
        [self updateButtonState];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    BOOL updateButtonState = (self.isHighlighted != highlighted);
    
    [super setHighlighted:highlighted];
    
    if (updateButtonState) {
        [self updateButtonState];
    }
}

- (void)setEnabled:(BOOL)enabled {
    BOOL updateButtonState = (self.isEnabled != enabled);
    
    [super setEnabled:enabled];
    
    if (updateButtonState) {
        [self updateButtonState];
    }
}

- (void)updateButtonStateWithoutAnimation {
    BOOL animateControlStateChanges = self.animateControlStateChanges;
    self.animateControlStateChanges = NO;
    [self updateButtonState];
    self.animateControlStateChanges = animateControlStateChanges;
}

- (void)updateButtonState {
    NSArray<NSDictionary<NSString *, id> *> *stateChanges = [self stateChangesForCurrentState];
    AWAnimationKeyPathDictionary animationsDictionary = [NSMutableDictionary dictionary];
    NSMutableArray<AWStateBlock> *stateBlocks = [NSMutableArray array];
    
    for (NSDictionary<NSString *, id> *stateChange in stateChanges) {
        AWAnimationDictionary animationDictionary = stateChange[AWAnimationDictionaryKey];
        if (animationDictionary) {
            CAAnimation *animation = animationDictionary[AWAnimationDictionaryAnimationKey];
            if (!animation) {
                continue;
            }
            
            NSString *keyPath = animationDictionary[AWAnimationDictionaryAnimationLayerKeyPathKey] ?: AWAnimationDefaultLayerKeyPath;
            if (!animationsDictionary[keyPath]) {
                animationsDictionary[keyPath] = [NSArray array];
            }
            
            NSMutableArray<CAAnimation *> *animations = [animationsDictionary[keyPath] mutableCopy];
            [animations addObject:animation];
            animationsDictionary[keyPath] = [animations copy];
        }
        
        AWStateBlock stateBlock = stateChange[AWStateBlockKey];
        if (stateBlock) {
            [stateBlocks addObject:stateBlock];
        }
    }
    
    for (NSString *keyPath in [animationsDictionary allKeys]) {
        NSArray<CAAnimation *> *animations = animationsDictionary[keyPath];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = self.controlStateAnimationDuration;
        group.timingFunction = self.controlStateAnimationTimingFunction;
        group.animations = animations;
        
        [[self valueForKeyPath:keyPath] addAnimation:group forKey:@"AWGroupAnim"];
    }
    
    for (AWStateBlock stateBlock in stateBlocks) {
        stateBlock();
    }
}

#pragma mark - Control states
- (void)setTintColor:(UIColor *)tintColor forState:(UIControlState)controlState {
    if (tintColor) {
        self.stateDictionary[AWStateButtonTintColorKey][@(controlState)] = tintColor;
    } else {
        [self.stateDictionary[AWStateButtonTintColorKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIColor *)tintColorForState:(UIControlState)controlState {
    return self.stateDictionary[AWStateButtonTintColorKey][@(controlState)];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)controlState {
    if (backgroundColor) {
        self.stateDictionary[AWStateButtonBackgroundColorKey][@(controlState)] = backgroundColor;
    } else {
        [self.stateDictionary[AWStateButtonBackgroundColorKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIColor *)backgroundColorForState:(UIControlState)controlState {
    return self.stateDictionary[AWStateButtonBackgroundColorKey][@(controlState)];
}

- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonAlphaKey][@(controlState)] = @(alpha);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)alphaForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonAlphaKey][@(controlState)] floatValue];
}

- (void)setTitleAlpha:(CGFloat)alpha forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonTitleAlphaKey][@(controlState)] = @(alpha);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)titleAlphaForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonTitleAlphaKey][@(controlState)] floatValue];
}

- (void)setImageAlpha:(CGFloat)alpha forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonImageAlphaKey][@(controlState)] = @(alpha);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)imageAlphaForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonImageAlphaKey][@(controlState)] floatValue];
}

- (void)setCornerRadius:(CGFloat)cornerRadius forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonCornerRadiusKey][@(controlState)] = @(cornerRadius);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)cornerRadiusForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonCornerRadiusKey][@(controlState)] floatValue];
}

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)controlState {
    if (borderColor) {
        self.stateDictionary[AWStateButtonBorderColorKey][@(controlState)] = borderColor;
    } else {
        [self.stateDictionary[AWStateButtonBorderColorKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIColor *)borderColorForState:(UIControlState)controlState {
    return self.stateDictionary[AWStateButtonBorderColorKey][@(controlState)];
}

- (void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonBorderWidthKey][@(controlState)] = @(borderWidth);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)borderWidthForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonBorderWidthKey][@(controlState)] floatValue];
}

- (void)setTransformRotationX:(CGFloat)radians forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonTransformRotationXKey][@(controlState)] = @(radians);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)transformRotationXForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonTransformRotationXKey][@(controlState)] floatValue];
}

- (void)setTransformRotationY:(CGFloat)radians forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonTransformRotationYKey][@(controlState)] = @(radians);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)transformRotationYForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonTransformRotationYKey][@(controlState)] floatValue];
}

- (void)setTransformRotationZ:(CGFloat)radians forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonTransformRotationZKey][@(controlState)] = @(radians);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)transformRotationZForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonTransformRotationZKey][@(controlState)] floatValue];
}

- (void)setTransformScale:(CGFloat)scale forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonTransformScaleKey][@(controlState)] = @(scale);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)transformScaleForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonTransformScaleKey][@(controlState)] floatValue];
}

- (void)setShadowColor:(UIColor *)shadowColor forState:(UIControlState)controlState {
    if (shadowColor) {
        self.stateDictionary[AWStateButtonShadowColorKey][@(controlState)] = shadowColor;
    } else {
        [self.stateDictionary[AWStateButtonShadowColorKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIColor *)shadowColorForState:(UIControlState)controlState {
    return self.stateDictionary[AWStateButtonShadowColorKey][@(controlState)];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonShadowOpacityKey][@(controlState)] = @(shadowOpacity);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)shadowOpacityForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonShadowOpacityKey][@(controlState)] floatValue];
}

- (void)setShadowOffset:(CGSize)shadowOffset forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonShadowOffsetKey][@(controlState)] = [NSValue valueWithCGSize:shadowOffset];
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGSize)shadowOffsetForState:(UIControlState)controlState {
    return [(NSValue *)self.stateDictionary[AWStateButtonShadowOffsetKey][@(controlState)] CGSizeValue];
}

- (void)setShadowRadius:(CGFloat)shadowRadius forState:(UIControlState)controlState {
    self.stateDictionary[AWStateButtonShadowRadiusKey][@(controlState)] = @(shadowRadius);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)shadowRadiusForState:(UIControlState)controlState {
    return [self.stateDictionary[AWStateButtonShadowRadiusKey][@(controlState)] floatValue];
}

- (void)setShadowPath:(UIBezierPath *)shadowPath forState:(UIControlState)controlState {
    if (shadowPath) {
        self.stateDictionary[AWStateButtonShadowPathKey][@(controlState)] = shadowPath;
    } else {
        [self.stateDictionary[AWStateButtonShadowPathKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIBezierPath *)shadowPathForState:(UIControlState)controlState {
    return self.stateDictionary[AWStateButtonShadowPathKey][@(controlState)];
}

#pragma mark - Factory methods
- (NSArray<NSDictionary<NSString *, id> *> *)stateChangesForCurrentState {
    UIControlState currentState = self.state;
    
    NSMutableArray<NSDictionary<NSString *, id> *> *stateChangesDictionary = [NSMutableArray array];
    
    [self.stateDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull propertyKey,
                                                              NSMutableDictionary<NSNumber *,id> * _Nonnull stateDictionary,
                                                              BOOL * _Nonnull stop) {
        
        UIControlState state = currentState;
        id value = stateDictionary[@(state)];
        if (!value) {
            if (state == UIControlStateNormal) {
                return;
            }
            
            // default to normal
            state = UIControlStateNormal;
            value = stateDictionary[@(state)];
            if (!value) {
                return;
            }
        }
        
        NSDictionary<NSString *, id> *changes = nil;
        
        if (propertyKey == AWStateButtonTintColorKey) {
            changes = [self tintColorStateChangesForState:state];
        } else if (propertyKey == AWStateButtonBackgroundColorKey) {
            changes = [self backgroundColorStateChangesForState:state];
        } else if (propertyKey == AWStateButtonAlphaKey) {
            changes = [self alphaStateChangesForState:state];
        } else if (propertyKey == AWStateButtonTitleAlphaKey) {
            changes = [self titleAlphaStateChangesForState:state];
        } else if (propertyKey == AWStateButtonImageAlphaKey) {
            changes = [self imageAlphaStateChangesForState:state];
        } else if (propertyKey == AWStateButtonCornerRadiusKey) {
            changes = [self cornerRadiusStateChangesForState:state];
        } else if (propertyKey == AWStateButtonBorderColorKey) {
            changes = [self borderColorStateChangesForState:state];
        } else if (propertyKey == AWStateButtonBorderWidthKey) {
            changes = [self borderWidthStateChangesForState:state];
        } else if (propertyKey == AWStateButtonTransformRotationXKey) {
            changes = [self transformRotationXStateChangesForState:state];
        } else if (propertyKey == AWStateButtonTransformRotationYKey) {
            changes = [self transformRotationYStateChangesForState:state];
        } else if (propertyKey == AWStateButtonTransformRotationZKey) {
            changes = [self transformRotationZStateChangesForState:state];
        } else if (propertyKey == AWStateButtonTransformScaleKey) {
            changes = [self transformScaleStateChangesForState:state];
        } else if (propertyKey == AWStateButtonShadowColorKey) {
            changes = [self shadowColorStateChangesForState:state];
        } else if (propertyKey == AWStateButtonShadowOpacityKey) {
            changes = [self shadowOpacityStateChangesForState:state];
        } else if (propertyKey == AWStateButtonShadowOffsetKey) {
            changes = [self shadowOffsetStateChangesForState:state];
        } else if (propertyKey == AWStateButtonShadowRadiusKey) {
            changes = [self shadowOffsetStateChangesForState:state];
        } else if (propertyKey == AWStateButtonShadowPathKey) {
            changes = [self shadowPathStateChangesForState:state];
        }
        
        if (changes) {
            [stateChangesDictionary addObject:changes];
        }
    }];
    
    return [stateChangesDictionary copy];
}

- (NSDictionary<NSString *, id> *)tintColorStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    AWStateBlock block = ^() {
        weakSelf.tintColor = [weakSelf tintColorForState:controlState];
    };
    
    return @{ AWStateBlockKey: block };
}

- (NSDictionary<NSString *, id> *)backgroundColorStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *backgroundColorKeyPath = @"backgroundColor";
        CGColorRef fromValue = (__bridge CGColorRef)([self.layer.presentationLayer valueForKeyPath:backgroundColorKeyPath]);
        CGColorRef toValue = [self backgroundColorForState:controlState].CGColor;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:backgroundColorKeyPath];
        animation.fromValue = (__bridge id _Nullable)fromValue;
        animation.toValue = (__bridge id _Nullable)toValue;
        
        AWStateBlock block = ^() {
            weakSelf.layer.backgroundColor = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.backgroundColor = [weakSelf backgroundColorForState:controlState].CGColor;
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)alphaStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *opacityKeyPath = @"opacity";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:opacityKeyPath] floatValue];
        CGFloat toValue = [self alphaForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            weakSelf.layer.opacity = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.opacity = [weakSelf alphaForState:controlState];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)titleAlphaStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *opacityKeyPath = @"opacity";
        CGFloat fromValue = [[self.titleLabel.layer.presentationLayer valueForKeyPath:opacityKeyPath] floatValue];
        CGFloat toValue = [self titleAlphaForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            weakSelf.titleLabel.layer.opacity = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation,
                                              AWAnimationDictionaryAnimationLayerKeyPathKey: @"titleLabel.layer" },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.titleLabel.layer.opacity = [weakSelf titleAlphaForState:controlState];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)imageAlphaStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *opacityKeyPath = @"opacity";
        CGFloat fromValue = [[self.imageView.layer.presentationLayer valueForKeyPath:opacityKeyPath] floatValue];
        CGFloat toValue = [self imageAlphaForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            weakSelf.imageView.layer.opacity = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation,
                                              AWAnimationDictionaryAnimationLayerKeyPathKey: @"imageView.layer" },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.imageView.layer.opacity = [weakSelf imageAlphaForState:controlState];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)cornerRadiusStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *cornerRadiusKeyPath = @"cornerRadius";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:cornerRadiusKeyPath] floatValue];
        CGFloat toValue = [self cornerRadiusForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:cornerRadiusKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            weakSelf.layer.cornerRadius = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.cornerRadius = [weakSelf cornerRadiusForState:controlState];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)borderColorStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *borderColorKeyPath = @"borderColor";
        CGColorRef fromValue = (__bridge CGColorRef)([self.layer.presentationLayer valueForKeyPath:borderColorKeyPath]);
        CGColorRef toValue = [self borderColorForState:controlState].CGColor;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:borderColorKeyPath];
        animation.fromValue = (__bridge id _Nullable)(fromValue);
        animation.toValue = (__bridge id _Nullable)(toValue);
        
        AWStateBlock block = ^() {
            weakSelf.layer.borderColor = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.borderColor = [weakSelf borderColorForState:controlState].CGColor;
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)borderWidthStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *borderWidthKeyPath = @"borderWidth";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:borderWidthKeyPath] floatValue];
        CGFloat toValue = [self borderWidthForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:borderWidthKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            weakSelf.layer.borderWidth = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.borderWidth = [weakSelf borderWidthForState:controlState];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)transformRotationXStateChangesForState:(UIControlState)controlState {
    NSString *xRotationKeyPath = @"transform.rotation.x";
    
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:xRotationKeyPath] floatValue];
        CGFloat toValue = [self transformRotationXForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:xRotationKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            [weakSelf.layer setValue:@(toValue) forKeyPath:xRotationKeyPath];
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            [weakSelf.layer setValue:@([weakSelf transformRotationXForState:controlState]) forKeyPath:xRotationKeyPath];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)transformRotationYStateChangesForState:(UIControlState)controlState {
    NSString *yRotationKeyPath = @"transform.rotation.y";
    
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:yRotationKeyPath] floatValue];
        CGFloat toValue = [self transformRotationYForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:yRotationKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            [weakSelf.layer setValue:@(toValue) forKeyPath:yRotationKeyPath];
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            [weakSelf.layer setValue:@([weakSelf transformRotationYForState:controlState]) forKeyPath:yRotationKeyPath];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)transformRotationZStateChangesForState:(UIControlState)controlState {
    NSString *zRotationKeyPath = @"transform.rotation.z";
    
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:zRotationKeyPath] floatValue];
        CGFloat toValue = [self transformRotationZForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:zRotationKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            [weakSelf.layer setValue:@(toValue) forKeyPath:zRotationKeyPath];
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            [weakSelf.layer setValue:@([weakSelf transformRotationZForState:controlState]) forKeyPath:zRotationKeyPath];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)transformScaleStateChangesForState:(UIControlState)controlState {
    NSString *scaleKeyPath = @"transform.scale";
    
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:scaleKeyPath] floatValue];
        CGFloat toValue = [self transformScaleForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:scaleKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            [weakSelf.layer setValue:@(toValue) forKeyPath:scaleKeyPath];
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            [weakSelf.layer setValue:@([weakSelf transformScaleForState:controlState]) forKeyPath:scaleKeyPath];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowColorStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowColorKeyPath = @"shadowColor";
        CGColorRef fromValue = (__bridge CGColorRef)([self.layer.presentationLayer valueForKeyPath:shadowColorKeyPath]);
        CGColorRef toValue = [self shadowColorForState:controlState].CGColor;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowColorKeyPath];
        animation.fromValue = (__bridge id _Nullable)fromValue;
        animation.toValue = (__bridge id _Nullable)toValue;
        
        AWStateBlock block = ^() {
            weakSelf.layer.shadowColor = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.shadowColor = [weakSelf shadowColorForState:controlState].CGColor;
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowOpacityStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowOpacityKeyPath = @"shadowOpacity";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:shadowOpacityKeyPath] floatValue];
        CGFloat toValue = [self shadowOpacityForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowOpacityKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            weakSelf.layer.shadowOpacity = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.shadowOpacity = [weakSelf shadowOpacityForState:controlState];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowOffsetStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowOffsetKeyPath = @"shadowOffset";
        CGSize fromValue = [[self.layer.presentationLayer valueForKeyPath:shadowOffsetKeyPath] CGSizeValue];
        CGSize toValue = [self shadowOffsetForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowOffsetKeyPath];
        animation.fromValue = [NSValue valueWithCGSize:fromValue];
        animation.toValue = [NSValue valueWithCGSize:toValue];
        
        AWStateBlock block = ^() {
            weakSelf.layer.shadowOffset = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.shadowOffset = [weakSelf shadowOffsetForState:controlState];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowRadiusStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowRadiusKeyPath = @"shadowRadius";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:shadowRadiusKeyPath] floatValue];
        CGFloat toValue = [self shadowRadiusForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowRadiusKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AWStateBlock block = ^() {
            weakSelf.layer.shadowRadius = toValue;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.shadowRadius = [weakSelf shadowRadiusForState:controlState];
        };
        
        return @{ AWStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowPathStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowPathKeyPath = @"shadowPath";
        UIBezierPath *fromValue = [self.layer.presentationLayer valueForKeyPath:shadowPathKeyPath];
        UIBezierPath *toValue = [self shadowPathForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowPathKeyPath];
        animation.fromValue = fromValue;
        animation.toValue = toValue;
        
        AWStateBlock block = ^() {
            weakSelf.layer.shadowPath = toValue.CGPath;
        };
        
        return @{
                 AWAnimationDictionaryKey: @{ AWAnimationDictionaryAnimationKey: animation },
                 AWStateBlockKey: block
                 };
    } else {
        AWStateBlock block = ^() {
            weakSelf.layer.shadowPath = [weakSelf shadowPathForState:controlState].CGPath;
        };
        
        return @{ AWStateBlockKey: block };
    }
}

@end
