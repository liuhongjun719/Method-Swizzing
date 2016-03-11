
//
//  PCEmptyView.m
//  AutoCoding
//
//  Created by luo.h on 16/1/19.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "HJEmptyView.h"
#import "UIView+Frame.h"

static const CGFloat LABEL_MAX_Height = 80.f;//文本最大高度
#define KRGBColor(r,g,b)    ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1])


@interface HJEmptyView ()
@property (nonatomic,strong)  UIButton    *refreshBtn;   //刷新按钮
@property (nonatomic,strong)  UIImageView *iconImageView;  //图标
@property (nonatomic,strong)  UILabel     *label;     //提示信息
@property (nonatomic,strong)  UILabel     *detailsLabel;     //提示信息
@end

@implementation HJEmptyView

/**计算文本1 CGSize*/
static inline CGSize LableExpectedSize(NSString *text,UIFont *font,CGSize maxSize){
    if (text>0) {
        //计算大小
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary * attributes = @{NSFontAttributeName : font,
                                      NSParagraphStyleAttributeName : paragraphStyle};
        return  [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    return CGSizeZero;
}



- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.userInteractionEnabled = YES;
        
        [self initHUDConfig];
        [self addSingleGestureRecognizer];
        
        [self addSubview:self.iconImageView];
        [self addSubview:self.label];
        [self addSubview:self.detailsLabel];        
        
        [self registerForKVO];//注册KVO

    }
    return self;
}


/**
 *  初始化设置
 */
-(void)initHUDConfig
{
    self.labelText = nil;
    self.detailsLabelText = nil;
    self.iconImage=nil;
    
    self.labelFont = [UIFont boldSystemFontOfSize:16.f];
    self.labelColor = KRGBColor(46, 46, 46);
    self.detailsLabelFont = [UIFont boldSystemFontOfSize:12.f];
    self.detailsLabelColor = KRGBColor(100, 100, 100);
    
    self.yOffset=0;
    self.marginImg_Lab=20.f;
    self.marginLab_DLab=20.f;
    self.marginDLab_Btn=20.f; 
}


-(void)addSingleGestureRecognizer
{
    UITapGestureRecognizer* singleRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    //点击的次数
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    //给self添加一个手势监测；
    [self addGestureRecognizer:singleRecognizer];
}

-(void)singleTap:(UITapGestureRecognizer *)recognizer{
    if (self.refreshEmptyTapBlock) {
        self.refreshEmptyTapBlock(recognizer.view);
    }
}


// 重新刷新按钮的点击事件
- (void)refreshBtnClicked:(UIButton *)sender{
    if (self.refreshBtnClickBlock) {
        self.refreshBtnClickBlock(sender);
    }
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
//    UIView *parent = self.superview;
//    if (parent) {
//        self.frame = parent.bounds;
//    }
    
    CGFloat marginImg_Lab=0;
    CGFloat marginLab_DLab=0;
    CGFloat marginDLab_Btn=0;

    if (self.iconImageView.image) {
        marginImg_Lab=self.marginImg_Lab;
    }
    if (self.label.text>0) {
        marginLab_DLab=self.marginLab_DLab;
        self.label.height=25;
    }else{
        self.label.height=0;
    }
    
    if (self.detailsLabel.text>0) {
        marginDLab_Btn=self.marginDLab_Btn;
    }
    
    /*计算UI控件CGSize*/
    self.label.size=LableExpectedSize(_labelText,_labelFont,CGSizeMake(_label.bounds.size.width,LABEL_MAX_Height));
    self.detailsLabel.size=LableExpectedSize(_detailsLabel.text, _detailsLabel.font,CGSizeMake(_detailsLabel.bounds.size.width,LABEL_MAX_Height));
    self.iconImageView.size=CGSizeMake(self.iconImage.size.width, self.iconImage.size.height);
    
    
    CGFloat contentHeight = self.iconImageView.height + marginImg_Lab + self.label.height +marginLab_DLab+self.detailsLabel.height+ marginDLab_Btn + self.refreshBtn.height;
    
    CGFloat topBottomMargin = (self.height - contentHeight) / 2-self.yOffset;
    
    self.iconImageView.centerX = self.width / 2;
    self.iconImageView.top = topBottomMargin;

    self.label.top = self.iconImageView.bottom + marginImg_Lab;
    self.label.centerX = self.iconImageView.centerX;
    
    self.detailsLabel.top = self.label.bottom + marginLab_DLab;
    self.detailsLabel.centerX = self.width / 2;
    
    self.refreshBtn.top =  self.detailsLabel.bottom + marginDLab_Btn;//详情可能不需要设置
    self.refreshBtn.centerX = self.width / 2;
}






#pragma mark-
#pragma mark------KVO  ----
- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}


/*通过KVO 集中处理 属性setter方法*/
- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects: @"labelText", @"labelFont", @"labelColor",
            @"detailsLabelText", @"detailsLabelFont", @"detailsLabelColor",@"iconImage",@"customButton",nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    } else {
        [self updateUIForKeypath:keyPath];
    }
}

- (void)updateUIForKeypath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"mode"] || [keyPath isEqualToString:@"customView"] ||
        [keyPath isEqualToString:@"activityIndicatorColor"]) {
        
    } else if ([keyPath isEqualToString:@"labelText"]) {
        _label.text = self.labelText;
    } else if ([keyPath isEqualToString:@"labelFont"]) {
        _label.font = self.labelFont;
    } else if ([keyPath isEqualToString:@"labelColor"]) {
        _label.textColor = self.labelColor;
    } else if ([keyPath isEqualToString:@"detailsLabelText"]) {
        _detailsLabel.text = self.detailsLabelText;
    } else if ([keyPath isEqualToString:@"detailsLabelFont"]) {
        _detailsLabel.font = self.detailsLabelFont;
    } else if ([keyPath isEqualToString:@"detailsLabelColor"]) {
        _detailsLabel.textColor = self.detailsLabelColor;
    }else if ([keyPath isEqualToString:@"iconImage"]) {
        _iconImageView.image = self.iconImage;
    }else if ([keyPath isEqualToString:@"customButton"]) {
        [_refreshBtn removeFromSuperview];
        _refreshBtn=nil;
    }
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}


#pragma mark----UILazyLoad----
- ( UIButton *)refreshBtn {
    
    if(_refreshBtn == nil) {
        if (self.customButton!=nil) {
            _refreshBtn=self.customButton;
        }else{
            _refreshBtn= [[UIButton alloc]init];
            [_refreshBtn setTitle:@"点击刷新" forState:(UIControlStateNormal)];
            _refreshBtn.layer.masksToBounds = YES;
            _refreshBtn.layer.cornerRadius = 3.0f;
            _refreshBtn.layer.borderColor = [UIColor redColor].CGColor;
            _refreshBtn.layer.borderWidth = 0.5;
            _refreshBtn.backgroundColor = [UIColor clearColor];
            [_refreshBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
            [_refreshBtn sizeToFit];
            _refreshBtn.size = CGSizeMake(240/2, 70/2);
            [_refreshBtn.titleLabel setFont:[UIFont systemFontOfSize:30/2]];
        }
        
        [_refreshBtn addTarget:self action:@selector(refreshBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_refreshBtn];
	}
	return _refreshBtn;
}


- ( UIImageView *)iconImageView {
	if(_iconImageView == nil) {
        // 图标187.5, 333.5
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image =self.iconImage;
        imageView.frame=CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
        _iconImageView = imageView;
        [self addSubview:_iconImageView];
	}
	return _iconImageView;
}



/* 主标题只显示一行*/
- ( UILabel *)label {
	if(_label == nil) {
        // label
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.adjustsFontSizeToFitWidth = NO;
        _label.numberOfLines=0;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.opaque = NO;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = self.labelColor;
        _label.font = self.labelFont;
        _label.text = self.labelText;
        [self addSubview:_label];
    }
	return _label;
}


/** 详情--多行 */
- ( UILabel  *)detailsLabel {
    if(_detailsLabel == nil) {
        _detailsLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _detailsLabel.adjustsFontSizeToFitWidth = NO;
        _detailsLabel.textAlignment = NSTextAlignmentCenter;
        _detailsLabel.opaque = NO;
        _detailsLabel.backgroundColor = [UIColor clearColor];
        _detailsLabel.numberOfLines = 0;
        _detailsLabel.font = self.detailsLabelFont;
        _detailsLabel.text = self.detailsLabelText;
        _detailsLabel.textColor = self.detailsLabelColor;
        [self addSubview:_detailsLabel];
    }
    return _detailsLabel;
}


+(instancetype)defaultEmptyView
{
    return [[HJEmptyView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
}

- (void)dealloc {
    [self unregisterFromKVO];
}


@end
