//
//  AddDevViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/11/29.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "AddDevViewController.h"

#import <SystemConfiguration/CaptiveNetwork.h>
#import "HFSmartLink.h"
#import <CoreLocation/CoreLocation.h>
#import "HFSmartLinkDeviceInfo.h"
#import "AFNetworking.h"
#import "NewDeviceListView.h"
#import "FYCountDownView.h"
#import "ScottAlertController.h"
#import "Reachability.h"
#import "Request.h"
#import "Language.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface AddDevViewController ()<CLLocationManagerDelegate>{
//    NSString* ssid;
    HFSmartLink * smtlk;
     BOOL isconnecting;
    UIButton* EasyConfigBtn;
    AFHTTPSessionManager *manager;//网络请求管理
    UIView* maskView;
    NSUserDefaults* defaults;
    NSMutableArray* macArray;
    UISwitch* singleSwitch;
    NSInteger count;
    NSTimer* timer;
    UIButton* questionForSSID;
    UIButton* questionForPass;
    NSString *wifiId;
}
//@property (strong, nonatomic) ASProgressPopUpView *progressView;
@property (strong, nonatomic)FYCountDownView * countDownView;
@property (strong, nonatomic) CLLocationManager *cllocation;
@end

@implementation AddDevViewController
singleton_m(InstanceThree);
- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    isconnecting = false;
    smtlk = [HFSmartLink shareInstence];
    //单个配置开关
    smtlk.isConfigOneDevice = YES;
    smtlk.waitTimers = 30;
    self.cllocation = [[CLLocationManager alloc] init];
    self.cllocation.delegate = self;
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.colors = @[(id)[[[UIColor colorWithRed:59/255.0 green:113/255.0 blue:167/255.0 alpha:1] colorWithAlphaComponent:1] CGColor], (id)[[[UIColor colorWithRed:44/255.0 green:115/255.0 blue:140/255.0 alpha:1] colorWithAlphaComponent:1] CGColor]];
    gradientLayer.startPoint = CGPointMake(0, 0);
    
    gradientLayer.endPoint = CGPointMake(0, 1);
    
    gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    [self.view.layer addSublayer:gradientLayer];

    self.navigationItem.title = LocalizedString(@"l_Adddevice");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    
    UIView* SSIDview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80)];
    SSIDview.backgroundColor = [UIColor clearColor];
    SSIDview.layer.cornerRadius = 3;
    [self.view addSubview:SSIDview];
    
    questionForSSID = [[UIButton alloc]initWithFrame:CGRectMake(SSIDview.frame.size.width - 30, SSIDview.frame.size.height/2 - 10, 20, 20)];
    [questionForSSID setImage:[UIImage imageNamed:@"question"] forState:UIControlStateNormal];
    [questionForSSID addTarget:self action:@selector(TipsHandle:) forControlEvents:UIControlEventTouchUpInside];
    [SSIDview addSubview:questionForSSID];

    UILabel* SSIDLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 20, 90, 40)];
    SSIDLabel.textAlignment = NSTextAlignmentCenter;
    SSIDLabel.text = LocalizedString(@"l_ssid");
    SSIDLabel.font = [UIFont fontWithName:@"Arial" size:18];
    SSIDLabel.textColor =[UIColor whiteColor];
    
//    UILabel* SSIDTips = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, [UIScreen mainScreen].bounds.size.width - 20, 30)];
//    SSIDTips.textAlignment = NSTextAlignmentRight;
//    SSIDTips.text = @"该网络为手机当前的网络,设备也将被绑定到此网络下";
//    SSIDTips.font = [UIFont fontWithName:@"Arial" size:15];
//    SSIDTips.textColor =[UIColor whiteColor];
//    [SSIDview addSubview:SSIDTips];
    
    _SSIDText = [[UITextField alloc]initWithFrame:CGRectMake(SSIDLabel.frame.origin.x + SSIDLabel.frame.size.width, SSIDLabel.frame.origin.y, SSIDview.frame.size.width - SSIDLabel.frame.origin.x - SSIDLabel.frame.size.width - 40, 40)];
    _SSIDText.borderStyle = UITextBorderStyleNone;
    _SSIDText.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    _SSIDText.textColor = [UIColor blackColor];
    _SSIDText.placeholder = LocalizedString(@"t_not_network_connect");
    _SSIDText.font = [UIFont fontWithName:@"Arial" size:18];
    _SSIDText.layer.cornerRadius = 3;
    _SSIDText.delegate = self;
    UIImageView* lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 81, [UIScreen mainScreen].bounds.size.width, 1)];
    lineImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineImageView];

    [SSIDview addSubview:SSIDLabel];
    [SSIDview addSubview:_SSIDText];
    
    UIView* PASSview = [[UIView alloc]initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 80)];
    PASSview.backgroundColor = [UIColor clearColor];
    PASSview.layer.cornerRadius = 3;
    [self.view addSubview:PASSview];
    questionForPass = [[UIButton alloc]initWithFrame:CGRectMake(PASSview.frame.size.width - 30, PASSview.frame.size.height/2 - 10, 20, 20)];
    [questionForPass setImage:[UIImage imageNamed:@"question"] forState:UIControlStateNormal];
    [PASSview addSubview:questionForPass];
    [questionForPass addTarget:self action:@selector(TipsHandle:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* PassWordLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 20, 90, 40)];
    PassWordLabel.textAlignment = NSTextAlignmentCenter;
    PassWordLabel.text = LocalizedString(@"l_pass");
    PassWordLabel.font = [UIFont fontWithName:@"Arial" size:18];
    PassWordLabel.textColor =[UIColor whiteColor];
    
    UIImageView* line2ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 161, [UIScreen mainScreen].bounds.size.width, 1)];
    line2ImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line2ImageView];

    //初始化遮罩层
    [self maskViewInit];
    
    _PasswordText = [[UITextField alloc]initWithFrame:CGRectMake(_SSIDText.frame.origin.x, PassWordLabel.frame.origin.y, _SSIDText.frame.size.width, _SSIDText.frame.size.height)];
    _PasswordText.borderStyle = UITextBorderStyleNone;
    _PasswordText.backgroundColor = [UIColor whiteColor];
    _PasswordText.font = [UIFont fontWithName:@"Arial" size:20];
    _PasswordText.placeholder = LocalizedString(@"l_wifiplacehoder");
    _PasswordText.secureTextEntry = YES;
    _PasswordText.layer.cornerRadius = 3;
    _PasswordText.delegate = self;
    
//    UILabel* PASSTips = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, [UIScreen mainScreen].bounds.size.width - 40, 30)];
//    PASSTips.textAlignment = NSTextAlignmentRight;
//    PASSTips.text = @"设备将获取此密码进行绑定";
//    PASSTips.font = [UIFont fontWithName:@"Arial" size:15];
//    PASSTips.textColor =[UIColor whiteColor];
//    [PASSview addSubview:PASSTips];

    [PASSview addSubview:_PasswordText];
    [PASSview addSubview:PassWordLabel];
   
    
    UIView* Switchview = [[UIView alloc]initWithFrame:CGRectMake(0, 160, [UIScreen mainScreen].bounds.size.width, 80)];
    Switchview.backgroundColor = [UIColor clearColor];
    Switchview.layer.cornerRadius = 3;
    [self.view addSubview:Switchview];
    
    UILabel*SingleSwitchLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,20, 200, 40)];
    SingleSwitchLabel.textAlignment = NSTextAlignmentCenter;
    SingleSwitchLabel.font = [UIFont fontWithName:@"Arial" size:18];
    SingleSwitchLabel.text = LocalizedString(@"l_single_switch");
    SingleSwitchLabel.textColor =[UIColor whiteColor];
    [Switchview addSubview:SingleSwitchLabel];

    //单个配置开关
    singleSwitch = [[UISwitch alloc]init];
    [singleSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 40,SingleSwitchLabel.frame.origin.y + SingleSwitchLabel.frame.size.height/2)];
    [Switchview addSubview:singleSwitch];
    [singleSwitch addTarget:self action:@selector(singleSwitchState:) forControlEvents:UIControlEventValueChanged];

    
    UIImageView* line3ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 241, [UIScreen mainScreen].bounds.size.width, 1)];
    line3ImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line3ImageView];

    
    [self EasyConfigBtn];
}

- (void)TipsHandle:(id)sender{
    if (sender == questionForPass) {
        [self AlertMessage:LocalizedString(@"t_pass_is_correct")];
    }else if(sender == questionForSSID){
        [self AlertMessage:LocalizedString(@"t_ssid_tips")];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
//遮罩层实现函数
- (UIView*)maskViewInit{
    maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];

    return maskView;
}
- (void)viewWillAppear:(BOOL)animated{
    [_PasswordText resignFirstResponder];
    macArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.listArray = [[NSMutableArray alloc]initWithCapacity:0];
    count = 0;
    defaults = [NSUserDefaults standardUserDefaults];
    NSString* stateString = [defaults objectForKey:@"switchState"];
    
    if ([stateString isEqualToString:@"Off"]){
        [singleSwitch setOn: NO];
        //30秒进度倒计时
        
        _countDownView = [[FYCountDownView alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 40, kScreenHeight/2-80, 80, 80) totalTime:30  lineWidth:3.0 lineColor:[UIColor whiteColor]  startBlock:^{
            
        } completeBlock:^{
        }];
        [self.view addSubview:self.countDownView = _countDownView];
        
    }else{
        [defaults setObject:@"On" forKey:@"switchState"];
        [singleSwitch setOn: YES];
        //10秒进度倒计时
        smtlk.waitTimers = 30;
        _countDownView = [[FYCountDownView alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 40, kScreenHeight/2-80, 80, 80) totalTime:30  lineWidth:3.0 lineColor:[UIColor whiteColor]  startBlock:^{
            
        } completeBlock:^{
        }];
        [self.view addSubview:self.countDownView = _countDownView];
        
    }
    
    [self getWifiSSIDInfo];
}
//即将离开页面
- (void)viewWillDisappear:(BOOL)animated{
    //移除遮罩层
    [maskView removeFromSuperview];
    [_countDownView removeFromSuperview];
    [EasyConfigBtn setTitle:LocalizedString(@"Config") forState:UIControlStateNormal];
    [_PasswordText resignFirstResponder];
    [timer invalidate];
}

- (UIButton*)EasyConfigBtn{
    EasyConfigBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/8, [UIScreen mainScreen].bounds.size.height/8*5, [UIScreen mainScreen].bounds.size.width/8*6, 40)];
    EasyConfigBtn.backgroundColor = [UIColor colorWithRed:100/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1];
    EasyConfigBtn.layer.cornerRadius = 3;
    EasyConfigBtn.layer.shadowOffset =  CGSizeMake(0, 1);
    EasyConfigBtn.layer.shadowOpacity = 0.5;
    EasyConfigBtn.layer.shadowColor =  [UIColor blackColor].CGColor;
    [EasyConfigBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [EasyConfigBtn setTintColor:[UIColor lightGrayColor]];
    [EasyConfigBtn setTitle:LocalizedString(@"Config") forState:UIControlStateNormal];
    [EasyConfigBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:EasyConfigBtn];
    [EasyConfigBtn addTarget:self action:@selector(EasyConfigHandle) forControlEvents:UIControlEventTouchUpInside];
    return EasyConfigBtn;
}



- (void)singleSwitchState:(id)sender{
    if (singleSwitch.isOn) {
        smtlk.isConfigOneDevice = YES;
        smtlk.waitTimers = 30;
        [defaults setObject:@"On" forKey:@"switchState"];
        //30秒进度倒计时
        _countDownView = [[FYCountDownView alloc] initWithFrame:CGRectMake(kScreenWidth/2, kScreenHeight/2 - 80, 80, 80) totalTime:30  lineWidth:3.0 lineColor:[UIColor whiteColor]  startBlock:^{
            
        } completeBlock:^{
        }];
        [self.view addSubview:self.countDownView = _countDownView];
        [self AlertMessage:LocalizedString(@"t_switch_on")];

    }else{
        smtlk.waitTimers = 30;
        smtlk.isConfigOneDevice = NO;
        [defaults setObject:@"Off" forKey:@"switchState"];
        //30秒进度倒计时
        _countDownView = [[FYCountDownView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80)/2.0, kScreenHeight/2, 80, 80) totalTime:30  lineWidth:3.0 lineColor:[UIColor whiteColor]  startBlock:^{
            
        } completeBlock:^{
        }];
        [self.view addSubview:self.countDownView = _countDownView];
        [self AlertMessage:LocalizedString(@"t_switch_off")];
    }
}


//一键配置
- (void)EasyConfigHandle{
    if (_SSIDText.text.length == 0) {
        [self AlertMessage:LocalizedString(@"Network_Error")];
    }else{
        if (_PasswordText.text.length == 0) {
            //密码不能为空
            [self AlertMessage:LocalizedString(@"m_pass_can_not_be_empty")];
        }else {
            //保存密码
            NSString * ssidStr= self.SSIDText.text;
            NSString * pswdStr = self.PasswordText.text;
            [self savePswd];
            if(!isconnecting){
                isconnecting = true;
                [smtlk startWithSSID:ssidStr Key:pswdStr withV3x:true
                        processblock:^(NSInteger process) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                            });
                        } successBlock:^(HFSmartLinkDeviceInfo *dev) {
                            
                            //macString = [NSString stringWithFormat:@"%@,%@",dev.mac,dev.ip];
                            // [self  AlertMessage:macString];
                            //获取Mac 地址列表
                            [macArray addObject:[NSString stringWithFormat:@"%@",dev.mac]];
                            
                        } failBlock:^(NSString *failmsg) {
                            [self  AlertMessage:failmsg];
                            [maskView removeFromSuperview];
                        } endBlock:^(NSDictionary *deviceDic) {
                            isconnecting  = false;

                            [maskView removeFromSuperview];
                            [EasyConfigBtn setTitle:LocalizedString(@"Config") forState:UIControlStateNormal];
                            if (macArray.count == 0) {
                                
                                //直接提出
                            }else{
                                if (singleSwitch.isOn) {
                                    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(requestToAddSingle) userInfo:nil repeats:NO];
                                    [timer fire];
                                    
                                }else{
                                    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(requestToAdd) userInfo:nil repeats:NO];
                                    [timer fire];
                                    
                                }
                            }
                        }];
                [EasyConfigBtn setTitle:LocalizedString(@"Wait") forState:UIControlStateNormal];
                [self.view addSubview:maskView];
                
                [self.countDownView startCountDown];
                
            }else{
                [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
                    if(isOk){
                        isconnecting  = false;
                        [EasyConfigBtn setTitle:@"1connect" forState:UIControlStateNormal];
                        
                        [self AlertMessage:@"Failed"];
                    }else{
                        [self AlertMessage:stopMsg];
                        
                    }
                }];
            }
        }
    }
}
- (void)requestToAddSingle{
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
    
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"],@"mac":macArray[0]};
    manager.securityPolicy.allowInvalidCertificates = NO;

    [manager POST:cqtek_api parameters:params headers:@{@"type":@"addDevice"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary* data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([[data objectForKey:@"code"]intValue] == 0) {

            [self.listArray addObjectsFromArray:[data objectForKey:@"snList"]];
            NSLog(@"%@",self.listArray);
        
            [macArray removeAllObjects];
            NewDeviceListView* DevListView = [[NewDeviceListView alloc]init];
            [self.navigationController pushViewController:DevListView animated:YES];
        }else if([[data objectForKey:@"code"]intValue] == 1){
           [macArray removeAllObjects];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [macArray removeAllObjects];
    }];
    
}
//发送请求添加设备
- (void)requestToAdd{
    count = 0;
    NSLog(@"%@",macArray);
    
    for (int i = 0; i < macArray.count; i++) {
        [self addAction:macArray[i]];
    }
}
- (void)addAction:(NSString*)mac{
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
   
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"],@"mac":mac};
    manager.securityPolicy.allowInvalidCertificates = NO;

    [manager POST:cqtek_api parameters:params headers:@{@"type":@"addDevice"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary* data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([[data objectForKey:@"code"]intValue] == 0) {
            count ++;
            [self.listArray addObjectsFromArray:[data objectForKey:@"snList"]];
            NSLog(@"%@",self.listArray);
            
            if (count == macArray.count) {
                [macArray removeAllObjects];
                NewDeviceListView* DevListView = [[NewDeviceListView alloc]init];
                [self.navigationController pushViewController:DevListView animated:YES];
            }
        }else{
            count ++;
            [macArray removeAllObjects];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        count ++;
        [macArray removeAllObjects];
    }];
}

- (void)goBackView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getWifiSSIDInfo {
    if (@available(iOS 13.0, *)) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            [self AlertMessage:LocalizedString(@"t_link_wifi")];
            return;
        }
        
        if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            [self.cllocation requestWhenInUseAuthorization];
            return;
        }
    }
    [self getSSID];
 
}


- (NSString *)getDeviceConnectWifiName{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((CFStringRef)CFBridgingRetain(ifnam));
        if (info && [info count]) {
            break;
        }
    }
    if ([info isKindOfClass:[NSDictionary class]]) {
        //获取SSID
        return [info objectForKey:@"SSID"];
    }
    return nil;
}

- (void)getSSID {
    NSString *wifiSSID = nil;
    CFArrayRef wifiArrayRef = CNCopySupportedInterfaces();
    if (!wifiArrayRef) {
        return;
    }
    NSArray *wifiArray = (__bridge NSArray *)wifiArrayRef;
    for (NSString *wifi in wifiArray) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(wifi));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiSSID = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiArrayRef);
    wifiId = wifiSSID;
    self.SSIDText.text = wifiId;
}
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}
- (void)updateWiFiInformation:(NSNotification *)noti {
    [self getWifiSSIDInfo];
}
 
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self getSSID];
}
//点击空白处收回键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_PasswordText resignFirstResponder];
}

- (void)AlertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
      
    }];
    [alertView addAction:action];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:NO];
}
//  让wifi输入框不可点击
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == _SSIDText){
        return NO;
    }
    return YES;
}

-(void)savePswd{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.PasswordText.text forKey:self.SSIDText.text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}
//在UITextField 编辑完成调用方法
- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

@end
