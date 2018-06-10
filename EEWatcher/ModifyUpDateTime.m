//
//  ModifyUpDateTime.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/12/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "ModifyUpDateTime.h"
#import "ScottAlertController.h"
@interface ModifyUpDateTime ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView* ItemTableView;
    UpdateCell* cell;
    AFHTTPSessionManager* manager;
    NSMutableDictionary* JSON;
    NSString* str;
    MBProgressHUD* m_loading;
    NSUserDefaults* defaults;
}

@end

@implementation ModifyUpDateTime

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"l_deviceinterval", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    UIButton* SetButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 50, 30)];
    SetButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [SetButton setTitle:@"修改" forState:normal];
    [SetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [SetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [SetButton addTarget:self action:@selector(setAndGoBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]initWithCustomView:SetButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    ItemTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    ItemTableView.dataSource = self;
    ItemTableView.delegate = self;
    ItemTableView.scrollEnabled = NO;//列表不可滚动
    ItemTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:ItemTableView];

//提示
    UILabel* tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 60, [UIScreen mainScreen].bounds.size.width - 10, 60)];
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.textColor = [UIColor lightGrayColor];
    tipsLabel.numberOfLines = 2;
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tipsLabel.text = @"提示：单位:秒(s)。设备上传间隔最大不超过5分钟，即300秒。";
    [self.view addSubview:tipsLabel];
    
    m_loading = [[MBProgressHUD alloc]initWithView:self.view];
    m_loading.dimBackground = YES;
    m_loading.labelText = NSLocalizedString(@"l_loading", nil);
    [self.view addSubview:m_loading];

}
- (void)viewWillAppear:(BOOL)animated{
    defaults = [NSUserDefaults standardUserDefaults];
    str = [[[DeviceSetController sharedInstance2]Dic1]objectForKey:@"devGap"];
    [ItemTableView reloadData];
    

}
//设置成功并返回
- (void)setAndGoBack{
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
    manager.securityPolicy.allowInvalidCertificates = NO;

    NSDictionary *params = @{@"user":@"xsf",@"snaddr": [[[EEMainPageView sharedInstance]selectedDevice]objectForKey:@"snaddr"],@"devGap":str};
    [manager.requestSerializer setValue:@"modifyDeviceGap" forHTTPHeaderField:@"type"];
    [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];

        NSLog(@"请求成功JSON:%@", JSON);
        if ([[JSON objectForKey:@"msg"] isEqualToString:@"success"]) {
            [self AlertMessage:@"设备修改成功"];
        }else{
            [self AlertMessage:@"设备修改失败"];
        }
        //        timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(RequestDevDate) userInfo:nil repeats:YES];
        //        [timer fire];
        [ItemTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
        [m_loading removeFromSuperview];
    }];
}

#pragma tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    cell = [[[NSBundle mainBundle]loadNibNamed:@"UpdateCell" owner:nil options:nil] lastObject];
    cell.time.delegate = self;
    cell.time.text = str;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.time addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [cell.deleteBtn addTarget:self action:@selector(deleteText) forControlEvents:UIControlEventTouchUpInside];
    return cell;

}

- (void)AlertMessage:(NSString*)message{
    //退出账户
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:NSLocalizedString(@"Tips", nil) message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    }];
    [alertView addAction:action];
    
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}



- (void)goBackView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deleteText{
    cell.time.text = @"";
}

- (void)textFieldDidChange:(UITextField *)textField
{
    
    if (textField == cell.time) {
        str = cell.time.text;
        if (textField.text.length > 2) {
            textField.text = [textField.text substringToIndex:2];
        }
    }
}

//点击空白处收回键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [cell.time resignFirstResponder];
}

@end
