//
//  FiveViewController.m
//  MethodSwizzing
//
//  Created by 123456 on 16/4/18.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "FiveViewController.h"
#import "UIButton+ExtendTouchRect.h"

@implementation FiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.extendButton.touchExtendInset = UIEdgeInsetsMake(-100, -100, -100, -100);
}
- (IBAction)clickMeAction:(id)sender {
    NSLog(@"clcik me!");
}

@end
