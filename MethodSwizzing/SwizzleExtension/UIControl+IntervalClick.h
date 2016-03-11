//
//  UIControl+IntervalClick.h
//  ButtonIntervalClick
//
//  Created by ZpyZp on 16/2/16.
//  Copyright © 2016年 zpy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (IntervalClick)
@property (nonatomic, assign) NSTimeInterval py_eventInterval;   //重复点击加间隔
@end
