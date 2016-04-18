//
//  UIView+ExtendTouchRect.m
//  MethodSwizzing
//
//  Created by 123456 on 16/4/18.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "UIView+ExtendTouchRect.h"
#import "NSObject+AOP.h"
#import <objc/runtime.h>

@implementation UIView (ExtendTouchRect)
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [UIView aop_ExchangeClassSelector:@selector(pointInside:withEvent:) swizzledSelector:@selector(imp_pointInside:withEvent:) class:[UIButton class]];
//    });
//}

- (BOOL)imp_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.touchExtendInset, UIEdgeInsetsZero) || self.hidden ||
        ([self isKindOfClass:UIControl.class] && !((UIControl *)self).enabled)) {
        return [self imp_pointInside:point withEvent:event]; // original implementation
    }
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.touchExtendInset);
    hitFrame.size.width = MAX(hitFrame.size.width, 0); // don't allow negative sizes
    hitFrame.size.height = MAX(hitFrame.size.height, 0);
    return CGRectContainsPoint(hitFrame, point);
}
static char touchExtendInsetKey;
- (void)setTouchExtendInset:(UIEdgeInsets)touchExtendInset {
    objc_setAssociatedObject(self, &touchExtendInsetKey, [NSValue valueWithUIEdgeInsets:touchExtendInset],
                             OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)touchExtendInset {
    return [objc_getAssociatedObject(self, &touchExtendInsetKey) UIEdgeInsetsValue];
}

@end
