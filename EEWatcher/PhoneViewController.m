//
//  SMSViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/8/29.
//  Copyright © 2017年 ChengQian. All rights reserved.
//  短信报警页面

#import "PhoneViewController.h"
#import "Request.h"
#import "cqtekHeader.pch"
#import "MJRefresh.h"//下拉刷新
#import "ScottAlertController.h"
#import "MBProgressHUD.h"
#import "Language.h"
@interface PhoneViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView* smsNumberTavleView;
    NSUserDefaults* defaults;
    NSDictionary* dataDictionary;
    NSString* addMoblie;
}

@end

@implementation PhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = LocalizedString(@"l_mobileList");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self SMSNumberTableView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    //隐藏tabbar
	self.tabBarController.tabBar.hidden = YES;
    defaults = [NSUserDefaults standardUserDefaults];
    [self getAccountMobileList];
    
}
- (void)getAccountMobileList{
    
    Request* request = [[Request alloc]init];
    [request setHeader:@"type" value:@"getAccountMobileList"];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    NSLog(@"%@",[defaults objectForKey:@"cqUser"]);
    [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
        if ([[data objectForKey:@"code"]intValue] == 0) {
            dataDictionary = data;
            [smsNumberTavleView reloadData];
        }
        else{
        
        }
        [smsNumberTavleView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        dataDictionary = nil;
        [smsNumberTavleView.mj_header endRefreshing];
    }];

}
- (void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
}
- (UITableView*)SMSNumberTableView{
    smsNumberTavleView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    smsNumberTavleView.dataSource = self;
    smsNumberTavleView.delegate = self;
    [self.view addSubview:smsNumberTavleView];
    smsNumberTavleView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    smsNumberTavleView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(SMSHeaderRereshing)];

    return smsNumberTavleView;
}

- (void)SMSHeaderRereshing{
    //刷新帐号绑定的手机
    [self getAccountMobileList];
}

- (void)addNewNumber{
    [self alertAddMobile];
}


//- (UILabel*)Tips{
//    UILabel* leftTips =[UILabel alloc]initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
//    return <#expression#>
//}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [NSString stringWithFormat:@"%@:%@",LocalizedString(@"Account"),[defaults objectForKey:@"cqUser"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (dataDictionary != nil) {
        return [[dataDictionary objectForKey:@"mobileList"] count];
    }
    else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* smsCell = @"SMSCELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:smsCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:smsCell];
    
    }
    if ([[dataDictionary objectForKey:@"mobileList"] count] >0){
        if(indexPath.row <= [[dataDictionary objectForKey:@"mobileList"] count]){
            cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[dataDictionary objectForKey:@"mobileList"][indexPath.row]];
        }

    }else{
            cell.textLabel.text = [NSString stringWithFormat:@"%@",@"尚未关联手机号码"];
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return  80;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView* footView = [[UIView alloc]initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 80)];
    UIButton* add = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/16, 40, [UIScreen mainScreen].bounds.size.width/8*7, 50)];
//    add.backgroundColor = [UIColor colorWithRed:0.1 green:0.3 blue:0.6 alpha:1];
    [add setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [add setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    add.backgroundColor = [UIColor colorWithRed:44/255.0 green:115/255.0 blue:175/255.0 alpha:1];

    [add setTitle:LocalizedString(@"l_addMobile") forState:UIControlStateNormal];
    [add addTarget:self action:@selector(addNewNumber) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:add];
    return footView;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

/**
 *  左滑cell时出现什么按钮
 */
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        Request* request = [[Request alloc]init];
        [request setHeader:@"type" value:@"delMobileToAccount"];
        [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
        [request setParameter:@"mobile" value:[dataDictionary objectForKey:@"mobileList"][indexPath.row]];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([[data objectForKey:@"code"]intValue] == 0) {
                NSLog(@"%@",data);
                [self alertMessage:[data objectForKey:@"msg"]];
                
            }else if([[data objectForKey:@"code"]intValue] == 2){
                //yi
                [self alertMessage:[data objectForKey:@"msg"]];
            }
            else{
                [self getAccountMobileList];
            }

        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];

        }];

    }];
    
    return @[action];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertAddMobile{
    ScottAlertView *alert = [ScottAlertView alertViewWithTitle:@"添加手机号码" message:@"输入手机号码到账号下"];

    ScottAlertAction *cancel = [ScottAlertAction actionWithTitle:LocalizedString(@"Cancel") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancel];
    ScottAlertAction *add = [ScottAlertAction actionWithTitle:LocalizedString(@"l_add") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        Request* request = [[Request alloc]init];
        [request setHeader:@"type" value:@"addMobileToAccount"];
        [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
        [request setParameter:@"mobile" value:addMoblie];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([[data objectForKey:@"code"]intValue] == 0) {
                NSLog(@"%@",data);
               [self alertMessage:[data objectForKey:@"msg"]];
            }else if([[data objectForKey:@"code"]intValue] == 1){
                //
                [self alertMessage:@"帐号内无可控制的设备"];
            }else if([[data objectForKey:@"code"]intValue] == 2){
                //号码已被绑定过。
                [self alertMessage:[data objectForKey:@"msg"]];
            }
            else{
                [self getAccountMobileList];
            }
        } failure:^(NSError *error) {
           [MBProgressHUD hideHUDForView:self.view animated:YES];
             [self alertMessage:[NSString stringWithFormat:@"%@",error]];
        }];
    }];
    [alert addAction:add];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入11位手机号码";
        textField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    [ScottShowAlertView showAlertViewWithView:alert backgroundDismissEnable:YES];
}
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    addMoblie = textField.text;
    // Enforce a minimum length of >= 5 characters for secure text alerts.
    
}

- (void)alertMessage:(NSString*)str{
    ScottAlertView *alert = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:str];
    
    ScottAlertAction *tipsOK = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
         [self getAccountMobileList];
    }];
    [alert addAction:tipsOK];
    [ScottShowAlertView showAlertViewWithView:alert backgroundDismissEnable:YES];
}
@end
