//
//  DeviceSecondStageMenuController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/2.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "DeviceSecondStageMenuController.h"
#import "DeviceSetController.h"
#import "HistoryTimePickViewController.h"
#import "AuthorityViewController.h"
#import "HistoryCheck.h"
#import "AFNetworking.h"
#import "Language.h"

@interface DeviceSecondStageMenuController (){
    NSUserDefaults* defaults;
    UILabel*temp;
    UILabel*humi;
    UILabel*status;
    UILabel* updateTime;
    NSString* msg1;
    NSString* msg2;
//    NSTimer* timer2;//动画定时器
    NSTimer* getTheRealData;
    NSTimer* getDevInfo;
    AFHTTPSessionManager *manager;
    NSDictionary* DataDic;
    UIButton* historyDataButton;
    UIButton* abnormalButton;
    UIButton* AlarmSoundSwitch;
    UIButton* deviceSettingButton;
    UIButton* authorityManagerButton;
    UILabel* History;
    UILabel* HistoryErr;
    UILabel* setIn;
    UILabel* AuthManager;
    UILabel* IN1;
    UILabel* IN2;
    UILabel* IN3;
    UILabel* IN4;
    UILabel* label1;
    UILabel* label2;
    UILabel* label3;
    UILabel* label4;
}

@end

@implementation DeviceSecondStageMenuController{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //背景色设备白色
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.colors = @[(id)[[[UIColor colorWithRed:85.0/255.0 green:158/255.0 blue:198/255.0 alpha:1] colorWithAlphaComponent:1] CGColor], (id)[[[UIColor colorWithRed:80/255.0 green:120.0/255.0 blue:200.0/255.0 alpha:1] colorWithAlphaComponent:1] CGColor]];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self.view.layer addSublayer:gradientLayer];

    //界面title
    defaults = [NSUserDefaults standardUserDefaults];
    UIView* title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 44)];
    UILabel* titlesub1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 22)];
    titlesub1.textAlignment = NSTextAlignmentCenter;
    titlesub1.textColor = [UIColor whiteColor];
    UILabel* titlesub2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 22, 150, 22)];
    [title addSubview:titlesub1];
    titlesub1.text = [defaults objectForKey:@"deviceName"];//设备名
    [title addSubview:titlesub2];
    titlesub2.textAlignment = NSTextAlignmentCenter;
    titlesub2.textColor = [UIColor whiteColor];
    titlesub2.text = [defaults objectForKey:@"snaddr"];//snaddr
    self.navigationItem.titleView = title;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //网络服务参数设置
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
//--------温度布局图--------
    temp = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/8, self.view.frame.size.width/2, 60)];
    temp.textAlignment = NSTextAlignmentCenter;
    temp.textColor = [UIColor whiteColor];
    temp.backgroundColor = [UIColor clearColor];
    
    temp.font = [UIFont fontWithName:@"Arial" size:50];
    temp.layer.borderColor = [UIColor clearColor].CGColor;
    temp.layer.borderWidth = 1;
    [self.view addSubview:temp];
    temp.text = @"--.--";
    UILabel* tempUnit = [[UILabel alloc]initWithFrame:CGRectMake(0,temp.frame.origin.y + temp.frame.size.height, [UIScreen mainScreen].bounds.size.width/2, 30)];
    [self.view addSubview:tempUnit];
    tempUnit.textAlignment = NSTextAlignmentCenter;
    tempUnit.font = [UIFont fontWithName:@"Arial" size:18];
    tempUnit.textColor = [UIColor whiteColor];
    tempUnit.text = [NSString stringWithFormat:@"%@(℃)",LocalizedString(@"temperature")];
    
//----湿度布局------------
    humi = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, temp.frame.origin.y, self.view.frame.size.width/2, temp.frame.size.height)];
    humi.textAlignment = NSTextAlignmentCenter;
    humi.textColor = [UIColor whiteColor];
    humi.backgroundColor = [UIColor clearColor];
    humi.font = [UIFont fontWithName:@"Arial" size:50];
    
    humi.layer.borderColor = [UIColor clearColor].CGColor;
    humi.layer.borderWidth = 1;
    [self.view addSubview:humi];
    humi.text = @"--.--";
    UILabel* humiUnit = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/2,temp.frame.origin.y + temp.frame.size.height, WIDTH/2, 30)];
    [self.view addSubview:humiUnit];
    humiUnit.textAlignment = NSTextAlignmentCenter;
    humiUnit.textColor = [UIColor whiteColor];
    humiUnit.font = [UIFont fontWithName:@"Arial" size:18];
    humiUnit.text = [NSString stringWithFormat:@"%@(%%RH)",LocalizedString(@"humidity")];

    UIImageView* LineView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2,temp.frame.origin.y, 1, temp.frame.size.height*1.5)];
    LineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:LineView];
    
    AlarmSoundSwitch = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, HEIGHT/8 - 50,50,50)];
    [AlarmSoundSwitch setImage:[UIImage imageNamed:@"sound1"] forState:UIControlStateNormal];
    [self.view addSubview:AlarmSoundSwitch];
    [AlarmSoundSwitch addTarget:self action:@selector(SoundSwitch) forControlEvents:UIControlEventTouchUpInside];


    [self IN1];
    [self IN2];
    [self IN3];
    [self IN4];
//----------设备状态------------------
    status = [[UILabel alloc]initWithFrame:CGRectMake(5,HEIGHT/3.5,self.view.frame.size.width - 10,60)];
    status.numberOfLines = 3;
    status.textColor = [UIColor whiteColor];
    status.backgroundColor = [UIColor clearColor];
    status.font = [UIFont fontWithName:@"Arial" size:20];

    status.layer.borderColor = [UIColor clearColor].CGColor;
    status.layer.borderWidth = 1;
    status.numberOfLines =2;
    status.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:status];
    updateTime = [[UILabel alloc]initWithFrame:CGRectMake(5, HEIGHT/3.5 + 120, WIDTH - 10, 30)];
    updateTime.textColor = [UIColor whiteColor];
    updateTime.font = [UIFont fontWithName:@"Arial" size:18];
    updateTime.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:updateTime];
    
    historyDataButton = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH/16, HEIGHT/3.5 + 200, WIDTH/8,  WIDTH/8)];
    historyDataButton.layer.cornerRadius = 100;
    [historyDataButton setImage:[UIImage imageNamed:@"main1sub_history.png"] forState:UIControlStateNormal];
    historyDataButton.backgroundColor = [UIColor clearColor];
    [historyDataButton addTarget:self action:@selector(historyData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:historyDataButton];
    History = [[UILabel alloc]initWithFrame:CGRectMake(historyDataButton.frame.origin.x, historyDataButton.frame.origin.y + historyDataButton.frame.size.height + 1, historyDataButton.frame.size.width, 20)];
    History.textAlignment = NSTextAlignmentCenter;
    History.font = [UIFont fontWithName:@"Arial" size:10];
    History.textColor = [UIColor whiteColor];
    History.text = LocalizedString(@"l_history_data");
    [self.view addSubview:History];
    
    abnormalButton = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH/16*5, HEIGHT/3.5 + 200, WIDTH/8,  WIDTH/8)];
    abnormalButton.layer.cornerRadius = 100;
    [abnormalButton setImage:[UIImage imageNamed:@"main1sub_historyErr.png"] forState:UIControlStateNormal];
    abnormalButton.backgroundColor = [UIColor clearColor];
    [abnormalButton addTarget:self action:@selector(checkAbnormal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:abnormalButton];
    HistoryErr = [[UILabel alloc]initWithFrame:CGRectMake(abnormalButton.frame.origin.x, abnormalButton.frame.origin.y + abnormalButton.frame.size.height + 1, abnormalButton.frame.size.width, 20)];
    HistoryErr.textAlignment = NSTextAlignmentCenter;
    HistoryErr.font = [UIFont fontWithName:@"Arial" size:10];
    HistoryErr.textColor = [UIColor whiteColor];
    HistoryErr.text = LocalizedString(@"l_alarm_record");
    [self.view addSubview:HistoryErr];

    deviceSettingButton = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH/16*9,HEIGHT/3.5 + 200, WIDTH/8, WIDTH/8)];
    deviceSettingButton.layer.cornerRadius = 100;
    [deviceSettingButton setImage:[UIImage imageNamed:@"main1sub_set.png"] forState:UIControlStateNormal];
    deviceSettingButton.backgroundColor = [UIColor clearColor];
    [deviceSettingButton addTarget:self action:@selector(deviceSetting) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deviceSettingButton];
    setIn = [[UILabel alloc]initWithFrame:CGRectMake(deviceSettingButton.frame.origin.x, deviceSettingButton.frame.origin.y + deviceSettingButton.frame.size.height + 1, deviceSettingButton.frame.size.width, 20)];
    setIn.textAlignment = NSTextAlignmentCenter;
    setIn.font = [UIFont fontWithName:@"Arial" size:10];
    setIn.textColor = [UIColor whiteColor];
    setIn.text = LocalizedString(@"l_setting");
    [self.view addSubview:setIn];

    
    authorityManagerButton = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH/16*13, HEIGHT/3.5 + 200, WIDTH/8, WIDTH/8)];
    
    authorityManagerButton.layer.cornerRadius = 100;
    [authorityManagerButton setImage:[UIImage imageNamed:@"main1_authority.png"] forState:UIControlStateNormal];
    authorityManagerButton.backgroundColor = [UIColor clearColor];
    [authorityManagerButton addTarget:self action:@selector(authorityHandle) forControlEvents:UIControlEventTouchUpInside];

    
    [self.view addSubview:authorityManagerButton];

    AuthManager = [[UILabel alloc]initWithFrame:CGRectMake(authorityManagerButton.frame.origin.x, authorityManagerButton.frame.origin.y + authorityManagerButton.frame.size.height + 1, authorityManagerButton.frame.size.width, 20)];
    AuthManager.textAlignment = NSTextAlignmentCenter;
    AuthManager.font = [UIFont fontWithName:@"Arial" size:10];
    AuthManager.textColor = [UIColor whiteColor];
    AuthManager.text = LocalizedString(@"l_authority");
    [self.view addSubview:AuthManager];

    // Do any additional setup after loading the view.
    
}


- (void)viewWillAppear:(BOOL)animated{
    defaults = [NSUserDefaults standardUserDefaults];
    getTheRealData = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(GetData) userInfo:nil repeats:YES];
    [getTheRealData fire];
    
    getDevInfo = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(GetDevInfo) userInfo:nil repeats:YES];
    [getDevInfo fire];
//    timer2 = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(BarChartanimation) userInfo:nil repeats:YES];
//
//    [timer2 fire];

}

- (UILabel*)IN1{
    if (!IN1) {
        label1 = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/4 - 60, HEIGHT/3.5, 50, 50)];
        label1.textColor = [UIColor whiteColor];
        label1.text = @"停电:";
        [self.view addSubview:label1];
        IN1 = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/4 - 10, HEIGHT/3.5, 120, 50)];
        IN1.font = [UIFont fontWithName:@"Arial" size:18];
        IN1.textColor = [UIColor whiteColor];
        IN1.textAlignment = NSTextAlignmentLeft;
        IN1.text = @"停电:";
        [self.view addSubview:IN1];
    }
    return IN1;
}
- (UILabel*)IN2{
    if (!IN2) {
        label2 = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/4*3 - 60, HEIGHT/3.5, 50, 50)];
        label2.textColor = [UIColor whiteColor];
        label2.text = @"水浸:";
        [self.view addSubview:label2];
        IN2 = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/4*3 - 10, HEIGHT/3.5, 120, 50)];
        IN2.font = [UIFont fontWithName:@"Arial" size:18];
        IN2.textColor = [UIColor whiteColor];
        IN2.textAlignment = NSTextAlignmentLeft;
        IN2.text = @"水浸:";
        [self.view addSubview:IN2];
    }
    return IN2;
}
- (UILabel*)IN3{
    if (!IN3) {
        label3 = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/4 - 60, HEIGHT/3.5 + 50, 50, 50)];
        label3.textColor = [UIColor whiteColor];
        label3.text = @"烟雾:";
        [self.view addSubview:label3];
        IN3 = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/4 - 10, HEIGHT/3.5 + 50, 120, 50)];
        IN3.font = [UIFont fontWithName:@"Arial" size:18];
        IN3.textColor = [UIColor whiteColor];
        IN3.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:IN3];
    }
    return IN3;
}

- (UILabel*)IN4{
    if (!IN4) {
        label4 = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/4*3 - 60, HEIGHT/3.5 + 50, 50, 50)];
        label4.textColor = [UIColor whiteColor];
        label4.text = @"门磁:";
        [self.view addSubview:label4];
        IN4 = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/4*3 - 10, HEIGHT/3.5 + 50, 120, 50)];
        IN4.font = [UIFont fontWithName:@"Arial" size:18];
        IN4.textColor = [UIColor whiteColor];
        IN4.textAlignment = NSTextAlignmentLeft;
        IN4.text = @"门磁:";
        [self.view addSubview:IN4];
    }
    return IN4;
}

//获取设备信息
- (void)GetDevInfo{
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"],@"snaddr":[defaults objectForKey:@"snaddr"]};
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    [manager POST:cqtek_api parameters:params headers:@{@"type":@"getDevInfo"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([[JSON objectForKey:@"code"]intValue] == 0) {
            [defaults setObject:[JSON objectForKey:@"beepStatus"] forKey:@"beepStatus"];
            [defaults setObject:[JSON objectForKey:@"authority"] forKey:@"cqAuthority"];
            if ([[JSON objectForKey:@"beepStatus"] isEqualToString:@"1"]) {
                [AlarmSoundSwitch setImage:[UIImage imageNamed:@"sound1"] forState:UIControlStateNormal];
            }else{
                [AlarmSoundSwitch setImage:[UIImage imageNamed:@"sound2"] forState:UIControlStateNormal];
            }
        }else{
            //code不等于0
        }
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"请求失败:%@", error.description);
              
          }
     ];
}

//获取数据
- (void)GetData{
    NSDictionary *params = @{@"snaddr":[defaults objectForKey:@"snaddr"],@"curve":@"allLast"};
    manager.securityPolicy.allowInvalidCertificates = NO;

    [manager POST:cqtek_api parameters:params headers:@{@"type":@"getRTData"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([[JSON objectForKey:@"code"]intValue] == 0) {
            if ([[[JSON objectForKey:@"array"] allKeys] containsObject:@"pow"] & [[[JSON objectForKey:@"array"] allKeys] containsObject:@"water"] & [[[JSON objectForKey:@"array"] allKeys] containsObject:@"smoke"] & [[[JSON objectForKey:@"array"] allKeys] containsObject:@"door"]) {
                if ([[[JSON objectForKey:@"array"] objectForKey:@"pow"] isEqualToString:@"F"]){
                    IN1.text = @"未接入";
                    IN1.textColor = [UIColor lightGrayColor];
                }else if ([[[JSON objectForKey:@"array"] objectForKey:@"pow"] isEqualToString:@"0"]){
                    IN1.text = @"正常";
                    IN1.textColor = [UIColor whiteColor];
                }else if ([[[JSON objectForKey:@"array"] objectForKey:@"pow"] isEqualToString:@"1"]){
                    IN1.text = @"报警";
                    IN1.textColor = [UIColor colorWithRed:216/255.0 green:67/255.0 blue:74/255.0 alpha:0.8];
                }
                if ([[[JSON objectForKey:@"array"] objectForKey:@"water"] isEqualToString:@"F"]){
                    IN2.text = @"未接入";
                    IN2.textColor = [UIColor lightGrayColor];
                }else if ([[[JSON objectForKey:@"array"] objectForKey:@"water"] isEqualToString:@"0"]){
                    IN2.text = @"正常";
                    IN2.textColor = [UIColor whiteColor];
                }else if ([[[JSON objectForKey:@"array"] objectForKey:@"water"] isEqualToString:@"1"]){
                    IN2.text = @"报警";
                    IN2.textColor = [UIColor colorWithRed:216/255.0 green:67/255.0 blue:74/255.0 alpha:1];
                }
                if ([[[JSON objectForKey:@"array"] objectForKey:@"smoke"] isEqualToString:@"F"]){
                    IN3.text = @"未接入";
                    IN3.textColor = [UIColor lightGrayColor];
                }else if ([[[JSON objectForKey:@"array"] objectForKey:@"smoke"] isEqualToString:@"0"]){
                    IN3.text = @"正常";
                    IN3.textColor = [UIColor whiteColor];
                }else if ([[[JSON objectForKey:@"array"] objectForKey:@"smoke"] isEqualToString:@"1"]){
                    IN3.text = @"报警";
                    IN3.textColor = [UIColor colorWithRed:216/255.0 green:67/255.0 blue:74/255.0 alpha:1];
                }
                if ([[[JSON objectForKey:@"array"] objectForKey:@"door"] isEqualToString:@"F"]){
                    IN4.text = @"未接入";
                    IN4.textColor = [UIColor lightGrayColor];
                }else if ([[[JSON objectForKey:@"array"] objectForKey:@"door"] isEqualToString:@"0"]){
                    IN4.text = @"正常";
                    IN4.textColor = [UIColor whiteColor];
                }else if ([[[JSON objectForKey:@"array"] objectForKey:@"door"] isEqualToString:@"1"]){
                    IN4.text = @"报警";
                    IN4.textColor = [UIColor colorWithRed:216/255.0 green:67/255.0 blue:74/255.0 alpha:1];
                }
            }else{
                IN4.textColor = [UIColor whiteColor];
                IN3.textColor = [UIColor whiteColor];
                IN2.textColor = [UIColor whiteColor];
                IN1.textColor = [UIColor whiteColor];
                IN1.text = @"-";
                IN2.text = @"-";
                IN3.text = @"-";
                IN4.text = @"-";
            }
            if([[[JSON objectForKey:@"array"] objectForKey:@"abnormal"] isEqualToString:@"3"]){
                status.text = @"传感器未连接";
                temp.text = [NSString stringWithFormat:@"--.--"];
                humi.text = [NSString stringWithFormat:@"--.--"];
                [updateTime setFrame:CGRectMake(5, HEIGHT/3.5 +50, WIDTH - 10, 30)];
                //updateTime.text = [NSString stringWithFormat:@"最后上传时间:%@",[JSON objectForKey:@"time"]];
                [IN1 setHidden:YES];
                [IN2 setHidden:YES];
                [IN3 setHidden:YES];
                [IN4 setHidden:YES];
                [label1 setHidden:YES];
                [label2 setHidden:YES];
                [label3 setHidden:YES];
                [label4 setHidden:YES];
            }else if([[[JSON objectForKey:@"array"] objectForKey:@"abnormal"] isEqualToString:@"1"]){
                temp.text = [NSString stringWithFormat:@"%@",[[[JSON objectForKey:@"array"] objectForKey:@"temp"] objectForKey:@"value"]];
                humi.text = [NSString stringWithFormat:@"%@",[[[JSON objectForKey:@"array"] objectForKey:@"humi"] objectForKey:@"value"]];
                updateTime.text = [NSString stringWithFormat:@"最后上传时间:%@",[[JSON objectForKey:@"array"] objectForKey:@"time"]];
                status.text = @"设备离线";
                status.textColor = [UIColor darkGrayColor];
                [updateTime setFrame:CGRectMake(5, HEIGHT/3.5 +50, WIDTH - 10, 30)];
                [IN1 setHidden:YES];
                [IN2 setHidden:YES];
                [IN3 setHidden:YES];
                [IN4 setHidden:YES];
                [label1 setHidden:YES];
                [label2 setHidden:YES];
                [label3 setHidden:YES];
                [label4 setHidden:YES];
            }
            else{
                //实时温湿度数据
                temp.text = [NSString stringWithFormat:@"%@",[[[JSON objectForKey:@"array"] objectForKey:@"temp"] objectForKey:@"value"]];
                humi.text = [NSString stringWithFormat:@"%@",[[[JSON objectForKey:@"array"] objectForKey:@"humi"] objectForKey:@"value"]];
                
                int strhumi = [[[[JSON objectForKey:@"array"] objectForKey:@"humi"] objectForKey:@"status"]intValue];
                switch (strhumi) {
                    case 0:
                        //湿度正常
                        msg1 = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"humidity"),LocalizedString(@"normal")];

                        humi.textColor = [UIColor whiteColor];
                        break;
                    case 1:
                        //湿度高于阈值
                        msg1 = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"humidity"),LocalizedString(@"exceed")];

                        humi.textColor = [UIColor colorWithRed:216/255.0 green:67/255.0 blue:74/255.0 alpha:0.8];
                        break;
                    case -1:
                        //湿度低于阈值
                        msg1 = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"humidity"),LocalizedString(@"lower")];

                        humi.textColor = [UIColor colorWithRed:12/255.0 green:58/255.0 blue:143/255.0 alpha:0.8];
                        break;
                        
                    default:
                        break;
                }
                int strtemp = [[[[JSON objectForKey:@"array"] objectForKey:@"temp"] objectForKey:@"status"]intValue];
                switch (strtemp) {
                    case 0:
                        //温度正常
                        msg2 = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"temperature"),LocalizedString(@"normal")];
                        temp.textColor = [UIColor whiteColor];
                        break;
                    case 1:
                        //温度高于阈值
                        msg2 = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"temperature"),LocalizedString(@"exceed")];
                        temp.textColor = [UIColor colorWithRed:216/255.0 green:67/255.0 blue:74/255.0 alpha:0.8];
                        break;
                    case -1:
                        //温度低于阈值
                        msg2 = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"temperature"),LocalizedString(@"lower")];
                        temp.textColor = [UIColor colorWithRed:12/255.0 green:58/255.0 blue:143/255.0 alpha:0.8];
                        break;
                        
                    default:
                        break;
                }
                status.text = @"";
                [label1 setHidden:false];
                [label2 setHidden:false];
                [label3 setHidden:false];
                [label4 setHidden:false];
                [updateTime setFrame:CGRectMake(5, HEIGHT/3.5 + 120, WIDTH - 10, 30)];
                updateTime.text = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"l_last_date"),[[JSON objectForKey:@"array"] objectForKey:@"time"]];
                msg2 = @"";
                msg1 = @"";
            }
            
        }else{
        //code不等于0
        }
    }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);

     }
    ];
}



- (void)SoundSwitch{
    if ([[defaults objectForKey:@"beepStatus"] isEqualToString:@"0"]) {
        [self SoundOpen];
    }else{
        [self SoundClose];
    }
}

//打开蜂鸣器
- (void)SoundOpen{
    NSDictionary *params = @{@"snaddr":[defaults objectForKey:@"snaddr"],@"beepStatus":@"1"};
    manager.securityPolicy.allowInvalidCertificates = NO;
    [manager POST:cqtek_api parameters:params headers:@{@"type":@"setRealAlarm"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([[JSON objectForKey:@"code"]intValue] == 0) {
            [defaults setObject:@"1" forKey:@"beepStatus"];
            if ([[JSON objectForKey:@"msg"] isEqualToString:@"蜂鸣器关闭"]) {
                [AlarmSoundSwitch setImage:[UIImage imageNamed:@"sound2"] forState:UIControlStateNormal];
            }
            else{
                [AlarmSoundSwitch setImage:[UIImage imageNamed:@"sound1"] forState:UIControlStateNormal];
            }
        }else{
            //code不等于0
        }
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"请求失败:%@", error.description);
              
          }
     ];

}
//关闭蜂鸣器
- (void)SoundClose{
    NSDictionary *params = @{@"snaddr":[defaults objectForKey:@"snaddr"],@"beepStatus":@"0"};
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    [manager POST:cqtek_api parameters:params headers:@{@"type":@"setRealAlarm"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([[JSON objectForKey:@"code"]intValue] == 0) {
            [defaults setObject:@"0" forKey:@"beepStatus"];
            if ([[JSON objectForKey:@"msg"] isEqualToString:@"蜂鸣器关闭"]) {
                [AlarmSoundSwitch setImage:[UIImage imageNamed:@"sound2"] forState:UIControlStateNormal];
            }
            else{
                [AlarmSoundSwitch setImage:[UIImage imageNamed:@"sound1"] forState:UIControlStateNormal];
            }

        }else{
            //code不等于0
        }
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"请求失败:%@", error.description);
              
          }
     ];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [getTheRealData invalidate];
    [getDevInfo invalidate];
//    [timer2 invalidate];
}
- (void)historyData{
//    [timer2 invalidate];
    HistoryTimePickViewController* historyDataPick = [[HistoryTimePickViewController alloc]init];
    [self.navigationController pushViewController:historyDataPick animated:YES];
}
- (void)checkHistory{
//    [timer2 invalidate];
    HistoryCheck* history = [[HistoryCheck alloc]init];
    [self.navigationController pushViewController:history animated:YES];
}
- (void)checkAbnormal{
//    [timer2 invalidate];
    HistoryCheck* history = [[HistoryCheck alloc]init];
    [self.navigationController pushViewController:history animated:YES];
}


- (void)deviceSetting{
    DeviceSetController* deviceSet = [[DeviceSetController alloc]init];
    [self.navigationController pushViewController:deviceSet animated:YES];
}
- (void)authorityHandle{
    AuthorityViewController* authority = [[AuthorityViewController alloc]init];
    [self.navigationController pushViewController:authority animated:YES];
}
- (void)goBackView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)BarChartanimation{
    [self.Shaper removeFromSuperlayer];
//    [historyDataButton removeFromSuperview];
//    [deviceSettingButton removeFromSuperview];
//    [abnormalButton removeFromSuperview];
//    [History removeFromSuperview];
//    [HistoryErr removeFromSuperview];
//    [setIn removeFromSuperview];

    _tt += M_PI * 0.01;
    if (_tt == M_PI * 3) {
        _tt = 0;
    }
    [self drawShaper:50.0f frame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/3*2, self.view.frame.size.width + 1,self.view.frame.size.height/3)];
}

//背景动画
- (void)drawShaper:(CGFloat)value frame:(CGRect)frame{
    
    self.Shaper = [CAShapeLayer layer];
    
    self.Shaper.strokeColor = [UIColor clearColor].CGColor;
    self.Shaper.lineWidth = 1.0f;
    self.Shaper.frame = frame;
    
    self.Shaper.fillColor = [UIColor colorWithRed:12/255.0 green:58/255.0 blue:143/255.0 alpha:0.8].CGColor;
    
    CGPoint zero = CGPointMake(0,self.Shaper.frame.size.height - value*5);
    UIBezierPath *wave = [UIBezierPath bezierPath];
    [wave moveToPoint:zero];
    
    for (int i = 0; i < self.Shaper.frame.size.width; i++) {
        CGPoint p =  relativeCoor2(zero, i, 15 * cos(M_PI /300 *i + _tt ) );
        [wave addLineToPoint:p];
    }
    
    [wave addLineToPoint:CGPointMake(0 + self.Shaper.frame.size.width, self.Shaper.frame.origin.y + self.Shaper.frame.size.height)];
    [wave addLineToPoint:CGPointMake(0, self.Shaper.frame.origin.y + self.Shaper.frame.size.height)];
    [wave addLineToPoint:zero];
    self.Shaper.path = wave.CGPath;
    
    [self.view.layer addSublayer:self.Shaper];
    [self.view addSubview:historyDataButton];
    [self.view addSubview:deviceSettingButton];
    [self.view addSubview:authorityManagerButton];
    [self.view addSubview:abnormalButton];
    [self.view addSubview:History];
    [self.view addSubview:HistoryErr];
    [self.view addSubview:setIn];
    [self.view addSubview:AuthManager];

}

CGPoint relativeCoor2(CGPoint point, CGFloat x ,CGFloat y){
    return CGPointMake(point.x + x, point.y + y);
}

@end
