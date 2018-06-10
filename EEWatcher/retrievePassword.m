//
//  retrievePassword.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/9.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "retrievePassword.h"
#import "AFNetworking.h"
#import "ScottAlertController.h"
#import "Language.h"
@interface retrievePassword ()<UITextFieldDelegate>{
    UITextField* retrievePassText;
    AFHTTPSessionManager *manager;
    NSUserDefaults* defaults;
}

@end

@implementation retrievePassword

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView* titleBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70)];
    UIImageView* image = [[UIImageView alloc]initWithFrame:titleBar.frame];
    image.image = [UIImage imageNamed:@"navgationbar"];
    [self.view addSubview:image];
    titleBar .backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleBar];
   
    UIButton* backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, titleBar.frame.size.height/2 - 5, 20, 20)];
    [backButton setImage:[UIImage imageNamed:@"main1down"] forState:UIControlStateNormal];
    
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:20];
    [titleBar addSubview:backButton];
    [backButton addTarget:self action:@selector(backToLoginView) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* setButton = [[UIButton alloc]initWithFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 55, titleBar.frame.size.height/2 - 10, 50, 30)];
    [setButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [setButton setTitle:LocalizedString(@"l_done") forState:UIControlStateNormal];
    [setButton setBackgroundColor:[UIColor clearColor]];
    setButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:20];
    [titleBar addSubview:setButton];
    [setButton addTarget:self action:@selector(setAndBack) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50, titleBar.frame.size.height/2 - 10, 100, 30)];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = LocalizedString(@"l_retrieve");
    title.font = [UIFont fontWithName:@"Arial" size:20];
    [titleBar addSubview:title];
    UILabel* messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, [UIScreen mainScreen].bounds.size.height/4, [UIScreen mainScreen].bounds.size.width - 10, 80)];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.numberOfLines = 5;
    messageLabel.font = [UIFont fontWithName:@"Arial" size:19];
    messageLabel.text = LocalizedString(@"l_retrieve_tip");
    [self.view addSubview:messageLabel];
    retrievePassText = [[UITextField alloc]initWithFrame:CGRectMake(5, titleBar.frame.origin.y + titleBar.frame.size.height + 10, [UIScreen mainScreen].bounds.size.width - 10, 40)];
    retrievePassText.delegate = self;
    retrievePassText.borderStyle = UITextBorderStyleRoundedRect;
    retrievePassText.layer.borderColor = [UIColor whiteColor].CGColor;
    retrievePassText.font = [UIFont fontWithName:@"Arial" size:20];
    retrievePassText.placeholder = LocalizedString(@"please_enter_user");
    retrievePassText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.view addSubview:retrievePassText];
    
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
}
- (void)backToLoginView{
    //创建动画
    CATransition *animation = [CATransition animation];
    //设置动画类型为立方体动画
    animation.type = @"cube";
    //设置动画时长
    animation.duration =0.5f;
    //设置运动的方向
    animation.subtype =kCATransitionFromRight;
    //控制器间跳转动画
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:animation forKey:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAndBack{
    NSDictionary *params = @{@"user":retrievePassText.text};
    manager.securityPolicy.allowInvalidCertificates = NO;
    [manager.requestSerializer setValue:@"retrievePass" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        NSMutableDictionary*JSON;
        JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [self alertMessage:[JSON objectForKey:@"msg"]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [retrievePassText endEditing:YES];
    
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)alertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}


@end

