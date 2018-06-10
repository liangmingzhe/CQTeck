//
//  EELoginView.m
//  EEWatcher
//
//  Created by 梁明哲 on 16/7/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//
/**
 *
 *----------Dragon be here!----------/
 *　　    ┏┓    ┏┓
 * 　　┏━━┛┻━━━━┛┻━┓
 * 　　┃           ┃
 * 　　┃     ━     ┃
 * 　　┃  ┳┛   ┗┳  ┃
 * 　　┃           ┃
 * 　　┃     ┻     ┃
 * 　　┃           ┃
 * 　　┗━┓     ┏━━━┛
 * 　 　 ┃     ┃神兽保佑
 * 　  　┃     ┃代码无BUG！
 * 　　  ┃     ┗━━━━┓
 * 　  　┃          ┣┓
 *  　　 ┃         ┏┛
 * 　　  ┗┓┓┏━┳┓┏━━┛
 * 　  　 ┃┫┫ ┃┫┫
 *   　　 ┗┻┛ ┗┻┛
 * ━━━━━━ 神兽出没 ━━━━━━
 */
#import "EELoginView.h"
#import "EERootController.h"
#import "AFNetworking/AFNetworking.h"
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
#import "retrievePassword.h"
#import "ScottAlertController.h"
#import "Request.h"
#import "Masonry/Masonry.h"
#import "RegisterViewController.h"

@interface EELoginView (){
    UITextField* User;
    UITextField* Pass;
    UIButton* LoginBtn;
    NSUserDefaults* defaults;
    MBProgressHUD* m_loading;
    NSString* passwordmd5;
//-----
}
@end
@implementation EELoginView

- (void)viewDidLoad {
    //自动登录功能
    [self autoLogin];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView* backView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    backView.backgroundColor = [UIColor clearColor];
    backView.image = [UIImage imageNamed:@"backImage"];
    [self.view addSubview:backView];
    __weak typeof (self) weakself = self;
    UIImageView* LogoView = [UIImageView new];
    LogoView.image = [UIImage imageNamed:@"title"];
    [self.view addSubview:LogoView];    
    [LogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(240, 80));
        make.top.equalTo(weakself.view.mas_top).offset(self.view.frame.size.height/12);
    }];
    //--------------------------
    User = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width/8, self.view.frame.size.height/4, self.view.frame.size.width/8*6, 50)];
    User.borderStyle = UITextBorderStyleNone;
    User.textAlignment = NSTextAlignmentCenter;
    User.backgroundColor = [UIColor clearColor];
    User.textColor = [UIColor blackColor];
    User.font = [UIFont fontWithName:@"Arial" size:22];
    User.placeholder = LocalizedString(@"please_enter_user");
    User.layer.borderWidth = 1;
    User.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:User];
    
    
    Pass = [[UITextField alloc]initWithFrame:CGRectMake(User.frame.origin.x, User.frame.origin.y + User.frame.size.height + 10, self.view.frame.size.width/8*6, User.frame.size.height)];
    Pass.borderStyle = UITextBorderStyleNone;
    Pass.textAlignment = NSTextAlignmentCenter;
    Pass.textColor = [UIColor blackColor];
    Pass.backgroundColor = [UIColor clearColor];
    Pass.secureTextEntry = YES;
    Pass.font = [UIFont fontWithName:@"Arial" size:22];
    Pass.placeholder = LocalizedString(@"please_enter_pass");
    Pass.layer.borderColor = [UIColor blackColor].CGColor;
    Pass.layer.borderWidth = 1;
    [self.view addSubview:Pass];
    //--------------------------
    LoginBtn = [[UIButton alloc]initWithFrame:CGRectMake(Pass.frame.origin.x,Pass.frame.origin.y + Pass.frame.size.height + 10, Pass.frame.size.width, 50)];
    
    LoginBtn.titleLabel.font = [UIFont fontWithName:@"Arial" size:20];
    [LoginBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"l_Login")] forState:UIControlStateNormal];
    [LoginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [LoginBtn setBackgroundImage:[UIImage imageNamed:@"bglogin.png"] forState:UIControlStateNormal];
    [LoginBtn setBackgroundImage:[UIImage imageNamed:@"bglogin2.png"] forState:UIControlStateHighlighted];
    LoginBtn.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:205.0/255.0 blue:110.0/255.0 alpha:0.7];
    
    LoginBtn.layer.cornerRadius = 10;
    [LoginBtn addTarget:self action:@selector(gotoMain) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:LoginBtn];
    //找回密码按键初始化
    UIButton* retrievePassButton = [[UIButton alloc]initWithFrame:CGRectMake(Pass.frame.origin.x - 10, LoginBtn.frame.origin.y + LoginBtn.frame.size.height + 10, 150, 40)];
    retrievePassButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
    retrievePassButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [retrievePassButton setTitle:LocalizedString(@"l_foget_pass") forState:UIControlStateNormal];
    [retrievePassButton setTitleColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.8 alpha:1] forState:UIControlStateNormal];
    [retrievePassButton addTarget:self action:@selector(getPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:retrievePassButton];

    //--------------------------
    UILabel* rightServiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/12*11 , [UIScreen mainScreen].bounds.size.width, 30)];
    rightServiceLabel.textColor = [UIColor whiteColor];
    rightServiceLabel.textAlignment = NSTextAlignmentCenter;
    rightServiceLabel.text = LocalizedString(@"company");
    rightServiceLabel.font = [UIFont fontWithName:@"Arial" size:18];
    [self.view addSubview:rightServiceLabel];
    
//    //语言切换按键
    UIButton* LanguageBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, [UIScreen mainScreen].bounds.size.height/12, 50, 30)];
    [LanguageBtn setTitle:LocalizedString(@"t_language_cn") forState:UIControlStateNormal];
    [LanguageBtn setBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.8 alpha:1]];
    [LanguageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    LanguageBtn.layer.cornerRadius = 10;
    [LanguageBtn addTarget:self action:@selector(changeLanguage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:LanguageBtn];
    //注册功能按键
    UIButton* RegisterBtn = [[UIButton alloc]initWithFrame:CGRectMake(Pass.frame.origin.x + Pass.frame.size.width - 90, LoginBtn.frame.origin.y + LoginBtn.frame.size.height + 10, 100, 40)];
    
    RegisterBtn.titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
    [RegisterBtn setTitle:[NSString stringWithFormat:@"%@", LocalizedString(@"l_Register")] forState:UIControlStateNormal];
    [RegisterBtn setTitleColor:[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1] forState:UIControlStateNormal];
    RegisterBtn.layer.cornerRadius = 10;
    [RegisterBtn addTarget:self action:@selector(goToRegidter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:RegisterBtn];
    
}


- (void)getPassword{
    retrievePassword* retrievePass = [[retrievePassword alloc]init];
    //创建动画
    CATransition *animation = [CATransition animation];
    //设置动画类型为立方体动画
    animation.type = @"cube";
    //设置动画时长
    animation.duration =0.5f;
    //设置运动的方向
    animation.subtype =kCATransitionFromLeft;
    //控制器间跳转动画
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:animation forKey:nil];
    [self presentViewController:retrievePass animated:NO completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    defaults = [NSUserDefaults standardUserDefaults];
    User.text = [defaults objectForKey:@"cqUser"];
    Pass.text = [defaults objectForKey:@"cqPass"];
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSLog(@"%ld",(long)status);
    
}


- (void) viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:1.0 animations:^{
        
//        self.view.alpha = 0.7f;    // 作用在fadeMeView视图
    }];
    
}

- (void)changeLanguage{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString* curLang = [Language getUserLanguage];
    if ([curLang isEqualToString: EN]) {
        [Language setUserlanguage:CNS];
    }else{
        [Language setUserlanguage:EN];
    }
}

- (void)autoLogin{
    m_loading = [[MBProgressHUD alloc]initWithView:self.view];
    m_loading.dimBackground = YES;
    m_loading.labelText = LocalizedString(@"l_loading");

    defaults = [NSUserDefaults standardUserDefaults];
    

    NSString* str = [defaults objectForKey:@"cqPass"];
    if (str == nil) {
        
    }else{
        [m_loading show:YES];
        passwordmd5 = [self md5:str];
        Request* request = [[Request alloc]init];
        [request setHeader:@"type" value:@"login"];
        [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
        [request setParameter:@"password" value:passwordmd5];
        
        [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
            
            if([[data valueForKey:@"code"]longValue] == 1){
                [self alertMessage:@"登录失败" msg:@"1.请检查用户名或密码是否正确\n2.请检查是否包含空格\n3.是否未区分大小写"];
            }else if([[data valueForKey:@"code"]longValue] == 0){
                //发送token后在进入主页
                [self updateToken];
            }else{
            
            }
            [m_loading removeFromSuperview];
        } failure:^(NSError *error) {
            [m_loading removeFromSuperview];
                [self alertMessage:@"网络" msg:LocalizedString(@"Network_Error")];
            
        }];

    }
}

- (void)goToRegidter{
    RegisterViewController* reg = [[RegisterViewController alloc]init];
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
    [self presentViewController:reg animated:NO completion:nil];
}

- (void)gotoMain{
    m_loading = [[MBProgressHUD alloc]initWithView:self.view];
    m_loading.dimBackground = YES;
    m_loading.labelText = LocalizedString(@"l_loading");
    [self.view addSubview:m_loading];
    //进入主页之前，检查用户名以及密码是否为空
    if (User.text.length == 0) {
        //[self AlertView:@"用户名不能为空"];

        [self alertMessage:@"提示" msg:LocalizedString(@"m_user_can_not_be_empty")];
    }else {
        //检查密码是否为空
        if (Pass.text.length == 0){
            [self alertMessage:@"提示" msg:LocalizedString(@"m_pass_can_not_be_empty")];
        }
        else{
//            //检查密码是否为空
            [m_loading show:YES];
   
            Request* request = [[Request alloc]init];
            [request setHeader:@"type" value:@"login"];
            [request setParameter:@"user" value:User.text];
            [request setParameter:@"password" value:[self md5:Pass.text]];
            
            [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
                
                [m_loading removeFromSuperview];
                if([[data valueForKey:@"code"]longValue] == 1){
                    [self alertMessage:@"登录失败" msg:@"1.请检查用户名或密码是否正确\n2.请检查是否包含空格\n3.是否未区分大小写"];
                    
                }else if([[data valueForKey:@"code"]longValue] == 0){
                    [defaults setObject:User.text forKey:@"cqUser"];
                    [defaults setObject:Pass.text forKey:@"cqPass"];
                    
                    [self updateToken];
                }
            } failure:^(NSError *error) {
                NSLog(@"请求失败:%@", error.description);
                [m_loading removeFromSuperview];
                [self alertMessage:@"网络" msg:LocalizedString(@"Network_Error")];
            }];
            
        }

    }
}

- (void)updateToken{
    if ([defaults objectForKey:@"token"] == nil) {
        NSLog(@"login with simuralter");
        EERootController* toRoot = [[EERootController alloc]init];
        [self presentViewController:toRoot animated:YES completion:nil];

    }else{
        Request* request = [[Request alloc]init];
        [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
        [request setParameter:@"token" value:[defaults objectForKey:@"token"]];
        [request setParameter:@"accessToken" value:@"CQY"];
        [request setHeader:@"type" value:@"setDevToken"];
        [Request Post:cqtek_api outTime:15
              success:^(NSDictionary *data) {
                  if ([[data objectForKey:@"code"]intValue] == 0) {
                      
                      EERootController* toRoot = [[EERootController alloc]init];
                      
                      [self presentViewController:toRoot animated:YES completion:nil];
                  }
              } failure:^(NSError *error) {
                  NSLog(@"网络问题，操作失败");
              }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//点击空白处隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [User endEditing:YES];
    [Pass endEditing:YES];
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (void)alertMessage:(NSString*)title msg:(NSString*)message{
    //退出账户
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:title message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {

    }];
    [alertView addAction:action];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}


@end
