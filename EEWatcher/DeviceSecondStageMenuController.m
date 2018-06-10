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
    NSTimer* timer2;//动画定时器
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
}

@end

@implementation DeviceSecondStageMenuController{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //背景色设备白色
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.colors = @[(id)[[[UIColor colorWithRed:85.0/255.0 green:158/255.0 blue:198/255.0 alpha:1] colorWithAlphaComponent:1] CGColor], (id)[[[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1] colorWithAlphaComponent:1] CGColor]];
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
    UILabel* humiUnit = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2,temp.frame.origin.y + temp.frame.size.height, [UIScreen mainScreen].bounds.size.width/2, 30)];
    [self.view addSubview:humiUnit];
    humiUnit.textAlignment = NSTextAlignmentCenter;
    humiUnit.textColor = [UIColor whiteColor];
    humiUnit.font = [UIFont fontWithName:@"Arial" size:18];
    humiUnit.text = [NSString stringWithFormat:@"%@(%%RH)",LocalizedString(@"humidity")];

    UIImageView* LineView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2,temp.frame.origin.y, 1, temp.frame.size.height*1.5)];
    LineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:LineView];
    
    AlarmSoundSwitch = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, [UIScreen mainScreen].bounds.size.height/8 - 50,50,50)];
    [AlarmSoundSwitch setImage:[UIImage imageNamed:@"sound1"] forState:UIControlStateNormal];
    [self.view addSubview:AlarmSoundSwitch];
    [AlarmSoundSwitch addTarget:self action:@selector(SoundSwitch) forControlEvents:UIControlEventTouchUpInside];

//----------设备状态------------------
    status = [[UILabel alloc]initWithFrame:CGRectMake(5,[UIScreen mainScreen].bounds.size.height/3,self.view.frame.size.width - 10,60)];
    status.numberOfLines = 3;
    status.textColor = [UIColor whiteColor];
    status.backgroundColor = [UIColor clearColor];
    status.font = [UIFont fontWithName:@"Arial" size:20];

    status.layer.borderColor = [UIColor clearColor].CGColor;
    status.layer.borderWidth = 1;
    status.numberOfLines =2;
    status.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:status];
    updateTime = [[UILabel alloc]initWithFrame:CGRectMake(5, status.frame.origin.y + status.frame.size.height, status.frame.size.width, 30)];
    updateTime.textColor = [UIColor whiteColor];
    updateTime.font = [UIFont fontWithName:@"Arial" size:18];
    updateTime.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:updateTime];
    
    historyDataButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/16, [UIScreen mainScreen].bounds.size.height/3*2, [UIScreen mainScreen].bounds.size.width/8,  [UIScreen mainScreen].bounds.size.width/8)];
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
    
    abnormalButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/16*5, [UIScreen mainScreen].bounds.size.height/3*2, [UIScreen mainScreen].bounds.size.width/8,  [UIScreen mainScreen].bounds.size.width/8)];
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

    deviceSettingButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/16*9, [UIScreen mainScreen].bounds.size.height/3*2, [UIScreen mainScreen].bounds.size.width/8,  [UIScreen mainScreen].bounds.size.width/8)];
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

    
    authorityManagerButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/16*13, deviceSettingButton.frame.origin.y, deviceSettingButton.frame.size.width, deviceSettingButton.frame.size.width)];
    
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
    timer2 = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(BarChartanimation) userInfo:nil repeats:YES];
    
    [timer2 fire];

}

//获取设备信息
- (void)GetDevInfo{
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"],@"snaddr":[defaults objectForKey:@"snaddr"]};
    manager.securityPolicy.allowInvalidCertificates = NO;
    [manager.requestSerializer setValue:@"getDevInfo" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
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
    [manager.requestSerializer setValue:@"getRTData" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([[JSON objectForKey:@"code"]intValue] == 0) {
            if([[[JSON objectForKey:@"array"] objectForKey:@"abnormal"] isEqualToString:@"3"]){
                status.text = @"传感器未连接";
                temp.text = [NSString stringWithFormat:@"--.--"];
                humi.text = [NSString stringWithFormat:@"--.--"];
                //updateTime.text = [NSString stringWithFormat:@"最后上传时间:%@",[JSON objectForKey:@"time"]];
                
                
            }else if([[[JSON objectForKey:@"array"] objectForKey:@"abnormal"] isEqualToString:@"1"]){
                temp.text = [NSString stringWithFormat:@"%@",[[[JSON objectForKey:@"array"] objectForKey:@"temp"] objectForKey:@"value"]];
                humi.text = [NSString stringWithFormat:@"%@",[[[JSON objectForKey:@"array"] objectForKey:@"humi"] objectForKey:@"value"]];
                updateTime.text = [NSString stringWithFormat:@"最后上传时间:%@",[[JSON objectForKey:@"array"] objectForKey:@"time"]];
                status.text = @"设备离线";
                status.textColor = [UIColor darkGrayColor];
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
                status.text = [NSString stringWithFormat:@"%@,%@",msg2,msg1];
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
    [manager.requestSerializer setValue:@"setRealAlarm" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
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
    [manager.requestSerializer setValue:@"setRealAlarm" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
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
    [timer2 invalidate];
}
- (void)historyData{
    [timer2 invalidate];
    HistoryTimePickViewController* historyDataPick = [[HistoryTimePickViewController alloc]init];
    [self.navigationController pushViewController:historyDataPick animated:YES];
}
- (void)checkHistory{
    [timer2 invalidate];
    HistoryCheck* history = [[HistoryCheck alloc]init];
    [self.navigationController pushViewController:history animated:YES];
}
- (void)checkAbnormal{
    [timer2 invalidate];
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
