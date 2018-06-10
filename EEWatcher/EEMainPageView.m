//
//  EEMainPageView.m
//  EEWatcher
//
//  Created by 梁明哲 on 16/7/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "EEMainPageView.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "Language.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchBarEffectController.h"

#import "ScottAlertController.h"
#import "MJRefresh.h"//下拉刷新
#define kSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
@interface EEMainPageView ()<UIScrollViewDelegate>{
    UIView* NavigationView; //导航条区域
    UIScrollView* ScrollView;
    
    UIButton* Confirm;
    UIButton* Cancel;
    UIButton* addButton;
    UICollectionView* _collection;
    UICollectionView* _list;
    UICollectionViewFlowLayout* Layout;
    UICollectionViewFlowLayout* Layout2;
    NSTimer* timer; //定时器，定时向服务器请求数据
    UIButton* setButton;
    AFHTTPSessionManager *manager;
    NSMutableDictionary *JSON;//http请求返回的JSON格式数据
    NSUserDefaults* defaults;
    UIView* MaskView;
    int tryCount;
    int noDevCount;
    UIActivityIndicatorView* activityIndicatorView;
    UILabel* titleLabel;
    HeaderView *reusableview;
    UILabel* onLineNumberLabel;
    UILabel* offLineNumberLabel;
    UILabel* abnormalNumberLabel;

}
@end
NSString* kheaderIdentifier = @"HeaderView";

@implementation EEMainPageView
singleton_m(Instance);
- (NSMutableArray*)DeviceListArray{
    _deviceListArray = [[NSMutableArray alloc]initWithCapacity:0];
    return _deviceListArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; //tableview的cell顶格显示
    self.view.opaque = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:) name:@"zuochouti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushOne) name:@"push1" object:nil];

    //导航条部分
    self.navigationItem.title = LocalizedString(@"Data_RealData");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    titleLabel.text = [defaults objectForKey:@"areaAll"];
    //右上角进入一键配置按键初始化
    UIView* btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    addButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [addButton setImage:[UIImage imageNamed:@"main1add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(AddDeviceHandle) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:addButton];
    UIBarButtonItem* rightbutton = [[UIBarButtonItem alloc]initWithCustomView:btnView];
    
    self.navigationItem.rightBarButtonItem = rightbutton;
    
    //左侧抽屉手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    UITapGestureRecognizer * twoFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerDoubleTap:)];
    [twoFingerDoubleTap setNumberOfTapsRequired:2];
    [twoFingerDoubleTap setNumberOfTouchesRequired:2];
    [self.view addGestureRecognizer:twoFingerDoubleTap];
    //左侧抽屉按键
    [self setupLeftMenuButton];
    
    UIColor * barColor = [UIColor
                          colorWithRed:247.0/255.0
                          green:249.0/255.0
                          blue:250.0/255.0
                          alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:barColor];
    [self.navigationController.view.layer setCornerRadius:10.0f];
    
//---------集合视图显示方式初始化
    Layout = [[UICollectionViewFlowLayout alloc]init];
    Layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    Layout.minimumInteritemSpacing = 1; //列间距
    Layout.minimumLineSpacing = 2; //行间距
    Layout.headerReferenceSize = CGSizeMake(320, 50);
    _collection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 49.5 - self.navigationController.navigationBar.frame.size.height - 20)  collectionViewLayout:Layout];
    _collection.delegate = self;
    _collection.dataSource = self;
    _collection.backgroundColor = [UIColor whiteColor];
    [_collection registerClass:[BlockCell class] forCellWithReuseIdentifier:@"cell"];
    _collection.alwaysBounceVertical = YES;
    //
    //下拉背景色
  UIImageView* UpCollection = [[UIImageView alloc]initWithFrame:CGRectMake(0, -[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50)];

    UpCollection.backgroundColor = [UIColor colorWithRed:44/255.0 green:115/255.0 blue:170/255.0 alpha:1];
    [_collection addSubview:UpCollection];
    
    [_collection registerClass:[HeaderView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kheaderIdentifier];
    //下拉刷新
//     _collection.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction: @selector(headerRereshing)];
//
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    
    // 设置文字
    [header setTitle:@"下拉" forState:MJRefreshStateIdle]; // 箭头向下时文字
    [header setTitle:@"松手更新" forState:MJRefreshStatePulling]; // 箭头向上时文字
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing]; // 松手刷新
    
    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:15];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置字体颜色
    [header setBackgroundColor:[UIColor colorWithRed:44/255.0 green:115/255.0 blue:170/255.0 alpha:1]];
    // 状态文字
    header.stateLabel.textColor = [UIColor whiteColor];
    // 时间字体的颜色
    header.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];

    _collection.mj_header = header;
    
    
    [self.view addSubview:_collection];
//---------列表显示方式初始化
    Layout2 = [[UICollectionViewFlowLayout alloc]init];
    Layout2.scrollDirection = UICollectionViewScrollDirectionVertical;
    Layout2.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 2,100);
    Layout2.minimumInteritemSpacing = 2; //列间距
    Layout2.minimumLineSpacing = 0; //行间距
    _list = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 50 - self.navigationController.navigationBar.frame.size.height)  collectionViewLayout:Layout2];
    _list.delegate = self;
    _list.dataSource = self;
    _list.backgroundColor = [UIColor whiteColor];
    [_list registerClass:[ListCell class] forCellWithReuseIdentifier:@"ListCell"];
    _list.alwaysBounceVertical = YES;
    [_list registerClass:[HeaderView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    //下拉刷新背景色
    UIImageView* UpList = [[UIImageView alloc]initWithFrame:CGRectMake(0, -[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50)];
    UpList.image = [UIImage imageNamed:@"stateBackBar"];
    [_collection addSubview:UpList];
    [_list addSubview:UpList];
    //下拉刷新
    
    MJRefreshNormalHeader *header2 = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    
    // 设置文字
    [header2 setTitle:@"下拉" forState:MJRefreshStateIdle]; // 箭头向下时文字
    [header2 setTitle:@"松手更新" forState:MJRefreshStatePulling]; // 箭头向上时文字
    [header2 setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing]; // 松手刷新
    
    // 设置字体
    header2.stateLabel.font = [UIFont systemFontOfSize:15];
    header2.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置字体颜色
    [header2 setBackgroundColor:[UIColor colorWithRed:44/255.0 green:115/255.0 blue:170/255.0 alpha:1]];
    // 状态文字
    header2.stateLabel.textColor = [UIColor whiteColor];
    // 时间字体的颜色
    header2.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];
    
    _list.mj_header = header2;
    //数组初始化
    _DeviceArray = [[NSMutableArray alloc]initWithCapacity:0];
    [self DeviceListArray];
    
//网络未连接覆盖层
    [self MaskView];

    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    //网络服务参数设置
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 5.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
    defaults = [NSUserDefaults standardUserDefaults];
}
/*
 *函数名:MaskView
 *功能:初始化断网的遮罩层提示界面
 */
//
- (UIView*)MaskView{
    if(!MaskView){
        //网络未连接覆盖层
        MaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH,kSCREEN_HEIGHT - 49)];
        MaskView.backgroundColor = [UIColor whiteColor];
        //网络未连接提示Label
        UILabel* NetNotConnectedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width, 60)];
        NetNotConnectedLabel.text = LocalizedString(@"Network_Error");
        NetNotConnectedLabel.font = [UIFont fontWithName:@"Arial" size:24];
        NetNotConnectedLabel.numberOfLines = 2;
        //居中对齐
        NetNotConnectedLabel.textAlignment = NSTextAlignmentCenter;
        [MaskView addSubview:NetNotConnectedLabel];
        
        UIImageView* image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,kSCREEN_WIDTH, kSCREEN_HEIGHT)];
        image.image = [UIImage imageNamed:@"main1noNet"];
        
        [MaskView addSubview:image];
        //重新加载按键初始化
        UIButton* ReloadBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/6, NetNotConnectedLabel.frame.origin.y + 120, [UIScreen mainScreen].bounds.size.width/3*2, 40)];
        ReloadBtn.layer.cornerRadius = 0;
        [ReloadBtn setTitleColor:[UIColor whiteColor] forState:normal];
        [ReloadBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [ReloadBtn setBackgroundColor: [UIColor colorWithRed:59.0/255.0 green:113/255.0 blue:164.0/255.0 alpha:1]];
        [ReloadBtn setTitle:LocalizedString(@"Reload") forState:normal];
        
        ReloadBtn.titleLabel.font = [UIFont fontWithName:@"Arial" size:20];
        [ReloadBtn addTarget:self action:@selector(reloadRealData) forControlEvents:UIControlEventTouchUpInside];
        [MaskView addSubview:ReloadBtn];
    }
    return MaskView;
}


- (void)tongzhi:(NSNotification *)text{
    //清空设备通知计数
    noDevCount = 0;
    if ([defaults objectForKey:@"areaAll"] == nil) {
        titleLabel.text = LocalizedString(@"Choose_Area");
        _DeviceArray = _deviceList;
        
        int x,y,z;
        x = 0;
        y = 0;
        z = 0;
        for (NSMutableDictionary* dic in _DeviceArray){
            if( [[dic objectForKey:@"abnormal"] isEqualToString:@"0"]){
                x++;
            }else if([[dic objectForKey:@"abnormal"] isEqualToString:@"1"]){
                y++;
            }else if([[dic objectForKey:@"abnormal"] isEqualToString:@"3"]){
                z++;
            }
        }
        onLineNumberLabel.text = [NSString stringWithFormat:@"%d",x];
        offLineNumberLabel.text = [NSString stringWithFormat:@"%d",y];
        abnormalNumberLabel.text = [NSString stringWithFormat:@"%d",z];

        
    }else{
        titleLabel.text = [defaults objectForKey:@"areaAll"];
        //重新加载数据  要不要进行请求   选择区域无需进行请求
        [self reloadRealData];
    }
    if ([[defaults objectForKey:@"show"] isEqualToString:@"List"]) {
        [self.view addSubview: _list];
        [_list reloadData];
    }else{
        [self.view addSubview: _collection];
        [_collection reloadData];
    }
    
}
/*
 *函数名: AddDeviceHandle
 *功能: 进入一键配置处理流程
 */
- (void)AddDeviceHandle{
    //移除界面中显示设备的UICollectionView，回收资源
    [_list removeFromSuperview];
    [_collection removeFromSuperview];
    //跳转到选择设备类型界面
    ChooseAddStyleViewController* Product = [[ChooseAddStyleViewController alloc]init];
    [Product setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:Product animated:YES];



}
/*
 *函数名: headerRereshing
 *功能: 刷新数据
 */
- (void)headerRereshing{
    [self getNewDataList];
}
//-------------------------------
- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    tryCount = 0;
    //第一次进入页面时间，检查区域内有无数据进行通知
    noDevCount = 0;
    if ([[defaults objectForKey:@"show"] isEqualToString:@"List"]) {
        [self.view addSubview: _list];
        [_list reloadData];
    }else{
        [self.view addSubview: _collection];
        [_collection reloadData];
    }

    if ([defaults objectForKey:@"areaAll"] == nil) {
        titleLabel.text = LocalizedString(@"Choose_Area");
    }else{
        titleLabel.text = [defaults objectForKey:@"areaAll"];
    }
    //检查App是否能正常连上外网
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == 0) {
        [self.view addSubview:MaskView];
        
    }else{
        // Do any additional setup after loading the view.
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getNewDataList) userInfo:nil repeats:YES];
        [timer fire];
    }
}

- (void)pushOne{
    DeviceSecondStageMenuController *setting=[[DeviceSecondStageMenuController alloc]init];
    [setting setHidesBottomBarWhenPushed:YES];//隐藏底层buttonbar
    [self.navigationController pushViewController:setting animated:YES];
    
}
//重新加载实时数据
- (void)reloadRealData{
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSLog(@"%ld",(long)status);
    if (status == 0) {
        [_deviceList removeAllObjects];
    }else{
        [MaskView removeFromSuperview];
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getNewDataList) userInfo:nil repeats:YES];
        [timer fire];
    }
}
//页面将离开
- (void)viewWillDisappear:(BOOL)animated{
    [MaskView removeFromSuperview];
    [timer invalidate];
}
//获取新的设备列表
- (void)getNewDataList{
    //获取账号下所有的设备序列码，组成一个列表
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"],@"curve":@"allLast"};
    manager.securityPolicy.allowInvalidCertificates = NO;
    [manager.requestSerializer setValue:@"getUserRTData" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //将设备实时数据保存到_datatest中
        if([[JSON objectForKey:@"code"]intValue] == 0){
            _deviceList = [JSON objectForKey:@"array"];
            [_DeviceArray removeAllObjects];
            [_deviceListArray removeAllObjects];
            if ([defaults objectForKey:@"areaAll"] == nil) {
                //如果当前未选择区域，则默认显示所有区域的设备
                _DeviceArray = _deviceList;
                
            }else{
                for (NSMutableDictionary* dic in _deviceList){
                    if( [[dic objectForKey:@"area"] isEqual:[defaults objectForKey:@"areaAll"]]){
                        [_DeviceArray addObject:dic];
                    }
                }
            }
            //设备区域确认好之后，进行简单的统计，在线离线设备个数
            int x,y,z;
            x = 0;
            y = 0;
            z = 0;
            
            for (NSMutableDictionary* dic in _DeviceArray){
                if([[dic objectForKey:@"abnormal"] isEqualToString:@"0"]){
                    x++;
                }else if([[dic objectForKey:@"abnormal"] isEqualToString:@"1"]){
                    y++;
                }else if([[dic objectForKey:@"abnormal"] isEqualToString:@"3"]){
                    z++;
                }
                NSString* devNamestr = [dic objectForKey:@"devName"];

                [_deviceListArray addObject:devNamestr];
            }
            onLineNumberLabel.text = [NSString stringWithFormat:@"%d",x];
            offLineNumberLabel.text = [NSString stringWithFormat:@"%d",y];
            abnormalNumberLabel.text = [NSString stringWithFormat:@"%d",z];
        }
        else{
        //请求失败，非网络原因，待补充
            
        }
        if ([[defaults objectForKey:@"show"] isEqualToString:@"List"]) {
            [self.view addSubview: _list];
            [_list reloadData];
            [_list.mj_header endRefreshing];
        }else{
            [self.view addSubview: _collection];
            [_collection reloadData];
            [_collection.mj_header endRefreshing];
        }
        //成功，清空计数，若三次请求失败将 调用MaskView盖住显示层
        tryCount = 0;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
        //请求失败，关闭hud
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        //网络异常计数+1
        tryCount ++;
        if (tryCount == 3) {
            [self.view addSubview:MaskView];
            [timer invalidate];
            
        }
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
 
    return  _DeviceArray.count;
}

//头部展示区
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader){
        if (reusableview == nil) {
            HeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
            reusableview = headerView;
            reusableview.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
//            UILabel* AreaLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, reusableview.frame.size.height/2 - 15, 80, 30)];

            //背景展示颜色，背景图
            reusableview.backgroundColor = [UIColor colorWithRed:44/255.0 green:115/255.0 blue:170/255.0 alpha:1];
            
            UIImageView* OnLineLight = [[UIImageView alloc]initWithFrame:CGRectMake(reusableview.frame.size.width/10*7, reusableview.frame.size.height/4*3 - 5, 10, 10)];
            OnLineLight.image = [UIImage imageNamed:@"main1_online.png"];
            [reusableview addSubview:OnLineLight];
            OnLineLight.layer.borderWidth = 1;
            OnLineLight.layer.borderColor = [UIColor whiteColor].CGColor;
            onLineNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(OnLineLight.frame.origin.x + OnLineLight.frame.size.width + 3, OnLineLight.frame.origin.y - 3, 60, 16)];
            onLineNumberLabel.text = @"";
            onLineNumberLabel.font = [UIFont fontWithName:@"Arial" size:14];
            onLineNumberLabel.textColor = [UIColor whiteColor];
            [reusableview addSubview:onLineNumberLabel];
            
            UIImageView* abLight = [[UIImageView alloc]initWithFrame:CGRectMake(reusableview.frame.size.width/5*4, reusableview.frame.size.height/4*3 - 5, 10, 10)];
            abLight.image = [UIImage imageNamed:@"main1_abnormal.png"];
            [reusableview addSubview:abLight];
            abLight.layer.borderWidth = 1;
            abLight.layer.borderColor = [UIColor whiteColor].CGColor;
            abnormalNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(abLight.frame.origin.x + abLight.frame.size.width + 3, abLight.frame.origin.y - 3, 60, 16)];
            abnormalNumberLabel.text = @"";
            abnormalNumberLabel.font = [UIFont fontWithName:@"Arial" size:14];
            abnormalNumberLabel.textColor = [UIColor whiteColor];
            [reusableview addSubview:abnormalNumberLabel];
            
            UIImageView* OffLineLight = [[UIImageView alloc]initWithFrame:CGRectMake(reusableview.frame.size.width/10*9, reusableview.frame.size.height/4*3 - 5, 10, 10)];
            OffLineLight.image = [UIImage imageNamed:@"main1_offline.png"];
            [reusableview addSubview:OffLineLight];
            OffLineLight.layer.borderWidth = 1;
            OffLineLight.layer.borderColor = [UIColor whiteColor].CGColor;
            offLineNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(OffLineLight.frame.origin.x + OffLineLight.frame.size.width + 3, OffLineLight.frame.origin.y - 3, 60, 16)];
            offLineNumberLabel.text = @"";
            offLineNumberLabel.font = [UIFont fontWithName:@"Arial" size:14];
            offLineNumberLabel.textColor = [UIColor whiteColor];
            [reusableview addSubview:offLineNumberLabel];

            titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,reusableview.frame.size.height/4*3 - 13, 200, 26)];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
            
            titleLabel.textAlignment = NSTextAlignmentLeft;
            
            if ([defaults objectForKey:@"areaAll"] == nil) {
                titleLabel.text = LocalizedString(@"Choose_Area");
            }else{
                titleLabel.text = [defaults objectForKey:@"areaAll"];
            }


            [reusableview addSubview:titleLabel];
        }else{
        
        }
    }
    return reusableview;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={320,40};
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _collection) {
        BlockCell *cell;
        cell = [_collection dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        cell.opaque = YES;
        cell.title.text = [_DeviceArray [indexPath.row] objectForKey:@"devName"];
        cell.temp.text = [NSString stringWithFormat:@"%@℃",[[_DeviceArray[indexPath.row] objectForKey:@"temp"] objectForKey:@"value"]];
        cell.humi.text = [NSString stringWithFormat:@"%@％",[[_DeviceArray[indexPath.row] objectForKey:@"humi"]objectForKey:@"value" ]];
        cell.lastTime.text = [NSString stringWithFormat:@"%@",[_DeviceArray[indexPath.row] objectForKey:@"time"]];
        NSLog(@"%@",[_DeviceArray[indexPath.row] objectForKey:@"time"]);
        cell.humiStatusImage.image = nil;
        cell.tempStatusImage.image = nil;
        
        if ([[_DeviceArray[indexPath.row] objectForKey:@"abnormal"] isEqualToString:@"1"]) {
            [cell.OnlineImage setImage:[UIImage imageNamed:@"main1offline"]];
            cell.tempStatusImage.image = nil;
            cell.humiStatusImage.image = nil;
            
        }else if ([[_DeviceArray[indexPath.row] objectForKey:@"abnormal"] isEqualToString:@"3"]){
            [cell.OnlineImage setImage:[UIImage imageNamed:@"main1abnormal"]];
            cell.temp.text = LocalizedString(@"t_no_sensor");
            cell.humi.text = LocalizedString(@"t_no_sensor");
            cell.lastTime.text = @"";

            cell.tempStatusImage.image = nil;
            cell.humiStatusImage.image = nil;

            //....℃
        }
        else{
            [cell.OnlineImage setImage:[UIImage imageNamed:@"main1online"]];
            //判断设备是否超出阈值并作报警提示
            if([[[_DeviceArray[indexPath.row] objectForKey:@"temp"] objectForKey:@"status"] isEqualToString:@"-1"]){
                cell.tempStatusImage.image = [UIImage imageNamed:@"main1low.png"];
            }
            else if([[[_DeviceArray[indexPath.row] objectForKey:@"temp"] objectForKey:@"status"] isEqualToString:@"0"]){
                cell.tempStatusImage.image = nil;
            }
            else if([[[_DeviceArray[indexPath.row] objectForKey:@"temp"] objectForKey:@"status"] isEqualToString:@"1"]){
                cell.tempStatusImage.image = [UIImage imageNamed:@"main1high.png"];
            }
            if([[[_DeviceArray[indexPath.row] objectForKey:@"humi"] objectForKey:@"status"] isEqualToString:@"-1"]){
                cell.humiStatusImage.image = [UIImage imageNamed:@"main1low.png"];
            }
            else if([[[_DeviceArray[indexPath.row] objectForKey:@"humi"] objectForKey:@"status"] isEqualToString:@"0"]){
                cell.humiStatusImage.image = nil;
            }
            else if([[[_DeviceArray[indexPath.row] objectForKey:@"humi"] objectForKey:@"status"] isEqualToString:@"1"]){
                cell.humiStatusImage.image = [UIImage imageNamed:@"main1high.png"];
            }

        }
        return cell;
    }
    else{
        ListCell *cell;
        cell = [_list dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
        cell.opaque = YES;
        cell.title.text = [_DeviceArray[indexPath.row] objectForKey:@"devName"];
        cell.temp.text = [NSString stringWithFormat:@"%@℃",[[_DeviceArray[indexPath.row] objectForKey:@"temp"] objectForKey:@"value"]];
        cell.humi.text = [NSString stringWithFormat:@"%@％",[[_DeviceArray[indexPath.row] objectForKey:@"humi"]objectForKey:@"value" ]];
        cell.lastTime.text = [NSString stringWithFormat:@"%@",[_DeviceArray[indexPath.row] objectForKey:@"time"]];
        if ([[_DeviceArray[indexPath.row] objectForKey:@"abnormal"] isEqualToString:@"1"]) {
            
            [cell.OnlineImage setImage:[UIImage imageNamed:@"main1offline"]];

            cell.tempStatusImage.image = nil;
            
            cell.humiStatusImage.image = nil;
            
        }else if ([[_DeviceArray[indexPath.row] objectForKey:@"abnormal"] isEqualToString:@"3"]){
            [cell.OnlineImage setImage:[UIImage imageNamed:@"main1abnormal"]];
            cell.temp.text = LocalizedString(@"t_no_sensor");
            cell.humi.text = LocalizedString(@"t_no_sensor");
            cell.lastTime.text = @"";

            cell.tempStatusImage.image = nil;
            cell.humiStatusImage.image = nil;

        }
        else{
            [cell.OnlineImage setImage:[UIImage imageNamed:@"main1online"]];
            //判断设备是否超出阈值并作报警提示
            if([[[_DeviceArray[indexPath.row] objectForKey:@"temp"] objectForKey:@"status"] isEqualToString:@"-1"]){
                cell.tempStatusImage.image = [UIImage imageNamed:@"main1low.png"];
            }
            else if([[[_DeviceArray[indexPath.row] objectForKey:@"temp"] objectForKey:@"status"] isEqualToString:@"0"]){
                cell.tempStatusImage.image = nil;
            }
            else if([[[_DeviceArray[indexPath.row] objectForKey:@"temp"] objectForKey:@"status"] isEqualToString:@"1"]){
                cell.tempStatusImage.image = [UIImage imageNamed:@"main1high.png"];
            }
            if([[[_DeviceArray[indexPath.row] objectForKey:@"humi"] objectForKey:@"status"] isEqualToString:@"-1"]){
                cell.humiStatusImage.image = [UIImage imageNamed:@"main1low.png"];
            }
            else if([[[_DeviceArray[indexPath.row] objectForKey:@"humi"] objectForKey:@"status"] isEqualToString:@"0"]){
                cell.humiStatusImage.image = nil;
            }
            else if([[[_DeviceArray[indexPath.row] objectForKey:@"humi"] objectForKey:@"status"] isEqualToString:@"1"]){
                cell.humiStatusImage.image = [UIImage imageNamed:@"main1high.png"];
            }
            
        }
        return cell;
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if(collectionView == _collection){
    return UIEdgeInsetsMake(1, 0, 0, 0);
    }else{
    return UIEdgeInsetsMake(1, 0, 0, 0);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [defaults setObject:[_DeviceArray[indexPath.row] objectForKey:@"snaddr"] forKey:@"snaddr"];
    [defaults setObject:[_DeviceArray[indexPath.row] objectForKey:@"devName"] forKey:@"deviceName"];
    NSLog(@"%@",[_DeviceArray[indexPath.row] objectForKey:@"dev_name"]);
    DeviceSecondStageMenuController* DevSetView = [[DeviceSecondStageMenuController alloc]init];
    [DevSetView setHidesBottomBarWhenPushed:YES];//隐藏底层buttonbar
    [self.navigationController pushViewController:DevSetView animated:YES];

}

//设置collection 的边界大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _collection) {
        CGSize x = {_collection.frame.size.width/3 - 1,80};
        return x;
    }else{
        CGSize x = {_list.frame.size.width - 1,102};
        return x;

    }
    
}
#pragma TableView
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//
//    return 0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 60;
//}
//
//- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString* str =@"cameraCell";
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:str];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
//    }
//    return cell;
//}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//}

#pragma Other
//点击空白处收回键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

}

- (void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    
    UIView* btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIButton* searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [searchBtn setImage:[UIImage imageNamed:@"main1search.png"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchEvent) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:searchBtn];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc]initWithCustomView:btnView];
    NSArray *actionButtonItems = @[leftDrawerButton, searchItem];
    self.navigationItem.leftBarButtonItems = actionButtonItems;
}
- (void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)rightDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

- (void)twoFingerDoubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideRight completion:nil];
}

- (void)searchEvent{
    SearchBarEffectController * search = [[SearchBarEffectController alloc]init];
    search.effectArray = _deviceListArray;
    [search show];
}

- (void)alertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        
    }];
    [alertView addAction:action];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}

@end


