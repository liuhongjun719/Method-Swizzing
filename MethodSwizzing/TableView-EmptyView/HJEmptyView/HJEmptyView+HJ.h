//
//  PCEmptyView+HJ.h
//  AutoCoding
//
//  Created by luo.h on 16/1/20.
//  Copyright © 2016年 PCOnline. All rights reserved.
//

#import "HJEmptyView.h"

@interface HJEmptyView (HJ)


+ (HJEmptyView *)showMessage:(NSString *)message toView:(UIView *)view;
+ (HJEmptyView *)showTitle:(NSString *)title
                   details:(NSString *)details
                  iconImag:(NSString *)imageName
                    toView:(UIView *)view;
@end
