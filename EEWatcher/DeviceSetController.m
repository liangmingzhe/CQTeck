//
//  DeviceSetController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/11/29.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "DeviceSetController.h"
#import "ScottAlertController.h"
#import "AFNetworking.h"
#import "SearchBarEffectController.h"
#import "cqtekHeader.pch"
#import "Request.h"
#import "Language.h"
@interface DeviceSetController ()<UITableViewDelegate,UITableViewDataSource>{
    UIButton* DevNameBtn;//设备名称修改按键
    UIButton* ThresholdBtn;//阈值修改按键
    UITableView* ItemTableView; //显示列表

    AFHTTPSessionManager *manager;//网络请求管理
    NSMutableDictionary *JSON;//http请求返回的JSON格式数据
    NSTimer* timer;//定时器
    
    NSUserDefaults* defaults;
    UIView* MaskView;
    NSInteger timeOut;
    NSTimer* TipsTimer;
    NSString* devGap;
}


@end

@implementation DeviceSetController
    singleton_m(Instance2);
- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    //背景色设备白色
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.navigationItem.title = LocalizedString(@"l_deviceset");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    ItemTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    ItemTableView.dataSource = self;
    ItemTableView.delegate = self;
//    ItemTableView.scrollEnabled = NO;//列表不可滚动
    ItemTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIButton* deleteButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/16, ItemTableView.frame.size.height/4*3, ItemTableView.frame.size.width/8*7, 50)];
    deleteButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:22];
    [deleteButton setTitle:[NSString stringWithFormat:@"%@",LocalizedString(@"deleteDevice")] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    deleteButton.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:78.0/255.0 blue:67.0/255.0 alpha:1];
    deleteButton.layer.cornerRadius = 3;
    deleteButton.layer.shadowOffset = CGSizeMake(1, 1);
    deleteButton.layer.shadowOpacity = 0.3;
    deleteButton.layer.shadowColor =  [UIColor blackColor].CGColor;
    [deleteButton addTarget:self action:@selector(if_delete) forControlEvents:UIControlEventTouchUpInside];
    [ItemTableView addSubview: deleteButton];

    //网络未连接覆盖层
    MaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height)];
    MaskView.backgroundColor = [UIColor whiteColor];
    //网络未连接提示Label
    UILabel* NetNotConnectedLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50,[UIScreen mainScreen].bounds.size.height/2 , 100, 30)];
    NetNotConnectedLabel.text = LocalizedString(@"Network_Error");
    NetNotConnectedLabel.backgroundColor = [UIColor orangeColor];
    [MaskView addSubview:NetNotConnectedLabel];
    //重新加载按键初始化
    UIButton* ReloadBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2  - 100, NetNotConnectedLabel.frame.origin.y + 40, 200, 30)];
    
    ReloadBtn.backgroundColor = [UIColor greenColor];
    [ReloadBtn setTitle:LocalizedString(@"Reload") forState:normal];
    [ReloadBtn addTarget:self action:@selector(reloadRealData) forControlEvents:UIControlEventTouchUpInside];
    [MaskView addSubview:ReloadBtn];

    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];

    [self.view addSubview:ItemTableView];

    
}
- (void)if_delete{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:@"是否删除该设备?"];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        NSDictionary *params = @{@"snaddr":[defaults objectForKey:@"snaddr"],@"user":[defaults objectForKey:@"cqUser"]};
        manager.securityPolicy.allowInvalidCertificates = NO;
        [manager.requestSerializer setValue:@"delDevice" forHTTPHeaderField:@"type"];
        [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"请求成功:%@", responseObject);
            JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"请求成功JSON:%@", JSON);
            if ([[JSON objectForKey:@"code"] longValue] == 0) {
                [self AlertView:LocalizedString(@"delete_success") type:1];
                
            
            }else if([[JSON objectForKey:@"code"] longValue] == 2){
                [self AlertView:[JSON objectForKey:@"msg"] type:1];
            }
            NSLog(@"%@",[JSON objectForKey:@"code"]);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"请求失败:%@", error.description);
            [self AlertView:LocalizedString(@"delete_failed") type:0];
        }];
        
    }];
    ScottAlertAction *action2 = [ScottAlertAction actionWithTitle:LocalizedString(@"Cancel") style:ScottAlertActionStyleDestructive handler:nil];
    [alertView addAction:action];
    [alertView addAction:action2];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
}

- (void)goBackView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    timeOut = 0;
    //网络服务参数设置
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getDevinfo) userInfo:nil repeats:YES];
    [timer fire];
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setParameter:@"accessToken" value:@"CQY"];
    [request setHeader:@"type" value:@"getAccountMobileList"];
    [Request Post:cqtek_api outTime:15
          success:^(NSDictionary *data) {
              if ([[data objectForKey:@"code"]intValue] == 0) {
                  _listArray = [data objectForKey:@"mobileList"];
                  
              }
          } failure:^(NSError *error) {
              NSLog(@"网络问题，操作失败");
          }];
}


- (void)reloadRealData{
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == 0) {
        
    }else{
        [MaskView removeFromSuperview];
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getDevinfo) userInfo:nil repeats:YES];
        [timer fire];

    }
}

//获取设备基本信息
- (void)getDevinfo{
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"]
                             ,@"snaddr":[defaults objectForKey:@"snaddr"]};
    
    manager.securityPolicy.allowInvalidCertificates = NO;
    [manager.requestSerializer setValue:@"getDevInfo" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"请求成功JSON:%@", JSON);
        if([[JSON objectForKey:@"code"]intValue] == 0){
            _Dic1 = JSON;
        }else{
        
        }
        [ItemTableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
        timeOut ++;
        if (timeOut == 3) {
            [timer invalidate];
            //三次请求失败提示超时，显示MaskView界面
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//  设置列表Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    return [NSString stringWithFormat:@"SN:%@",[defaults objectForKey:@"snaddr"]];
 
}
// 列表cell个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DevSetCell*cell = [[[NSBundle mainBundle]loadNibNamed:@"DevSetCell" owner:nil options:nil] lastObject];
        switch (indexPath.row) {
            case 0:
                cell.ItemName.text = LocalizedString(@"l_devicename");
                cell.ItemValue.text = [_Dic1 objectForKey:@"devName"];
                break;
            case 1:
                cell.ItemName.text = LocalizedString(@"l_deivcearea");
                cell.ItemValue.text = [_Dic1 objectForKey:@"area"];
                break;
            case 2:
                cell.ItemName.text = LocalizedString(@"l_devicethreshold");
                cell.ItemValue.text = @"";
                break;
            case 3:
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.ItemName.text = LocalizedString(@"l_deviceinterval");
                cell.ItemValue.text = [NSString stringWithFormat:@"%@ %@",[_Dic1 objectForKey:@"devGap"],LocalizedString(@"l_second")];
                break;
            case 4:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.ItemName.text = LocalizedString(@"l_devicealarm");
                cell.ItemValue.text = LocalizedString(@"t_message_and_call");
                break;
            default:
                cell.ItemValue.text = @"--";
                
                break;
        }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ModifyDevNameView* modifyName = [[ModifyDevNameView alloc]init];
    DeviceAreaView* modifyArea = [[DeviceAreaView alloc]init];
    ModifyThresholdView* modifyThread = [[ModifyThresholdView alloc]init];
//    ModifyUpDateTime* modifyUpdateTime = [[ModifyUpDateTime alloc]init];
    
    switch (indexPath.row) {
        case 0:
            //修改设备名称
            if ([[_Dic1 objectForKey:@"authority"]intValue] == 1) {
                [self.navigationController pushViewController:modifyName animated:YES];
            }else{
                [self AlertView:LocalizedString(@"t_no_authority") type:0];
            }

            break;
        case 1:
            //修改设备的区域
            if ([[_Dic1 objectForKey:@"authority"]intValue] == 1) {
                [self.navigationController pushViewController:modifyArea animated:YES];
            }else{
                [self AlertView:LocalizedString(@"t_no_authority") type:0];
            }
            break;
        case 2:
            //修改阈值
            if ([[_Dic1 objectForKey:@"authority"]intValue] == 1) {
                [defaults setObject:@"1" forKey:@"authority"];
            }else{
                [defaults setObject:@"0" forKey:@"authority"];
            }
            [self.navigationController pushViewController:modifyThread animated:YES];
            
            break;
        case 3:
            //修改设备上传时间
            
            if ([[_Dic1 objectForKey:@"authority"]intValue] == 1) {
                [self selectDevGapSet];
            }else{
                [self AlertView:LocalizedString(@"t_no_authority") type:0];
            }
            
            break;
        case 4:
            //修改设备报警方式
            
            if ([[_Dic1 objectForKey:@"authority"]intValue] == 1) {
                MSMAlarmViewController* MSM = [[MSMAlarmViewController alloc]init];
                [self.navigationController pushViewController:MSM animated:YES];
            }else{
                [self AlertView:LocalizedString(@"t_no_authority") type:0];
            }
            
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//Cell点击后恢复未点击状态
}
- (void) AlertView:(NSString*)string type:(int)type{
    UIAlertController * Tips = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:Tips animated:YES completion:nil];
    if (type == 1){
        TipsTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(SuccessHandle) userInfo:nil repeats:NO];
    }else{
        TipsTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(FailHandle) userInfo:nil repeats:NO];
    }
}
- (void)SuccessHandle{
    [TipsTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)FailHandle{
    [TipsTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) selectDevGapSet{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:LocalizedString(@"t_gap")];
    ScottAlertAction *action1 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"10%@",LocalizedString(@"l_second")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        devGap = @"10";
        [self ModifyDevGap];
    }];
    [alertView addAction:action1];
    
    ScottAlertAction *action2 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"30%@",LocalizedString(@"l_second")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        devGap = @"30";
        [self ModifyDevGap];
    }];
    [alertView addAction:action2];
    
    ScottAlertAction *action3 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"40%@",LocalizedString(@"l_second")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        devGap = @"40";
        [self ModifyDevGap];
    }];
    [alertView addAction:action3];
    
    ScottAlertAction *action4 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"1%@",LocalizedString(@"l_minute")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        devGap = @"60";
        [self ModifyDevGap];
    }];
    [alertView addAction:action4];
    ScottAlertAction *action5 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"2%@",LocalizedString(@"l_minute")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        devGap = @"120";
        [self ModifyDevGap];
    }];
    [alertView addAction:action5];
    ScottAlertAction *action6 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"5%@",LocalizedString(@"l_minute")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        devGap = @"300";
        [self ModifyDevGap];
    }];
    [alertView addAction:action6];
    
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];

}

- (void)ModifyDevGap{
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"],@"snaddr": [defaults objectForKey:@"snaddr"],@"devGap":devGap};
    [manager.requestSerializer setValue:@"modifyDeviceGap" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"请求成功JSON:%@", JSON);
        if ([[JSON objectForKey:@"code"] intValue] == 0) {
            [self AlertView:LocalizedString(@"l_modifysuccess") type:0];
            [self getDevinfo];
            
        }else{
            [self AlertView:LocalizedString(@"l_modifyfailed") type:0];
        }
        //        timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(RequestDevDate) userInfo:nil repeats:YES];
        //        [timer fire];
        [ItemTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
    }];
}

@end
