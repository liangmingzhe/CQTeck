//
//  BindMailboxViewView.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/8.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "BindMailboxViewView.h"
#import "MBProgressHUD.h"
#import "ScottAlertController.h"
#import "CustmerServiceView.h"
#import "cqtekHeader.pch"
#import "Request.h"
#import "Language.h"
@interface BindMailboxViewView ()<UITextFieldDelegate>{
    UITextField* mailBoxText;

    NSUserDefaults* defaults;
    
}
@end

@implementation BindMailboxViewView
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.title = LocalizedString(@"l_bindMailBox");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    UIButton* setButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [setButton setTitle:LocalizedString(@"Confirm") forState:UIControlStateNormal];
    [setButton setBackgroundColor:[UIColor clearColor]];
    [setButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    setButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:setButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    [setButton addTarget:self action:@selector(setAndBack) forControlEvents:UIControlEventTouchUpInside];
    
    mailBoxText = [[UITextField alloc]initWithFrame:CGRectMake(5,20, [UIScreen mainScreen].bounds.size.width - 10, 40)];
    mailBoxText.delegate = self;
    mailBoxText.borderStyle = UITextBorderStyleRoundedRect;
    mailBoxText.layer.borderColor = [UIColor whiteColor].CGColor;
    mailBoxText.font = [UIFont fontWithName:@"Arial" size:20];
    mailBoxText.placeholder = LocalizedString(@"t_please_insert_mail");
    mailBoxText.keyboardType = UIKeyboardTypeDefault;
    [self.view addSubview:mailBoxText];
    
    UILabel* messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, mailBoxText.frame.origin.y + mailBoxText.frame.size.height + 10, [UIScreen mainScreen].bounds.size.width - 10, 120)];
    messageLabel.numberOfLines = 5;
    messageLabel.font = [UIFont fontWithName:@"Arial" size:19];
    messageLabel.text = LocalizedString(@"t_tips_mailbox");
    messageLabel.textColor =[UIColor grayColor];
    [self.view addSubview:messageLabel];

    //解绑邮箱按键
    UIButton* UnbundMail = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/8, messageLabel.frame.origin.y + 120, [UIScreen mainScreen].bounds.size.width/4*3, 50)];
    [self.view addSubview:UnbundMail];

    [UnbundMail setBackgroundColor:[UIColor colorWithRed:36.0/255.0 green:75.0/255.0 blue:157.0/255.0 alpha:0.8]];
    [UnbundMail setTitle:LocalizedString(@"l_disbind") forState:UIControlStateNormal];
    
    [UnbundMail setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [UnbundMail setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [UnbundMail addTarget:self action:@selector(unBundHanle) forControlEvents:UIControlEventTouchUpInside];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    
}


//
//"t_if_disbound" = "Do you want to disbind";
//"t_and" = "and";
//"t_and_mailbox" = "?";

//解绑邮箱
- (void)unBundHanle{
    //首先确认邮箱是否为空
    
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:[NSString stringWithFormat:@"%@%@%@%@%@",LocalizedString(@"t_if_disbound"),[defaults objectForKey:@"cqUser"],LocalizedString(@"t_and"),mailBoxText.text,LocalizedString(@"t_and_mailbox")]];
    
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        Request* request = [[Request alloc]init];
        [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
        [request setParameter:@"mail" value:mailBoxText.text];
        [request setHeader:@"type" value:@"delMailbox"];
        [Request Post:cqtek_api outTime:15
              success:^(NSDictionary *data) {
                  if ([[data objectForKey:@"code"]intValue] == 0) {
                      [self AlertMessage:@"Success!"];
                  }else if([[data objectForKey:@"code"]intValue] == 1){
                      [self AlertMessage:@"Failed!"];
                  }
              } failure:^(NSError *error) {
                  NSLog(@"网络问题，操作失败");
              }];
    }];
    ScottAlertAction* action2 = [ScottAlertAction actionWithTitle:LocalizedString(@"Cancel") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        
    }];
                                 
    [alertView addAction:action];
    [alertView addAction:action2];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setParameter:@"accessToken" value:@"CQY"];
    [request setHeader:@"type" value:@"userInfo"];
    [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
        if([[data objectForKey:@"code"] intValue] == 0){
            mailBoxText.text = [data objectForKey:@"mail"];
        }else if([[data objectForKey:@"code"] intValue] == 2){
            [self AlertMessage:LocalizedString(@"t_not_bound_mailbox")];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)backToMainView{
    [mailBoxText endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//绑定邮箱操作
- (void)setAndBack{
    [mailBoxText endEditing:YES];
    BOOL x =  [self isValidateEmail:mailBoxText.text];
    if (x == 0) {
        [self AlertMessage:LocalizedString(@"t_format_error")];
    }
    else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        Request* request = [[Request alloc]init];
        [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
        [request setParameter:@"mail" value:mailBoxText.text];
        [request setHeader:@"type" value:@"bindMailbox"];
        [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
            if ([[data objectForKey:@"code"]intValue] == 0) {
                [self AlertMessage2:[data objectForKey:@"msg"]];
            }else{
                [self AlertMessage:[NSString stringWithFormat:@"%@",[data objectForKey:@"msg"]]];
            }
            //将设备列表保存到_datatest中
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(NSError *error) {
            NSLog(@"请求失败:%@", error.description);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
    }

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//点击空白处隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [mailBoxText endEditing:YES];
    
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)AlertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        
    }];
    [alertView addAction:action];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
}



- (void)AlertMessage2:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }];
    [alertView addAction:action];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
}

//检查邮箱格式
- (BOOL)isValidateEmail:(NSString *)email1 {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email1];
}

@end
