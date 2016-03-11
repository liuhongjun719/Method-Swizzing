//
//  UIImage+Swizzling.m
//  MethodSwizzing
//
//  Created by 123456 on 16/2/26.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "UIImage+Swizzling.h"
#import "NSObject+AOP.h"
#import <objc/runtime.h>
#import "UIImage+Swizzling.h"

@implementation UIImage (Swizzling)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIImage aop_ExchangeClassSelector:@selector(imageNamed:) swizzledSelector:@selector(imp_ImageNamed:) class:[UIImage class]];
    });
}

//使用此方法替换系统的方法
+ (UIImage *)imp_ImageNamed:(NSString *)name {
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    
    if ( version >= 7.0) {
        name = [name stringByAppendingString:@"_ios7"];
    }
    //交换之后 imp_ImageNamed 就是imageNamed ，所以这个return就是系统的方法，这个要注意
    return [UIImage imp_ImageNamed:name];
}
@end
