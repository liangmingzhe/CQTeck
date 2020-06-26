//
//  DeviceAreaView.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/11/30.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "DeviceAreaView.h"
#import "DeviceSetController.h"
@interface DeviceAreaView ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray* AreaArray;
    UITableView* AreaTableView;
    NSUserDefaults* defaults;
    AFHTTPSessionManager *manager;
    NSMutableDictionary *JSON;//http请求返回的JSON格式数据
    NSString* DevAreastr;//
    NSTimer* TipsTimer;
}

@end

@implementation DeviceAreaView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"l_devicearea", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIButton* SetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0 , 60, 30)];
    [SetButton setTitle:NSLocalizedString(@"l_modify", nil) forState:normal];
    [SetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [SetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [SetButton addTarget:self action:@selector(setAndGoBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]initWithCustomView:SetButton];
    self.navigationItem.rightBarButtonItem = rightButton;

    
    AreaTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/9*8)];
    AreaTableView.dataSource = self;
    AreaTableView.delegate = self;
    AreaTableView.scrollEnabled = NO;//列表不可滚动
    AreaTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:AreaTableView];

    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
}

- (void)viewWillAppear:(BOOL)animated{
    defaults = [NSUserDefaults standardUserDefaults];
    DevAreastr = [[[DeviceSetController sharedInstance2]Dic1]objectForKey:@"area"];
    [self requestAllArea];
}
- (void)requestAllArea{

    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"]};
    manager.securityPolicy.allowInvalidCertificates = NO;

    [manager POST:cqtek_api parameters:params headers:@{@"type":@"getAreaInfo"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        
        NSMutableDictionary* JSON2 = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"请求成功JSON:%@", JSON2);
        if ([[JSON2 objectForKey:@"code"]intValue] == 0) {
            AreaArray = [JSON2 objectForKey:@"array"];
            [AreaTableView reloadData];
        }else{
            [self AlertView:[JSON2 objectForKey:@"msg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
        [self AlertView:@"请求超时，请检查网络"];
    }];

}

//修改分组并返回
- (void)setAndGoBack{
    //网络服务参数设置
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"],@"snaddr":[defaults objectForKey:@"snaddr"],@"area":DevAreastr};
    manager.securityPolicy.allowInvalidCertificates = NO;

    [manager POST:cqtek_api parameters:params headers:@{@"type":@"setDevArea"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"请求成功JSON:%@", JSON);
        if ([[JSON objectForKey:@"code" ]intValue] == 0) {
            [self AlertView:@"设备区域修改成功"];
        }else{
            NSLog(@"%@",[JSON objectForKey:@"msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
        [self AlertView:@"设备区域修改失败"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //由实际分组的个数决定
    return AreaArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* SeCell= @"cell";
    UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SeCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:18];
    cell.textLabel.text = AreaArray [indexPath.row];
    if ([DevAreastr isEqualToString: AreaArray[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DevAreastr = AreaArray[indexPath.row];
    [tableView reloadData];
}
- (void)AlertView:(NSString*)string{
    UIAlertController * Tips = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:Tips animated:YES completion:nil];
    
    TipsTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(TipsHandle) userInfo:nil repeats:NO];
    
}
- (void)TipsHandle{
    [TipsTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
