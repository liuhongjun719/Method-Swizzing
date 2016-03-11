//
//  NSObject+AOP.h
//  01-改变方法指向
//
//  Created by qianfeng on 15-10-9.
//  Copyright (c) 2015年 肖喆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AOP)


+(void)aop_ExchangeInstanceSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector class:(Class)categoryClass;

+(void)aop_ExchangeClassSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector class:(Class)categoryClass;
@end
