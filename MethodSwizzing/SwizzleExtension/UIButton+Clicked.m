//
//  UIButton+Clicked.m
//  MethodSwizzing
//
//  Created by 123456 on 16/2/25.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "UIButton+Clicked.h"
#import <objc/runtime.h>
#import "NSObject+AOP.h"

@implementation UIButton (Clicked)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIButton aop_ExchangeInstanceSelector:@selector(touchesBegan:withEvent:) swizzledSelector:@selector(imp_TouchesBegan:withEvent:) class:[UIButton class]];
        [UIButton aop_ExchangeInstanceSelector:@selector(touchesMoved:withEvent:) swizzledSelector:@selector(imp_touchesMoved:withEvent:) class:[UIButton class]];
    });
    NSLog(@"UIButton_load.....");
}

#pragma mark- 开始点击时执行
- (void)imp_TouchesBegan:(NSSet <UITouch *> *)touches withEvent:(nullable UIEvent *)event {
//    NSLog(@"class=========:%@", touches.anyObject);
    /**
     当点击的为 "指定的" button时，则执行对应的界面的点击事件，同时执行changeColor方法
     当点击的为 "非指定的" button时，则 "只" 执行对应界面的点击事件
    */
    if (touches.anyObject.view.tag == 999999) {//指定button的tag=999999
        [self imp_TouchesBegan:touches withEvent:event];
        [self changeColor];
        NSLog(@"new action");
    }else {//非指定button
        [self imp_TouchesBegan:touches withEvent:event];
    }
}
#pragma mark- 在被点击view上移动时执行
- (void)imp_touchesMoved:(NSSet <UITouch *> *)touches withEvent:(nullable UIEvent *)event {
//    NSLog(@"class=========:%@", touches.anyObject);
    /**
     当点击的为 "指定的" button时，则执行对应的界面的点击事件，同时执行changeColor方法
     当点击的为 "非指定的" button时，则 "只" 执行对应界面的点击事件
     */
    if (touches.anyObject.view.tag == 999999) {//指定button的tag=999999
        [self imp_TouchesBegan:touches withEvent:event];
        [self changeColor];
        NSLog(@"new action");
    }else {//非指定button
        [self imp_TouchesBegan:touches withEvent:event];
    }
}

- (void)changeColor {
    if (self.backgroundColor == [UIColor redColor]) {
        self.backgroundColor = [UIColor greenColor];
    } else {
        self.backgroundColor = [UIColor redColor];
    }
}


@end
