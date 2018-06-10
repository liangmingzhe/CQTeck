//
//  AreaView.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/12/6.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "ModifyNameView.h"
#import "GetMessage.h"
#import "ScottAlertController.h"
#import "Language.h"

@interface ModifyNameView ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSMutableDictionary* areas;
    UITableView* AreaTable;
    NSUserDefaults* defaults;
    AFHTTPSessionManager *manager;
    
    NSString* selectArea;
    NSString* str2;
    UITextField* NewTextField;
}

@end

@implementation ModifyNameView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    areas = [[NSMutableDictionary alloc]initWithCapacity:0];
    //背景色设备白色
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    UIView* titleBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    titleBar.backgroundColor = [UIColor clearColor];
    UIImageView* titleImageView = [[UIImageView alloc]initWithFrame:titleBar.frame];
    titleImageView.image = [UIImage imageNamed:@"navgationbar"];
    [self.view addSubview:titleImageView];
    [self.view addSubview:titleBar];
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 60, titleBar.frame.size.height/2 - 10, 120, 30)];
    title.font = [UIFont fontWithName:@"Arial" size:20];
    title.textColor = [UIColor whiteColor];
    title.text = LocalizedString(@"l_Area");
    title.textAlignment = NSTextAlignmentCenter;
    [titleBar addSubview:title];
    UIButton* backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, titleBar.frame.size.height/2 - 5, 20, 20)];
    [backButton setImage:[UIImage imageNamed:@"main1down"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToMain) forControlEvents:UIControlEventTouchUpInside];
    [titleBar addSubview:backButton];
    
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
                                                         
    AreaTable = [[UITableView alloc]initWithFrame:CGRectMake(0, titleBar.frame.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    AreaTable.dataSource = self;
    AreaTable.delegate = self;
    AreaTable.scrollEnabled = YES;//列表不可滚动
    AreaTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:AreaTable];
    
    defaults = [NSUserDefaults standardUserDefaults];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [self requestArea];
}
- (void)backToMain{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//向服务器请求获取区域数据
- (void)requestArea{
    //网络服务参数设置
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"]};
    manager.securityPolicy.allowInvalidCertificates = NO;
    [manager.requestSerializer setValue:@"getAreaInfo" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功
        NSMutableDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        areas = JSON;
        [AreaTable reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
        [GetMessage showMessage:NSLocalizedString(@"Request_Failed", nil) image:[UIImage imageNamed:@"netErr"]];
    }];
}

- (void)goBackView{
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[areas objectForKey:@"array"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* SeCell= @"cell";
    UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SeCell];
    cell.textLabel.text = [areas objectForKey:@"array"][indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([[defaults objectForKey:@"areaAll"] isEqualToString: [areas objectForKey:@"array"][indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectArea = [defaults objectForKey:@"areaAll"];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showSystemAlert:[areas objectForKey:@"array"][indexPath.row]];
}

- (void)showSystemAlert:(NSString*)str
{
    ScottAlertView *alert = [ScottAlertView alertViewWithTitle:NSLocalizedString(@"Tips", nil) message:@" 请输入新的区域名"];

    ScottAlertAction *cancel = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    ScottAlertAction *save = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"],@"oldArea":str,@"newArea" :str2};
        manager.securityPolicy.allowInvalidCertificates = NO;
        [manager.requestSerializer setValue:@"setAreaInfo" forHTTPHeaderField:@"type"];
        [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //请求成功
            NSMutableDictionary* JSON2 = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([[JSON2 objectForKey:@"code"]intValue] == 0) {
                //设置成功, 将区域名字更新
                if ([selectArea isEqualToString:str]) {
                    [defaults setObject:str2 forKey:@"areaAll"];
                }
                [self requestArea];
                [self alertmessage:@"设备名修改成功"];
                
            }
            else if ([[JSON2 objectForKey:@"code"]intValue] == 1){
                [self requestArea];
                [self alertmessage:@"设备名已存在"];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"请求失败:%@", error.description);
        }];
        //--------

        
    }];
    [alert addAction:save];
    
    //  添加重命名弹出对话框中的text
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = str;
        str2 = str;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    [ScottShowAlertView showAlertViewWithView:alert backgroundDismissEnable:YES];
}
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    str2 = textField.text;
    // Enforce a minimum length of >= 5 characters for secure text alerts.
    
}

- (void)alertmessage:(NSString*)message{
    
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:NSLocalizedString(@"Tips", nil) message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    
    }];
    [alertView addAction:action];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}

@end
