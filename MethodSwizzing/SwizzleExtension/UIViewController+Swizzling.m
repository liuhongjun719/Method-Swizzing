//
//  UIViewController+Swizzling.m
//  MethodSwizzing
//
//  Created by 123456 on 16/2/24.
//  Copyright © 2016年 wany. All rights reserved.
//


//  官方文档types详细的说明地址(https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1),
/*
 
 
 为啥要用Method swizzled
 例如要做统计 ，可以项目中每个viewWillAppear 中都要添加统计的代码, 如果界面多的话，那么就会产生大量的冗余代码
 所以就诞生了Method swizzled，我们希望在执行系统viewWillAppear的时候自动执行我们自定义的方法mrc_viewWillAppear
 
 一个category 就搞定了，不用建一个父类去写这些东西，也不用一个一个界面的viewWillAppear 去写统计代码
 */

#import "UIViewController+Swizzling.h"
#import <objc/runtime.h>
#import "NSObject+AOP.h"
//#import "MobClick.h"

@implementation UIViewController (Swizzling)
//+load 方法是当类或分类被添加到 Objective-C runtime 时被调用的
+(void)load{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        //用于友盟统计监测 进入 界面的次数
        [self aop_ExchangeInstanceSelector:@selector(viewWillAppear:) swizzledSelector:@selector(mrc_viewWillAppear:) class:[UIViewController class]];
//        NSLog(@"%p", @selector(viewWillAppear:));
        
        //用于友盟统计监测 退出 界面的次数
        [self aop_ExchangeInstanceSelector:@selector(viewWillDisappear:) swizzledSelector:@selector(mrc_viewWillDisappear:) class:[UIViewController class]];
    });
}

- (void)mrc_myButtonClicked:(id)sender {
    
}
#pragma mark- 将要出现界面时(1.当对应的UIViewController界面有导航控制器时，会先调用一次mrc_viewWillAppear方法(原因有待研究)，再调用viewWillAppear方法，执行完viewWillAppear方法后再执行一次mrc_viewWillAppear方法；2.当对应的UIViewController界面没有导航控制器时，会先执行viewWillAppear方法，再执行mrc_viewWillAppear方法)
- (void)mrc_viewWillAppear:(BOOL)animated {
    
    /*
     诶,这里写[self mrc_viewWillAppear:animated]; 不就造成递归了么?
     难道你忘了，调用方法名，真正实现方法的跟这个方法名关联的IMP，而IMP  已经被我们改了，此时调用mrc_viewWillAppear 实际是调用viewWillAppear
     */
    
    //防止会因为有UINavigationController 或 UIInputWindowController而调用次数变多
    if ([NSStringFromClass([self class]) isEqualToString:@"UINavigationController"] || [NSStringFromClass([self class]) isEqualToString:@"UIInputWindowController"]) {
        NSLog(@"-------------------");
        return;
    }

    [self mrc_viewWillAppear:animated];
    NSLog(@"mrc_viewWillAppear");
    NSLog(@"page_class: %@", NSStringFromClass([self class]));
    
    //在这里添加友盟统计，统计每个页面的 进入情况
    //例如:
//    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

#pragma mark- 将要退出界面时
- (void)mrc_viewWillDisappear:(BOOL)animated {
    if ([NSStringFromClass([self class]) isEqualToString:@"UINavigationController"] || [NSStringFromClass([self class]) isEqualToString:@"UIInputWindowController"]) {
        return;
    }
    
    [self mrc_viewWillDisappear:animated];
    NSLog(@"mrc_viewWillDisappear");
    NSLog(@"page_class: %@", NSStringFromClass([self class]));
    
    //在这里添加友盟统计，统计每个页面的 退出情况
    //例如:
//    [MobClick endLogPageView:NSStringFromClass([self class])];
}

/*
 
 2016-02-24 15:22:37.751 MethodSwizzing[14977:940190] mrc_viewWillAppear
 2016-02-24 15:22:37.751 MethodSwizzing[14977:940190] page_class: UINavigationController
 2016-02-24 15:22:37.758 MethodSwizzing[14977:940190] mrc_viewWillAppear
 2016-02-24 15:22:37.758 MethodSwizzing[14977:940190] page_class: ViewController
 2016-02-24 15:22:37.765 MethodSwizzing[14977:940190] mrc_viewWillAppear
 2016-02-24 15:22:37.765 MethodSwizzing[14977:940190] page_class: UIInputWindowController
 
 */
@end
