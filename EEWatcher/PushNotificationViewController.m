//
//  PushNotificationViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/9/12.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "PushNotificationViewController.h"
#import "Request.h"
#import "cqtekHeader.pch"
#import "ScottAlertController/ScottAlertController.h"
@interface PushNotificationViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView* pushTable;
    NSUserDefaults* defaults;
    UISwitch* pushSwitch;
}

@end

@implementation PushNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"App推送";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    pushTable = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    pushTable.delegate = self;
    pushTable.dataSource = self;
    
    [self.view addSubview:pushTable];

}

- (void)viewWillAppear:(BOOL)animated{
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setParameter:@"channel" value:@"status_push"];
    [request setHeader:@"type" value:@"getAlarmChannel"];
    [Request Post:cqtek_api outTime:15
          success:^(NSDictionary *data) {
              if ([[data objectForKey:@"code"]intValue] == 0) {
                  if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"0"]) {
                      [pushSwitch setOn:NO];
                  }else{
                      [pushSwitch setOn:YES];
                  }
                
              }else{
                  [self AlertMessage:@"操作失败"];
              }
          } failure:^(NSError *error) {
              NSLog(@"网络问题，操作失败");
          }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* adentifier = @"mailcell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:adentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:adentifier];
        cell.textLabel.text = @"App推送报警";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        pushSwitch = [[UISwitch alloc]init];
        [pushSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
        [pushSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:pushSwitch];

    }
    return cell;
}

- (void)switchHandle:(id)sender{
    if (sender == pushSwitch) {
        //推送开关
        Request* request = [[Request alloc]init];
        [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
        [request setParameter:@"channel" value:@"data_mail"];
        [request setHeader:@"type" value:@"switchAlarmChannel"];
        if ([pushSwitch isOn] == YES) {
            [request setParameter:@"alarmStatus" value:@"1"];
        }else{
            [request setParameter:@"alarmStatus" value:@"0"];
        }
        
        [Request Post:cqtek_api outTime:15
              success:^(NSDictionary *data) {
                  if ([[data objectForKey:@"code"]intValue] == 0) {
                      if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"0"]) {
                          [pushSwitch setOn:NO];
                          NSLog(@"close");
                          [self AlertMessage:@"App推送已关闭"];
                      }else{
                          [pushSwitch setOn:YES];
                          NSLog(@"open");
                          [self AlertMessage:@"App推送已打开"];
                      }
                      
                  }else{
                      [self AlertMessage:@"操作失败"];
                  }
              } failure:^(NSError *error) {
                  NSLog(@"网络问题，操作失败");
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
- (void)AlertMessage:(NSString*)str{
    ScottAlertView *alert = [ScottAlertView alertViewWithTitle:@"提示" message:str];
    
    ScottAlertAction *tipsOK = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    
    }];
    [alert addAction:tipsOK];
    [ScottShowAlertView showAlertViewWithView:alert backgroundDismissEnable:YES];
}

@end
