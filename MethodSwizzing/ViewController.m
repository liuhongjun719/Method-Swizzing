//
//  ViewController.m
//  MethodSwizzing
//
//  Created by wany on 15/7/10.
//  Copyright (c) 2015年 wany. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

-(void)viewWillAppear:(BOOL)animated{
    //这句不能少，否则无法成功, 原因：执行下面这句话是因为该类属于ViewController，所以调用下面的方法会保证当返回的类也属于ViewController类型时会调用方法mrc_viewWillAppear，否则不会执行
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

- (IBAction)myButtonClicked:(id)sender {
    NSLog(@"button_clicked....");
}



@end
