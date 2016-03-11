//
//  PCEmptyView+HJ.m
//  AutoCoding
//
//  Created by luo.h on 16/1/20.
//  Copyright © 2016年 PCOnline. All rights reserved.
//

#import "HJEmptyView+HJ.h"

@implementation HJEmptyView (HJ)

+ (HJEmptyView *)showMessage:(NSString *)message toView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    HJEmptyView *emptyView = [[HJEmptyView  alloc]initWithView:view];
    emptyView.iconImage=[UIImage imageNamed:@"no-wifi"];
    emptyView.labelText=message;
    return emptyView;
}


+ (HJEmptyView *)showTitle:(NSString *)title
                   details:(NSString *)details
                  iconImag:(NSString *)imageName
                    toView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];

    //自定义相关配置
    HJEmptyView *emptyView = [[HJEmptyView  alloc]initWithView:view];
    emptyView.iconImage=[UIImage imageNamed:imageName];
    emptyView.labelText=title;
    emptyView.detailsLabelText=details;
    return emptyView;
}


@end
