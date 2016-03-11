//
//  SecondViewController.m
//  MethodSwizzing
//
//  Created by 123456 on 16/2/24.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "SecondViewController.h"
#import "UIControl+IntervalClick.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UIButton *intervalButton;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.intervalButton.py_eventInterval = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- 利用runtime拦截UIButton的点击事件，防止重复点击
- (IBAction)delayIntervalClicked:(id)sender {
    NSLog(@"Interval Runtime按钮被点击了");
}
#pragma mark- 连续点击情况
- (IBAction)noIntervalClicked:(id)sender {
    NSLog(@"No Interval按钮被点击了");
}

@end
