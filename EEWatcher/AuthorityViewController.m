//
//  AuthorityViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/7/5.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "AuthorityViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "ScottAlertController.h"
#import "cqtekHeader.pch"
#import "Language.h"
@interface AuthorityViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray* AccountListArray;
    AFHTTPSessionManager *manager;
    NSUserDefaults* defaults;
    UITableView* accountTableView;
    NSString* newUser;
    NSTimer* timer;
}

@end

@implementation AuthorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaults = [NSUserDefaults standardUserDefaults];
    self.navigationItem.title = [defaults objectForKey:@"snaddr"];
    
    AccountListArray = [NSMutableArray arrayWithCapacity:0];
    accountTableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    accountTableView.delegate = self;
    accountTableView.dataSource = self;
    [self.view addSubview:accountTableView];
    
    manager = [[AFHTTPSessionManager manager]init];
    //网络服务参数设置
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
    manager.securityPolicy.allowInvalidCertificates = NO;
    [self request];
    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(TimeHandle) userInfo:nil repeats:YES];
    [timer fire];
}
- (void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];

}

- (void)TimeHandle{
    [self request];
}
- (void)request{
    NSDictionary *params =@{@"snaddr":[defaults objectForKey:@"snaddr"]};
    
    [manager POST:cqtek_api parameters:params headers:@{@"type":@"getDevAuthority"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //将设备列表保存到_datatest中
        
        if([[JSON objectForKey:@"code"]intValue] == 0){
            
            AccountListArray =  [JSON objectForKey:@"array"];
            for (NSDictionary* dic in AccountListArray) {
                if ([[dic objectForKey:@"account"] isEqualToString:[defaults objectForKey:@"cqUser"]]) {
                    [defaults setObject:[NSString stringWithFormat:@"%@",[dic objectForKey:@"authority"]] forKey:@"cqAuthority"];
                }
            }
            [accountTableView reloadData];
        }else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return AccountListArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identfier = @"Authority";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identfier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfier];
    }
    cell.textLabel.text = [AccountListArray [indexPath.row] objectForKey:@"account"];
    if ([[AccountListArray[indexPath.row] objectForKey:@"authority"] intValue] == 1) {
        cell.textLabel.textColor = [UIColor colorWithRed:36/255.0 green:75/255.0 blue:140/255.0 alpha:1];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.textLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if([[defaults objectForKey:@"cqAuthority"] isEqualToString:@"0"]){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//Cell点击后恢复未点击状态
    if ([[defaults objectForKey:@"cqAuthority"] isEqualToString:@"1"]) {
        if ([[defaults objectForKey:@"cqUser"] isEqualToString:[AccountListArray[indexPath.row] objectForKey:@"account"]]) {
            
        }else{
            //
            newUser = [AccountListArray[indexPath.row] objectForKey:@"account"];
            
            [self alertMessage: [NSString stringWithFormat:@"%@ %@?",LocalizedString(@"t_transfer_authority"),newUser]];
            
        }
    }else{
        [self alertMessage2: [NSString stringWithFormat:@"本帐号暂未获取%@的管理权限，无法执行修改阈值，设备名称，设置上传间隔等操作，亦不能主动获取管理权限。如需要进行对设备的修改操作，请登录管理账号执行。",[defaults objectForKey:@"snaddr"]]];
        
    }
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [NSString stringWithFormat:@"%@:%@",LocalizedString(@"Account"),[defaults objectForKey:@"cqUser"]];
    
}

- (void)alertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        
        NSDictionary *params =@{@"snaddr":[defaults objectForKey:@"snaddr"],@"user":[defaults objectForKey:@"cqUser"],@"newUser":newUser};
        
        
        [manager POST:cqtek_api parameters:params headers:@{@"type":@"handOverAuthority"} progress:^(NSProgress * _Nonnull uploadProgress) {
            nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            //将设备列表保存到_datatest中
            
            if([[JSON objectForKey:@"code"]intValue] == 0){
                [self request];
            }else{
                
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }];
    ScottAlertAction *cancel = [ScottAlertAction actionWithTitle:LocalizedString(@"Cancel") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    
    }];
    [alertView addAction:action];
    [alertView addAction:cancel];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}
- (void)alertMessage2:(NSString*)message{
    //退出账户
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {

    }];
    [alertView addAction:action];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}

@end



























