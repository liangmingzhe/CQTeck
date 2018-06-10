//
//  AccountViewViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/12.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "AccountViewViewController.h"
#import "AccountCellTableViewCell.h"
#import "ScottAlertController.h"
#import "CustmerServiceView.h"
#import "EELoginView.h"
#import "BindMailboxViewView.h"
#import "modifyPassword.h"
#import "Request.h"
#import "Language.h"
@interface AccountViewViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView* ItemTableView;
    NSUserDefaults *defaults;
    
}

@end

@implementation AccountViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = LocalizedString(@"Account");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    ItemTableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ItemTableView.dataSource = self;
    ItemTableView.delegate = self;

    [self.view addSubview:ItemTableView];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"leftCell";
    
    AccountCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (cell == nil)
    {
        cell = [[AccountCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.AccountIcon.image = [UIImage imageNamed:@"main3mailbox"];
        cell.AccountValue.text = LocalizedString(@"l_bindMailBox");
    }else if(indexPath.row == 1){
        cell.AccountIcon.image = [UIImage imageNamed:@"main3modifypass"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.AccountValue.text = LocalizedString(@"l_modifyPass");
    }else if(indexPath.row == 2){
        //退出账户
        cell.AccountIcon.image = [UIImage imageNamed:@"main3logout"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.AccountValue.text = LocalizedString(@"l_exit");
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        //绑定邮箱
        BindMailboxViewView* bindMailbox = [[BindMailboxViewView alloc]init];
        [self.navigationController pushViewController:bindMailbox animated:YES];
        // pushViewController:bindMailbox animated:YES];
    }else if(indexPath.row == 1){
        //修改密码
        modifyPassword* modify = [[modifyPassword alloc]init];
        [self.navigationController pushViewController:modify animated:YES];
    }else if(indexPath.row == 2){
        //退出账户
        [self if_exit];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




- (void)if_exit{
    //退出账户
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:LocalizedString(@"If_LogOut")];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        defaults = [NSUserDefaults standardUserDefaults];
        //退出登陆前，取消推送功能
        NSLog(@"%@",[defaults objectForKey:@"token"]);
        
        if ([defaults objectForKey:@"token"] == nil) {
            //模拟器情况下直接退出
            [defaults setObject:nil forKey:@"cqPass"];
            EELoginView* logout = [[EELoginView alloc]init];
            self.view.window.rootViewController = logout;
            
        }else{
            //真机调试情况下处理
            Request* request = [[Request alloc]init];
            [request setHeader:@"type" value:@"logOut"];
            [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
            [request setParameter:@"token" value:[defaults objectForKey:@"token"]];
            [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
                [defaults setObject:nil forKey:@"cqPass"];
                if([[data objectForKey:@"code"]intValue] == 0){
                [defaults setObject:@"1" forKey:@"logOut"];
                    EELoginView* logout = [[EELoginView alloc]init];
                    self.view.window.rootViewController = logout;

                }else{
                    
                }
                
                
            } failure:^(NSError *error) {
                
            }];

        }
    }];
    ScottAlertAction *action2 = [ScottAlertAction actionWithTitle:LocalizedString(@"Cancel") style:ScottAlertActionStyleDestructive handler:nil];
    [alertView addAction:action];
    [alertView addAction:action2];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}
@end
