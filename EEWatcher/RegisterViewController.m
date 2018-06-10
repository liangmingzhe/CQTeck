//
//  RegisterViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/11/18.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "RegisterViewController.h"
#import "declarationViewController.h"
#import "ScottAlertController.h"
#import "cqtekHeader.pch"
#import "Algorithm.h"
#import "Request.h"
#import "MBProgressHUD.h"
#import "Language.h"
@interface RegisterViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView* RegistTableView;
    NSString* user;
    NSString* password;
    NSString* password2;
    NSString* name;
    NSUserDefaults* defaults;
    UIButton* Register;
    UIButton* checkDeclaration;
    UIButton* declaration;

}
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIView* titleBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    UIImageView* image = [[UIImageView alloc]initWithFrame:titleBar.frame];
    image.image = [UIImage imageNamed:@"navgationbar"];
    [self.view addSubview:image];
    titleBar .backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleBar];
    UIButton* backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, titleBar.frame.size.height/2, 20, 20)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"main1down"] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
    [titleBar addSubview:backButton];
    [backButton addTarget:self action:@selector(backToLoginView) forControlEvents:UIControlEventTouchUpInside];
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50, titleBar.frame.size.height/2 - 10, 100, 30)];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = LocalizedString(@"l_Register");
    title.font = [UIFont fontWithName:@"Arial" size:18];
    [titleBar addSubview:title];
    
    [self RegistTableView];
    [self checkDeclaration];
    [self RegisterBtn];

}

- (UITableView*)RegistTableView{
    RegistTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 60) style:UITableViewStylePlain];
    RegistTableView.dataSource = self;
    RegistTableView.delegate = self;
    RegistTableView.scrollEnabled = false;
    RegistTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //移除多余的cell
    [self.view addSubview:RegistTableView];
    return RegistTableView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UIButton*)RegisterBtn{
    Register = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/8, [UIScreen mainScreen].bounds.size.height/4*3, [UIScreen mainScreen].bounds.size.width/4*3, 40)];
    [Register setBackgroundImage:[UIImage imageNamed:@"bgregister.png"] forState:UIControlStateNormal];
    [Register setBackgroundImage:[UIImage imageNamed:@"bgregister2.png"] forState:UIControlStateHighlighted];
    [Register setTitle:LocalizedString(@"l_Register") forState:UIControlStateNormal];
    [Register addTarget:self action:@selector(RegisterHandle) forControlEvents:UIControlEventTouchUpInside];
    Register.enabled = false;
    [self.view addSubview:Register];
  
    return Register;
}

- (void)RegisterHandle{
    //账号必须为字母或数字 写进算法里面
    if (user.length >= 6 & user.length <= 20) {
        BOOL checkUser = [Algorithm isOnlyNumberAndCharactors:user];
        if (checkUser == true) {
            if (password.length >=6 & password.length <=20) {
                if (password == password2) {
                    if (![name containsString:@" "]&&name>0) {
                        Request* request = [[Request alloc]init];
                        [request setHeader:@"type" value:@"register"];
                        [request setParameter:@"user" value:user];
                        [request setParameter:@"password" value:[Algorithm md5:password]];
                        [request setParameter:@"name" value:name];
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        
                        [Request Post:cqtek_api outTime:10 success:^(NSDictionary *data) {
                            NSLog(@"%@",data);
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            if ([[data objectForKey:@"code"] intValue] == 0) {
                                [self alertMessage:[NSString stringWithFormat:@"%@",[data objectForKey:@"msg"]]];
                                [defaults setObject:@"" forKey:@"cqUser"];
                                [defaults setObject:@"" forKey:@"cqPass"];
                            }else if([[data objectForKey:@"code"]intValue] == 1){
                                [self alertMessage:[NSString stringWithFormat:@"%@",[data objectForKey:@"msg"]]];
                            }else{
                                [self alertMessage:[NSString stringWithFormat:@"%@",[data objectForKey:@"msg"]]];
                            }
                        } failure:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
                    }else{
                        if ([name containsString:@" "]) {
                            
                            [self alertMessage:LocalizedString(@"t_nickname_format")];
                        }else if(name.length == 0){
                            [self alertMessage:LocalizedString(@"t_account_format")];
                        }
                    }
                }else{
                   [self alertMessage:LocalizedString(@"t_pass_not_fit")];
                }
            }else{
                if (password.length < 6) {
                    [self alertMessage:LocalizedString(@"t_password_format")];
                }else if(password.length >20){
                    [self alertMessage:LocalizedString(@"t_password_format")];
                }
            
            }
        }else{
            [self alertMessage:LocalizedString(@"t_account_format")];
        }
    }else{
        [self alertMessage:LocalizedString(@"t_account_format")];
    }
}

#pragma tableView
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* idr1 =@"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:idr1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idr1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITextField* textField = [[UITextField alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 280, cell.frame.size.height/2 - 15, 270, 30)];
        textField.delegate = self;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [cell addSubview:textField];
        textField.tag = indexPath.row;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.returnKeyType = UIReturnKeyDone;
        [textField addTarget:self action:@selector(testHandle:) forControlEvents:UIControlEventEditingChanged];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:16];
        if(indexPath.row == 0){
            cell.textLabel.text = LocalizedString(@"Account");
            textField.placeholder = LocalizedString(@"t_account_format");
        }else if(indexPath.row == 1){
            cell.textLabel.text = LocalizedString(@"l_password");
            textField.placeholder = LocalizedString(@"t_password_format");
            textField.secureTextEntry = YES;
        }
        else if(indexPath.row == 2){
            UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 80, cell.frame.size.height)];
            title.numberOfLines = 2;
            title.text = LocalizedString(@"l_password_again");
            [cell addSubview:title];
//            cell.textLabel.text = ;
            cell.textLabel.numberOfLines = 2;
            textField.placeholder = LocalizedString(@"t_password_format");
            textField.secureTextEntry = YES;
        }else if(indexPath.row == 3){
            cell.textLabel.text = LocalizedString(@"l_nickname");
            textField.placeholder = LocalizedString(@"t_nickname_format");
        }else if(indexPath.row == 4){
            cell.textLabel.text = LocalizedString(@"l_phone");
        }
    }
    
    return cell;
}

- (void)testHandle:(UITextField*)textField{
    if (textField.tag == 0) {
        textField.text = [textField.text lowercaseString];
        user = textField.text;
    }else if(textField.tag == 1){
        password = textField.text;
    }else if(textField.tag == 2){
        password2 = textField.text;
    }else if(textField.tag == 3){
        name = textField.text;
    }
}

- (UIButton*)checkDeclaration{
    checkDeclaration = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 100, [UIScreen mainScreen].bounds.size.height/2 - 50, 20, 20)];
    [checkDeclaration setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    [checkDeclaration setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
    [checkDeclaration addTarget:self action:@selector(buttonHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkDeclaration];
    
    declaration = [[UIButton alloc]initWithFrame:CGRectMake(checkDeclaration.frame.origin.x + checkDeclaration.frame.size.width, checkDeclaration.frame.origin.y - 10, 200, 40)];
    [declaration setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    declaration.titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
    [declaration setTitle:LocalizedString(@"l_protocol") forState:UIControlStateNormal];
    [declaration addTarget:self action:@selector(displaydocument) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:declaration];
    return checkDeclaration;
}

- (void)buttonHandle{
    if (checkDeclaration.isSelected == true) {
        checkDeclaration.selected = false;
        Register.enabled = false;
    }else if(checkDeclaration.isSelected == false){
        checkDeclaration.selected = true;
        Register.enabled = true;
        
    }
}
- (void)displaydocument{
    declarationViewController* doc = [[declarationViewController alloc]init];
    [self presentViewController:doc animated:YES completion:nil];
}
- (void)backToLoginView{
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
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}
- (void)alertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}
@end
