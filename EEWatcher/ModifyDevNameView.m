//
//  ModifyDevNameView.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/11/30.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "ModifyDevNameView.h"
#import "ScottAlertController.h"
#import "ModifyDevNameCell.h"
#import "AFNetworking.h"
#import "DeviceSetController.h"
#import "MBProgressHUD.h"
#import "cqtekHeader.pch"
#import "Language.h"
@interface ModifyDevNameView ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView* ItemTableView;
    NSString* NewDevName;
    ModifyDevNameCell* cell;
    AFHTTPSessionManager *manager;
    NSMutableDictionary *JSON;//http请求返回的JSON格式数据
    MBProgressHUD* m_loading;
    NSUserDefaults* defaults;
}

@end

@implementation ModifyDevNameView

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = LocalizedString(@"l_devicename");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    UIButton* SetButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 50, 30)];
    SetButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [SetButton setTitle:LocalizedString(@"l_done") forState:normal];
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


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{

}

- (void)goBackView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setAndGoBack{
    
    
    
    
    
        //确认格式正确 ，上传，获取返回，返回上一页面
        m_loading = [[MBProgressHUD alloc]initWithView:self.view];
        m_loading.dimBackground = YES;
        m_loading.labelText = NSLocalizedString(@"l_loading", nil);
        [self.view addSubview:m_loading];
        [m_loading show:YES];
        
        manager = [[AFHTTPSessionManager manager]init];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 15.0;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
        
        NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"],@"snaddr":[defaults objectForKey:@"snaddr"],@"devName":cell.DevTextField.text};
        manager.securityPolicy.allowInvalidCertificates = NO;
        [manager.requestSerializer setValue:@"setDevName" forHTTPHeaderField:@"type"];
        [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [m_loading removeFromSuperview];
            JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([[JSON objectForKey:@"code"]intValue] == 0) {
                //修改成功
                defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:cell.DevTextField.text forKey:@"deviceName"];//设备名
                [self AlertMessage2:[NSString stringWithFormat:@"%@",LocalizedString(@"l_modifysuccess")]];
            }else{
                [self AlertMessage:[JSON objectForKey:[NSString stringWithFormat:@"%@",LocalizedString(@"l_modifyfailed")]]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [m_loading removeFromSuperview];
            NSLog(@"请求失败:%@", error.description);
            [self AlertMessage:NSLocalizedString(@"l_modifyfailed", nil)];
        }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = @"ModifyDevNameCell";
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[ModifyDevNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.DevTextField.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.DevTextField.text = [[[DeviceSetController sharedInstance2]Dic1] objectForKey:@"devName"];
    [cell.DevTextField addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
    [cell.DeleteTextField addTarget:self action:@selector(deleteText) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)textFieldWithText:(UITextField *)textField{
    NewDevName = textField.text;
    if (textField == cell.DevTextField) {
        if (textField.text.length > 10) {
            textField.text = [textField.text substringToIndex:10];
        }
    }

}

- (void)AlertMessage:(NSString*)message{
    //退出账户
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:NSLocalizedString(@"Tips", nil) message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    }];
    [alertView addAction:action];
    
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}
- (void)AlertMessage2:(NSString*)message{
    //退出账户
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:NSLocalizedString(@"Tips", nil) message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
    }];
    [alertView addAction:action];
    
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}

- (void)deleteText{
    cell.DevTextField.text = @"";
}

//点击空白处收回键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [cell.DevTextField resignFirstResponder];
}


@end




