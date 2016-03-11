//
//  UITableView+HJEmptyView.m
//  AutoCoding
//
//  Created by luo.h on 16/1/20.
//  Copyright © 2016年 PCOnline. All rights reserved.
//

#import "UITableView+HJEmptyView.h"
#import <objc/runtime.h>
#import "NSObject+AOP.h"

static const NSString *NXEmptyViewAssociatedKey = @"NXEmptyViewAssociatedKey";

@implementation UITableView (HJEmptyView)
#pragma mark Entry

+ (void)load;
{
    [self aop_ExchangeInstanceSelector:@selector(reloadData) swizzledSelector:@selector(nxEV_reloadData) class:[UITableView class]];
    [self aop_ExchangeInstanceSelector:@selector(layoutSubviews) swizzledSelector:@selector(nxEV_layoutSubviews) class:[UITableView class]];
}

#pragma mark Properties
- (BOOL)nxEV_hasRowsToDisplay;
{
    NSUInteger numberOfRows = 0;
    for (NSInteger sectionIndex = 0; sectionIndex < self.numberOfSections; sectionIndex++) {
        numberOfRows += [self numberOfRowsInSection:sectionIndex];
    }
    return (numberOfRows > 0);
}


@dynamic nxEV_emptyView;
- (UIView *)nxEV_emptyView;
{
    return objc_getAssociatedObject(self, &NXEmptyViewAssociatedKey);
}

- (void)setNxEV_emptyView:(UIView *)value;
{
    if (self.nxEV_emptyView.superview) {
        [self.nxEV_emptyView removeFromSuperview];
    }
    objc_setAssociatedObject(self, &NXEmptyViewAssociatedKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self nxEV_updateEmptyView];
}



#pragma mark Updating
- (void)nxEV_updateEmptyView;
{
    UIView *emptyView = self.nxEV_emptyView;
    if (!emptyView) return;
    
    if (emptyView.superview != self) {
        [self addSubview:emptyView];
    }
    
    // setup empty view frame
    CGRect frame = self.bounds;
    frame.origin = CGPointMake(0, 0);
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(CGRectGetHeight(self.tableHeaderView.frame), 0, 0, 0));
    frame.size.height -= self.contentInset.top;
    emptyView.frame = frame;
    emptyView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    // check available data
    BOOL emptyViewShouldBeShown = (self.nxEV_hasRowsToDisplay == NO);
    
    // show / hide empty view
    emptyView.hidden = !emptyViewShouldBeShown;
}


#pragma mark Swizzle methods
- (void)nxEV_reloadData;
{
    // this calls the original reloadData implementation
    [self nxEV_reloadData];
    
    [self nxEV_updateEmptyView];
}

- (void)nxEV_layoutSubviews;
{
    // this calls the original layoutSubviews implementation
    [self nxEV_layoutSubviews];
    
    [self nxEV_updateEmptyView];
}

@end