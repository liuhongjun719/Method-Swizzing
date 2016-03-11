//
//  NSObject+AOP.m
//  01-改变方法指向
//
//  Created by qianfeng on 15-10-9.
//  Copyright (c) 2015年 肖喆. All rights reserved.
//

#import "NSObject+AOP.h"
#import <objc/runtime.h>

@implementation NSObject (AOP)

+(void)aop_ExchangeInstanceSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector class:(Class)categoryClass {
    NSLog(@"class-------:%@", [self class]);
    Method originalMethod = class_getInstanceMethod(categoryClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(categoryClass, swizzledSelector);
    
    BOOL success = class_addMethod(categoryClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(categoryClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {//改变两个方法的具体指针指向
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+(void)aop_ExchangeClassSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector class:(Class)categoryClass {
    Method originalMethod = class_getClassMethod(categoryClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(categoryClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end
