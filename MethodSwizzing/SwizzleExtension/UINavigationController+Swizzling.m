//
//  UINavigationController+Swizzling.m
//  MethodSwizzing
//
//  Created by 123456 on 16/2/26.
//  Copyright © 2016年 wany. All rights reserved.
//




/**
 如果对某些界面进行权限判断的时候，我们不妨使用Runtime面向切面编程来进行处理，这样不仅能够将我们的业务逻辑与模型分开，而且还能够在不更改源代码的情况下进行功能性的添加，保证了程序的稳定性。
 */

#import "UINavigationController+Swizzling.h"
#import "NSObject+AOP.h"

@implementation UINavigationController (Swizzling)
+(void)load{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        [self aop_ExchangeInstanceSelector:@selector(pushViewController:animated:) swizzledSelector:@selector(aop_pushViewController:animated:) class:[UINavigationController class]];
    });
}

- (void)aop_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"-----aop_pushViewController----");
    
    //配置明确,那些页面需要权限控制
    //plist 文件来进行配置填写
    NSArray * tmp = @[@"GPMineDetailController",@"GPFoodDetailController",@"GPHomeDetailController"];
    
    NSString * className = NSStringFromClass([viewController class]);
//    NSLog(@"className=========: %@", className);
//    for (NSString * name in tmp)
//    {
//        if ([name isEqualToString:className])
//        {
//            NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
//            
//            //如果没有去到用户名,说名没有登录过
//            //那么就跳转到登录页面
//            if (![ud objectForKey:@"name"])
//            {
//                //跳转到登录页面
//                GPLoginController * login = [[GPLoginController alloc] init];
//                UINavigationController * navLogin = [[UINavigationController alloc] initWithRootViewController:login];
//                [self presentViewController:navLogin animated:YES completion:nil];
//                
//                return ;
//            }
//            
//        }
//        
//    }
    
    
    [self aop_pushViewController:viewController animated:animated];
    
}
@end
