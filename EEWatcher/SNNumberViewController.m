//
//  SNNumberViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/2/20.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "SNNumberViewController.h"
#import "AFNetworking.h"
#import "ScottAlertController.h"
#import "ScanViewController.h"
#import "WhatisRTUViewController.h"
#import "Language.h"
@interface SNNumberViewController ()<UITextFieldDelegate>{
    UITextField* snaddrNumber;
    UITextField* acNumber;
    UIButton* EasyConfigBtn;
    AFHTTPSessionManager *manager;//网络请求管理
    NSUserDefaults* defaults;
    UIButton* scanBtn;
    UIButton* RTUButton;
}

@end

@implementation SNNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.colors = @[(id)[[[UIColor colorWithRed:59/255.0 green:113/255.0 blue:168/255.0 alpha:1] colorWithAlphaComponent:1] CGColor], (id)[[[UIColor colorWithRed:44/255.0 green:115/255.0 blue:170/255.0 alpha:1] colorWithAlphaComponent:1] CGColor]];
    gradientLayer.startPoint = CGPointMake(0, 0);
    
    gradientLayer.endPoint = CGPointMake(0, 1);
    
    gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    [self.view.layer addSublayer:gradientLayer];

    
    self.navigationItem.title = LocalizedString(@"universal");
    
    scanBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [scanBtn setImage:[UIImage imageNamed:@"scan.png"] forState:normal];
    UIView* btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btnView addSubview:scanBtn];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:btnView];
    self.navigationItem.rightBarButtonItem = rightButton;
    [scanBtn addTarget:self action:@selector(goScanView) forControlEvents:UIControlEventTouchUpInside];

    
    UIView* SNview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80)];
    SNview.backgroundColor = [UIColor clearColor];
    SNview.layer.cornerRadius = 3;
    [self.view addSubview:SNview];
    
    UILabel* snaddrLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 100, 40)];
    snaddrLabel.textAlignment = NSTextAlignmentCenter;
    snaddrLabel.text = LocalizedString(@"SerialNumber");
    snaddrLabel.font = [UIFont fontWithName:@"Arial" size:20];
    snaddrLabel.textColor =[UIColor whiteColor];
    
    snaddrNumber = [[UITextField alloc]initWithFrame:CGRectMake(snaddrLabel.frame.origin.x + snaddrLabel.frame.size.width, snaddrLabel.frame.origin.y, SNview.frame.size.width - snaddrLabel.frame.origin.x - snaddrLabel.frame.size.width - 10, 40)];
    snaddrNumber.borderStyle = UITextBorderStyleNone;
    snaddrNumber.backgroundColor = [UIColor whiteColor];
    snaddrNumber.textColor = [UIColor blackColor];
    snaddrNumber.placeholder = LocalizedString(@"SerialNumber");
    snaddrNumber.font = [UIFont fontWithName:@"Arial" size:20];
    snaddrNumber.layer.cornerRadius = 3;
    snaddrNumber.delegate = self;
    UIImageView* lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 81, [UIScreen mainScreen].bounds.size.width, 1)];
    lineImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineImageView];
    
    
    //    UIImageView* line = [[UIImageView alloc]initWithFrame:CGRectMake(_SSIDText.frame.origin.x, _SSIDText.frame.origin.y + _SSIDText.frame.size.height, _SSIDText.frame.size.width, 1)];
    //    line.backgroundColor = [UIColor blackColor];
    [SNview addSubview:snaddrLabel];
    [SNview addSubview:snaddrNumber];
    
    
    UIView* ACview = [[UIView alloc]initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 80)];
    ACview.backgroundColor = [UIColor clearColor];
    ACview.layer.cornerRadius = 3;
    [self.view addSubview:ACview];
    
    UILabel* ACNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 100, 40)];
    ACNumberLabel.textAlignment = NSTextAlignmentCenter;
    ACNumberLabel.text = LocalizedString(@"ac_check");
    ACNumberLabel.font = [UIFont fontWithName:@"Arial" size:22];
    ACNumberLabel.textColor =[UIColor whiteColor];
    
    UIImageView* line2ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 161, [UIScreen mainScreen].bounds.size.width, 1)];
    line2ImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line2ImageView];

    
    acNumber = [[UITextField alloc]initWithFrame:CGRectMake(snaddrNumber.frame.origin.x, ACNumberLabel.frame.origin.y, snaddrNumber.frame.size.width, snaddrNumber.frame.size.height)];
    acNumber.borderStyle = UITextBorderStyleNone;
    acNumber.backgroundColor = [UIColor whiteColor];
    acNumber.font = [UIFont fontWithName:@"Arial" size:20];
    acNumber.placeholder = LocalizedString(@"t_check");
    acNumber.secureTextEntry = YES;
    acNumber.layer.cornerRadius = 3;
    acNumber.delegate = self;
    
    [ACview addSubview:acNumber];
    [ACview addSubview:ACNumberLabel];
    
   //提示语模块
    [self TipsBlock];
    [self RTUButton];
    
    EasyConfigBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/8, [UIScreen mainScreen].bounds.size.height/8*5, [UIScreen mainScreen].bounds.size.width/8*6, 40)];
    EasyConfigBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:200.0/255.0 blue:150.0/255.0 alpha:1];
    EasyConfigBtn.layer.cornerRadius = 3;
    EasyConfigBtn.layer.shadowOffset =  CGSizeMake(0, 1);
    EasyConfigBtn.layer.shadowOpacity = 0.5;
    EasyConfigBtn.layer.shadowColor =  [UIColor blackColor].CGColor;
    [EasyConfigBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [EasyConfigBtn setTintColor:[UIColor lightGrayColor]];
    [EasyConfigBtn setTitle:LocalizedString(@"l_add") forState:UIControlStateNormal];
    [EasyConfigBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:EasyConfigBtn];
    [EasyConfigBtn addTarget:self action:@selector(EasyConfigeration) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewWillAppear:(BOOL)animated{
    defaults = [NSUserDefaults standardUserDefaults];
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
    if ([defaults objectForKey:@"barCode"]!= nil && [defaults objectForKey:@"acCode"]!= nil) {
        snaddrNumber.text = [defaults objectForKey:@"barCode"];
        acNumber.text = [defaults objectForKey:@"acCode"];
    }else{
        [defaults setObject:nil forKey:@"barCode"];
        [defaults setObject:nil forKey:@"acCode"];
    }
}

- (void)EasyConfigeration{
    if (snaddrNumber.text.length != 8) {
        [self alertMessage:LocalizedString(@"l_please_enter_correct_sn")];
    }else{
        if (acNumber.text.length != 8) {
            [self alertMessage:LocalizedString(@"l_please_enter_correct_ac")];
        }else{
            NSDictionary *params = @{@"snaddr":snaddrNumber.text,@"user":[defaults objectForKey:@"cqUser"],@"ac":acNumber.text};
            manager.securityPolicy.allowInvalidCertificates = NO;
            [manager.requestSerializer setValue:@"addDeviceBySN" forHTTPHeaderField:@"type"];
            [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                nil;
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"请求成功:%@", responseObject);
                NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                
                NSLog(@"请求成功JSON:%@", JSON);
                if ([[JSON objectForKey:@"code"]intValue] == 0) {
                    [self alertMessage:[NSString stringWithFormat:@"%@",[JSON objectForKey:@"msg"]]];
                }
                else if([[JSON objectForKey:@"code"]intValue] == 2){
                    [self alertMessage:LocalizedString(@"t_device_exist")];
                }else{
                    [self alertMessage:LocalizedString(@"t_sn_ac_error")];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"请求失败:%@", error.description);
                
            }];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goScanView{
    ScanViewController* scanView = [[ScanViewController alloc]init];
    [self presentViewController:scanView animated:NO completion:nil];

}

- (void)alertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    }];
    [alertView addAction:action];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}
//点击空白处收回键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [snaddrNumber resignFirstResponder];
    [acNumber resignFirstResponder];
}


- (UILabel*)TipsBlock{
    UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(10, 181, [UIScreen mainScreen].bounds.size.width - 20, 100)];
    tips.font = [UIFont fontWithName:@"Arial" size:18];
    [self.view addSubview:tips];
    tips.numberOfLines = 3;
    tips.textColor = [UIColor whiteColor];
    tips.text = LocalizedString(@"t_tips_rtu");
   
    return tips;
}

- (UIButton*)RTUButton{
    RTUButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120, 280, 120, 30)];
    [RTUButton setTitle:LocalizedString(@"l_whatis_rtu") forState:UIControlStateNormal];
    [RTUButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [RTUButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [RTUButton addTarget:self action:@selector(ButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: RTUButton];
    return RTUButton;
}
- (void)ButtonHandle:(id)sender{
    if (sender == RTUButton) {
        WhatisRTUViewController* rtuview = [[WhatisRTUViewController alloc]init];
        [self presentViewController:rtuview animated:YES completion:nil];
    }
    
}







@end
