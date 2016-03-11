//
//  UIControl+IntervalClick.m
//  ButtonIntervalClick
//
//  Created by ZpyZp on 16/2/16.
//  Copyright © 2016年 zpy. All rights reserved.
//


/**
 iOS开发- 利用runtime拦截UIButton的点击事件，防止重复点击
 */

#import "UIControl+IntervalClick.h"
#import <objc/runtime.h>
#import "NSObject+AOP.h"

static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";

static const char *UIControl_acceptedEventTime = "UIControl_acceptedEventTime";

@implementation UIControl (IntervalClick)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self aop_ExchangeInstanceSelector:@selector(sendAction:to:forEvent:) swizzledSelector:@selector(__py_sendAction:to:forEvent:) class:[UIControl class]];
    });
}

- (NSTimeInterval)py_acceptedEventTime
{
    return [objc_getAssociatedObject(self, UIControl_acceptedEventTime) doubleValue];
}

- (void)setPy_acceptedEventTime:(NSTimeInterval)uxy_acceptedEventTime
{
    objc_setAssociatedObject(self, UIControl_acceptedEventTime, @(uxy_acceptedEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSTimeInterval)py_eventInterval
{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}

-(void)setPy_eventInterval:(NSTimeInterval)py_eventInterval
{
    objc_setAssociatedObject(self, UIControl_acceptEventInterval, @(py_eventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark- swizzle
- (void)__py_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
//    NSLog(@"NSDate:%f", NSDate.date.timeIntervalSince1970);
//    NSLog(@"self.py_acceptedEventTime: %f", self.py_acceptedEventTime);
//    NSLog(@"self.py_eventInterval: %f", self.py_eventInterval);
//    NSLog(@"minus:%f", NSDate.date.timeIntervalSince1970 - self.py_acceptedEventTime);
    if (NSDate.date.timeIntervalSince1970 - self.py_acceptedEventTime < self.py_eventInterval) return;
    
    if (self.py_eventInterval > 0)
    {
        self.py_acceptedEventTime = NSDate.date.timeIntervalSince1970;
    }
    
    [self __py_sendAction:action to:target forEvent:event];
}


@end


