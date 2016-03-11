//
//  PCEmptyView.h
//  AutoCoding
//
//  Created by luo.h on 16/1/19.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^RefreshEmptyTapBlock)(UIView   *view);
typedef void(^RefreshBtnClickBlock)(UIButton *button);

@interface  HJEmptyView : UIView

@property (nonatomic,strong) UIButton *customButton;


/**labelText*/
@property(nonatomic,copy)    NSString   *labelText;
@property(nonatomic,copy)    NSString   *detailsLabelText;

/**UIFont*/
@property(nonatomic,strong)  UIFont     *labelFont;
@property(nonatomic,strong)  UIFont     *detailsLabelFont;

/**UIColor*/
@property (nonatomic,strong) UIColor    *labelColor;
@property (nonatomic,strong) UIColor    *detailsLabelColor;
@property(nonatomic,strong)  UIImage    *iconImage;


@property (nonatomic,assign) CGFloat yOffset;
@property (assign) CGFloat marginImg_Lab;
@property (assign) CGFloat marginLab_DLab;
@property (assign) CGFloat marginDLab_Btn;

@property(nonatomic,copy)  RefreshBtnClickBlock refreshBtnClickBlock;
@property(nonatomic,copy)  RefreshEmptyTapBlock refreshEmptyTapBlock;



+(instancetype)defaultEmptyView;
- (id)initWithView:(UIView *)view;

@end
