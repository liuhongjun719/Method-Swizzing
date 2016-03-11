//
//  ThirdUIViewController.m
//  MethodSwizzing
//
//  Created by 123456 on 16/2/29.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "ThirdUIViewController.h"
#import "UITableView+HJEmptyView.h"
#import "MJRefresh.h"
#import "HJEmptyView+HJ.h"


#pragma mark - 下拉刷新数据
#define PCRandomData [NSString stringWithFormat:@"随机数据---%d", arc4random_uniform(10000)]
#define PCRandomNoData [NSString stringWithFormat:@"没有数据哦！亲-%d", arc4random_uniform(10)]
#define PCRandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]


@interface ThirdUIViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) HJEmptyView *emptyView;
@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) UIButton *customButton;

@end



@implementation ThirdUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
    
    [self setUpEmptyView];
    [self setUpMJRefresh];
}



-(void)setUpEmptyView
{
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    
    //自定义空视图
    HJEmptyView  *emptyView=[HJEmptyView showTitle:@"oh,shit!!!" details:@"对不起,没有网络\n请检查网络网络是否打开" iconImag:@"no-wifi" toView:self.view];
    self.emptyView=emptyView;
    
    
    //或者 默认空视图
    //    self.emptyView=[HJEmptyView defaultEmptyView];
    
    //点击刷新按钮
    emptyView.refreshBtnClickBlock=^(UIButton *button){
        [weakSelf MJBeginRefreshing];
    };
    
    
    //轻击Empty视图回调
    emptyView.refreshEmptyTapBlock=^(UIView *view){
        [weakSelf MJBeginRefreshing];
    };
    
    self.tableView.nxEV_emptyView=self.emptyView;
}



- (void)setUpMJRefresh {
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}




- (void)loadNewData {
    
    // 模拟假数据
    if (_dataArray.count>0) {
        self.dataArray = nil;
    } else {
        for (int i = 0; i<5; i++) {
            [self.dataArray insertObject:PCRandomData atIndex:0];
        }
    }
    
    
    //刷新表格
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.dataArray.count) {
            NSArray *imageArray=@[@"icon_appstore",@"icon_camera",@"icon_dropbox",@"icon_instagram",@"icon_itunesconnect",@"icon_photos",@"placeholder_dropbox",@"placeholder_foursquare"];
            
            int  pageSize=(int)imageArray.count;
            NSInteger index=arc4random_uniform(pageSize);
            self.emptyView.iconImage=[UIImage imageNamed:imageArray[index]];
            if (( arc4random() % 10)/2==0) {
                self.emptyView.customButton=nil;
            }else{
                self.emptyView.customButton=self.customButton;
            }
        }
        
        
        // 刷新表格
        [self.tableView reloadData];
        //结束刷新状态
        [self.tableView.mj_header endRefreshing];
    });
}



-(void)MJBeginRefreshing
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.38 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.tableView.mj_header beginRefreshing];
    });
}



#pragma mark -Tableview Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

#pragma mark返回每行的单元格
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier=@"cellID";
    //初始化cell并指定其类型，也可自定义cell
    UITableViewCell *cell = (UITableViewCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.textLabel.font=[UIFont systemFontOfSize:14];
    }
    
    cell.textLabel.text=self.dataArray[indexPath.row];
    return cell;
}


- (UITableView*)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}


- (NSMutableArray *)dataArray {
    if(_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (UIButton *)customButton {
    if(_customButton == nil) {
        _customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _customButton.frame=CGRectMake(0, 0,120, 45);
        _customButton.backgroundColor=[UIColor redColor];
        _customButton.layer.cornerRadius=3;
        [_customButton setTitle:@"点击加载" forState:UIControlStateNormal];
    }
    return _customButton;
}


@end
