//
//  TelephoneAlarmViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/9/12.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "TelephoneAlarmViewController.h"
#import "ScottAlertController.h"
#import "cqtekHeader.pch"
#import "DeviceAlarmSwitchViewController.h"
@interface TelephoneAlarmViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView* telephoneTable;
    NSUserDefaults* defaults;
    NSMutableArray* numberArray;
    NSMutableArray* checkedArray;
    
    
}

@end

@implementation TelephoneAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"电话报警";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    telephoneTable = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    telephoneTable.delegate = self;
    telephoneTable.dataSource = self;
    
    [self.view addSubview:telephoneTable];
    
}

- (void)viewWillAppear:(BOOL)animated{
    numberArray = [[DeviceAlarmSwitchViewController sharedInstance1]listArray];
    [telephoneTable reloadData];
//    Requset* request = [[Requset alloc]init];
//    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
//    [request setParameter:@"accessToken" value:@"CQY"];
//    [request setHeader:@"type" value:@"getAccountMobileList"];
//    [Requset Post:cqtek_test_api outTime:15
//          success:^(NSDictionary *data) {
//              if ([[data objectForKey:@"code"]intValue] == 0) {
//                  numberArray = [data objectForKey:@"mobileList"];
//                  [telephoneTable reloadData];
//              }
//          } failure:^(NSError *error) {
//              NSLog(@"网络问题，操作失败");
//          }];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return numberArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* adentifier = @"callcell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:adentifier];
 
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:adentifier];
        cell.textLabel.text = @"电话语音报警";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    cell.textLabel.text = numberArray[indexPath.row];
    return cell;
}

- (void)bindNumber{
    
}
- (void)AlertMessage:(NSString*)str{
    ScottAlertView *alert = [ScottAlertView alertViewWithTitle:@"提示" message:str];
    
    ScottAlertAction *tipsOK = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:tipsOK];
    [ScottShowAlertView showAlertViewWithView:alert backgroundDismissEnable:YES];
}



@end
