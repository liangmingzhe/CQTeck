//
//  AlarmManagerViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/9/11.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "AlarmManagerViewController.h"
#import "cqtekHeader.pch"
#import "PhoneViewController.h"
#import "MoreItemCell.h"
#import "ScottAlertController/ScottAlertController.h"
#import "Request.h"
#import "MBProgressHUD.h"
#import "Language.h"
@interface AlarmManagerViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView* table1;
    UISwitch* allSwitch;
    //离线报警开关
    UISwitch* msmStateSwitch;
    UISwitch* pushStateSwitch;
    UISwitch* mailStateSwitch;
    UISwitch* callStateSwitch;
    //数据报警开关
    UISwitch* msmDataSwitch;
    UISwitch* pushDataSwitch;
    UISwitch* mailDataSwitch;
    UISwitch* callDataSwitch;
    
    NSUserDefaults* defaults;
}

@end

@implementation AlarmManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.title = LocalizedString(@"AlarmManager");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    
    table1 = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height- 55) style:UITableViewStyleGrouped];
    table1.delegate = self;
    table1.dataSource = self;
//    table.scrollEnabled = NO;
    [self.view addSubview:table1];

}

- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setHeader:@"type" value:@"getAllAlarmStatus"];
    [Request Post:cqtek_api outTime:15
          success:^(NSDictionary *data) {
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              if([[data objectForKey:@"code"] intValue] == 0){
                  
                  if ([[data objectForKey:@"allAlarmStatus"]intValue] == 0){
             
                      [allSwitch setOn:NO];
                      [defaults setObject:@"NO" forKey:@"alarmSwitch"];
                      [defaults synchronize];
                  }else {
                      [defaults setObject:@"YES" forKey:@"alarmSwitch"];
                      [allSwitch setOn:YES];
                      if([[data objectForKey:@"alarmChannel"] count] > 0){
                          NSArray *array =  [data objectForKey:@"alarmChannel"];
                          if ([array containsObject:@"data_push"]) {
//                              [pushDataSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"dataPushFlag"];
                          }else{
//                              [pushDataSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"dataPushFlag"];
                          }
                          
                          if ([array containsObject:@"state_push"]) {
                              [defaults setObject:@"1" forKey:@"statePushFlag"];
//                              [pushStateSwitch setOn:YES];
                          }else{
//                              [pushStateSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"statePushFlag"];
                          }

                          if ([array containsObject:@"data_msm"]) {
//                              [msmDataSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"dataMSMFlag"];
                          }else{
                              [defaults setObject:@"0" forKey:@"dataMSMFlag"];
                          }
                          if ([array containsObject:@"state_msm"]) {
                              [defaults setObject:@"1" forKey:@"stateMSMFlag"];
                          }else{
                              [defaults setObject:@"0" forKey:@"stateMSMFlag"];
                          }


                          if ([array containsObject:@"data_call"]) {
//                              [callDataSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"dataCallFlag"];
                          }else{
//                              [callDataSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"dataCallFlag"];
                          }
                          if ([array containsObject:@"state_call"]) {
//                             [callStateSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"stateCallFlag"];
                          }else{
                             [callStateSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"stateCallFlag"];
                          }
                          if ([array containsObject:@"data_mail"]) {
//                             [mailDataSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"dataMailFlag"];
                          }else{
                             [mailDataSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"dataMailFlag"];
                          }
                          
                          if ([array containsObject:@"state_mail"]) {
//                             [mailStateSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"stateMailFlag"];
                          }else{
//                             [mailStateSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"stateMailFlag"];
                          }
                          
                          [table1 reloadData];
                      }
                  }
              }
              [table1 reloadData];
          } failure:^(NSError *error) {
              NSLog(@"");
              [MBProgressHUD hideHUDForView:self.view animated:YES];
          }];

    NSIndexSet *set = [NSIndexSet indexSetWithIndex:1];
    [table1 reloadSections:set withRowAnimation:UITableViewRowAnimationFade];

}
- (void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//UISwitch
-(void)switchHandle:(id)sender{
    //开关操作处理事件根据不同按键执行不同操作
     Request* request = [[Request alloc]init];
    NSString* str = [defaults objectForKey:@"cqUser"];
    [request setParameter:@"user" value:str];

    //控制报警总开关
    if (sender == allSwitch){
        
        [request setHeader:@"type" value:@"switchAllAlarm"];
        
        if ([allSwitch isOn] == true) {
            //        如果总开关经过操作后的状态是开
            [request setParameter:@"allAlarmStatus" value:@"1"];
        }else{
            [request setParameter:@"allAlarmStatus" value:@"0"];
        }
        MBProgressHUD* hud = [[MBProgressHUD alloc]init];
        [hud show:YES];

        
        [Request Post:cqtek_api outTime:15
              success:^(NSDictionary *data) {
                  [hud hide:YES];
                  if ([[data objectForKey:@"code"] intValue] == 0){
                      if ([[data objectForKey:@"allAlarmStatus"] isEqualToString:@"0"]) {
                          [allSwitch setOn:NO];
                          [defaults setObject:@"NO" forKey:@"alarmSwitch"]; // table1设立标识位用于识别
                          NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
                          [table1 beginUpdates];
                          NSLog(@"%ld",table1.numberOfSections);
                          
                          [table1 deleteSections:set withRowAnimation:UITableViewRowAnimationNone];
                          [table1 endUpdates];
                          [table1 reloadData];
                          [self alertMessage:@"总开关已关闭"];
                      }else{
                          [allSwitch setOn:YES];
                          [defaults setObject:@"YES" forKey:@"alarmSwitch"];
                          NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
                          [table1 beginUpdates];
                          [table1 insertSections:set withRowAnimation:UITableViewRowAnimationFade];
                          [table1 endUpdates];
                          [self alertMessage:@"总开关已打开"];
                      }
                  }else {
                      if ([allSwitch isOn] == YES) {
                          [allSwitch setOn:NO];
                      }else{
                          [allSwitch setOn:YES];
                      }
                  }
              } failure:^(NSError *error) {
                  NSLog(@"");
                  dispatch_async(dispatch_get_main_queue(), ^{
                      
                      //打印当前线程
                      [hud hide:YES];
                      if ([allSwitch isOn] == YES) {
                          [allSwitch setOn:NO];
                      }else{
                          [allSwitch setOn:YES];
                      }

                  });
              }];
        
    }else{
//        除总开关外其他报警开关
        [request setHeader:@"type" value:@"switchAlarmChannel"];
        
        if(sender == pushDataSwitch){
            //通道为数据App推送
            [request setParameter:@"channel" value:@"data_push"];
            if ([pushDataSwitch isOn] == YES) {
                [request setParameter:@"alarmStatus" value:@"1"];
            }else {
                [request setParameter:@"alarmStatus" value:@"0"];
            }
            [Request Post:cqtek_api outTime:15
                  success:^(NSDictionary *data) {
                      
                      if ([[data objectForKey:@"code"]intValue] == 0) {
                          NSLog(@"");
                          if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"1"]) {
                              [pushDataSwitch setOn:YES];
                           
                              NSLog(@"open");
                              [defaults setObject:@"1" forKey:@"dataPushFlag"];
                          }else{
                              [pushDataSwitch setOn:NO];
                           
                              NSLog(@"close");
                              [defaults setObject:@"0" forKey:@"dataPushFlag"];
                              
                          }
                      }else {
                          if ([pushDataSwitch isOn] == YES) {
                              [pushDataSwitch setOn:NO];
                          }else{
                              [pushDataSwitch setOn:YES];
                          }
                      }
                      
                  } failure:^(NSError *error) {
                      if ([pushDataSwitch isOn] == YES) {
                          [pushDataSwitch setOn:NO];
                      }else{
                          [pushDataSwitch setOn:YES];
                      }
              
                      
                  }];

        }else if(sender == pushStateSwitch){
            //通道为离线App推送
            [request setParameter:@"channel" value:@"state_push"];
            if ([pushStateSwitch isOn] == YES) {
                [request setParameter:@"alarmStatus" value:@"1"];
            }else {
                [request setParameter:@"alarmStatus" value:@"0"];
            }
            [Request Post:cqtek_api outTime:15
                  success:^(NSDictionary *data) {
                      
                      if ([[data objectForKey:@"code"]intValue] == 0) {
                          NSLog(@"");
                          if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"1"]) {
                              [pushStateSwitch setOn:YES];
                              
                              NSLog(@"open");
                              [defaults setObject:@"1" forKey:@"statePushFlag"];
                              
                          }else{
                              [pushStateSwitch setOn:NO];
                              
                              NSLog(@"close");
                              [defaults setObject:@"0" forKey:@"statePushFlag"];
                              
                          }
                      }else{
                          if ([pushStateSwitch isOn] == YES) {
                              [pushStateSwitch setOn:NO];
                          }else{
                              [pushStateSwitch setOn:YES];
                          }
                      }
                      
                  } failure:^(NSError *error) {
                      if ([pushStateSwitch isOn] == YES) {
                          [pushStateSwitch setOn:NO];
                      }else{
                          [pushStateSwitch setOn:YES];
                      }
                  }];

        }else if(sender == mailDataSwitch){

            //通道为数据邮件报警开关
            [request setParameter:@"channel" value:@"data_mail"];
            if ([mailDataSwitch isOn] == YES) {
                [request setParameter:@"alarmStatus" value:@"1"];
            }else {
                [request setParameter:@"alarmStatus" value:@"0"];
            }
            [Request Post:cqtek_api outTime:15
                  success:^(NSDictionary *data) {
                      
                      if ([[data objectForKey:@"code"]intValue] == 0) {
                          NSLog(@"");
                          if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"1"]) {
                              [mailDataSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"dataMailFlag"];
                              NSLog(@"open");
                          }else{
                              [mailDataSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"dataMailFlag"];
                              NSLog(@"close");
                              
                          }
                      }else{
                          if ([pushStateSwitch isOn] == YES) {
                              [pushStateSwitch setOn:NO];
                          }else{
                              [pushStateSwitch setOn:YES];
                          }
                      }
                      
                  } failure:^(NSError *error) {
                      NSLog(@"网络问题，操作失败");
                      if ([pushStateSwitch isOn] == YES) {
                          [pushStateSwitch setOn:NO];
                      }else{
                          [pushStateSwitch setOn:YES];
                      }

                  }];
        }else if(sender == mailStateSwitch){

            //通道为离线邮件报警开关
            [request setParameter:@"channel" value:@"state_mail"];
            if ([mailStateSwitch isOn] == YES) {
                [request setParameter:@"alarmStatus" value:@"1"];
            }else {
                [request setParameter:@"alarmStatus" value:@"0"];
            }
            [Request Post:cqtek_api outTime:15
                  success:^(NSDictionary *data) {
                      
                      if ([[data objectForKey:@"code"]intValue] == 0) {
                          NSLog(@"");
                          if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"1"]) {
                              [mailStateSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"stateMailFlag"];
                              NSLog(@"open");
                          }else{
                              [mailStateSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"stateMailFlag"];
                              NSLog(@"close");
                              
                          }
                      }else{
                          if ([mailStateSwitch isOn] == YES) {
                              [mailStateSwitch setOn:NO];
                          }else{
                              [mailStateSwitch setOn:YES];
                          }

                      }
                      
                  } failure:^(NSError *error) {
                      NSLog(@"网络问题，操作失败");
                      if ([mailStateSwitch isOn] == YES) {
                          [mailStateSwitch setOn:NO];
                      }else{
                          [mailStateSwitch setOn:YES];
                      }

                  }];
        }else if(sender == msmDataSwitch){
            //通道为数据短信报警开关
            [request setParameter:@"channel" value:@"data_msm"];
            if ([msmDataSwitch isOn] == YES) {
                [request setParameter:@"alarmStatus" value:@"1"];
            }else {
                [request setParameter:@"alarmStatus" value:@"0"];
            }
            [Request Post:cqtek_api outTime:15
                  success:^(NSDictionary *data) {
                      
                      if ([[data objectForKey:@"code"]intValue] == 0) {
                          NSLog(@"");
                          if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"1"]) {
                              [msmDataSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"dataMSMFlag"];
                              NSLog(@"open");
                          }else{
                              [msmDataSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"dataMSMFlag"];
                              NSLog(@"close");
                              
                          }
                      }else{
                          if ([msmDataSwitch isOn] == YES) {
                              [msmDataSwitch setOn:NO];
                          }else{
                              [msmDataSwitch setOn:YES];
                          }

                      }
                      
                  } failure:^(NSError *error) {
                      NSLog(@"网络问题，操作失败");
                      if ([msmDataSwitch isOn] == YES) {
                          [msmDataSwitch setOn:NO];
                      }else{
                          [msmDataSwitch setOn:YES];
                      }

                  }];
        }else if(sender == msmStateSwitch){
            
            //通道为离线短信报警开关
            [request setParameter:@"channel" value:@"state_msm"];
            if ([msmStateSwitch isOn] == YES) {
                [request setParameter:@"alarmStatus" value:@"1"];
            }else {
                [request setParameter:@"alarmStatus" value:@"0"];
            }
            [Request Post:cqtek_api outTime:15
                  success:^(NSDictionary *data) {
                      
                      if ([[data objectForKey:@"code"]intValue] == 0) {
                          NSLog(@"");
                          if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"1"]) {
                              [msmStateSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"stateMSMFlag"];
                              NSLog(@"open");
                          }else{
                              [msmStateSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"stateMSMFlag"];
                              NSLog(@"close");
                              
                          }
                      }else{
                          if ([msmStateSwitch isOn] == YES) {
                              [msmStateSwitch setOn:NO];
                          }else{
                              [msmStateSwitch setOn:YES];
                          }
                      }
                      
                  } failure:^(NSError *error) {
                      NSLog(@"网络问题，操作失败");
                      if ([msmStateSwitch isOn] == YES) {
                          [msmStateSwitch setOn:NO];
                      }else{
                          [msmStateSwitch setOn:YES];
                      }
                  }];
        }else if(sender == callDataSwitch){
            //通道为数据语音报警开关
            [request setParameter:@"channel" value:@"data_call"];
            if ([callDataSwitch isOn] == YES) {
                [request setParameter:@"alarmStatus" value:@"1"];
            }else {
                [request setParameter:@"alarmStatus" value:@"0"];
            }
            [Request Post:cqtek_api outTime:15
                  success:^(NSDictionary *data) {
                      
                      if ([[data objectForKey:@"code"]intValue] == 0) {
                          NSLog(@"");
                          if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"1"]) {
                              [callDataSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"dataCallFlag"];
                              NSLog(@"open");
                          }else{
                              [callDataSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"dataCallFlag"];
                              NSLog(@"close");
                              
                          }
                      }else{
                          if ([callDataSwitch isOn] == YES) {
                              [callDataSwitch setOn:NO];
                          }else{
                              [callDataSwitch setOn:YES];
                          }
                      }
                      
                  } failure:^(NSError *error) {
                      NSLog(@"网络问题，操作失败");
                      if ([callDataSwitch isOn] == YES) {
                          [callDataSwitch setOn:NO];
                      }else{
                          [callDataSwitch setOn:YES];
                      }
                  }];
        }else if(sender == callStateSwitch){
            
            //通道为离线语音报警开关
            [request setParameter:@"channel" value:@"state_call"];
            if ([callStateSwitch isOn] == YES) {
                [request setParameter:@"alarmStatus" value:@"1"];
            }else {
                [request setParameter:@"alarmStatus" value:@"0"];
            }
            [Request Post:cqtek_api outTime:15
                  success:^(NSDictionary *data) {
                      
                      if ([[data objectForKey:@"code"]intValue] == 0) {
                          NSLog(@"");
                          if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"1"]) {
                              [callStateSwitch setOn:YES];
                              [defaults setObject:@"1" forKey:@"stateCallFlag"];
                              NSLog(@"open");
                          }else{
                              [callStateSwitch setOn:NO];
                              [defaults setObject:@"0" forKey:@"stateCallFlag"];
                              NSLog(@"close");
                              
                          }
                      }else{
                          if ([callStateSwitch isOn] == YES) {
                              [callStateSwitch setOn:NO];
                          }else{
                              [callStateSwitch setOn:YES];
                          }
                      }
                      
                  } failure:^(NSError *error) {
                      NSLog(@"网络问题，操作失败");
                      if ([callStateSwitch isOn] == YES) {
                          [callStateSwitch setOn:NO];
                      }else{
                          [callStateSwitch setOn:YES];
                      }

                  }];
        }
    }
//    Requset
}




//-----tableView----
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    else if(section == 1){
        return 1;
    }else if(section == 2){
        return 4;
    }else if(section == 3){
        return 4;
    }
    else{
        return 0;
    }
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section  == 0){
        return @"";
    }else if(section == 1){
        return LocalizedString(@"l_AllSwitch");
    }else if(section == 2){
        return LocalizedString(@"l_data_exception");
    }else if(section == 3){
        return LocalizedString(@"l_offLine");
    }
    else{
        return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([[defaults objectForKey:@"alarmSwitch"] isEqualToString:@"YES"]){
        return 4;
    }else{
        return 2;
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* SeCell= @"MoreItemCell";
    MoreItemCell* cell = [tableView dequeueReusableCellWithIdentifier:SeCell];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MoreItemCell" owner:nil options:nil] lastObject];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:18];
        cell.itemImage.contentMode = UIViewContentModeScaleAspectFit;
        
//section = 0
        if (indexPath.section == 0) {
            if(indexPath.row == 0){
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.itemImage.image = [UIImage imageNamed:@"main3phone"];
                cell.cellNameLabel.text = LocalizedString(@"l_mobileList");
                cell.detailText.text = @"";
            }
        }else if (indexPath.section == 1){
            if (indexPath.row == 0) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.itemImage.image = [UIImage imageNamed:@"main3account"];
                cell.cellNameLabel.text = LocalizedString(@"l_AllSwitch");
                cell.detailText.text = @"";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                //                allSwitch = [[UISwitch alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, cell.frame.size.height/2 - 10, 40, 30)];
                allSwitch = [[UISwitch alloc]init];
                [allSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
                [allSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:allSwitch];
            }
        }else if(indexPath.section == 2){
            if (indexPath.row == 0) {
                cell.cellNameLabel.text = LocalizedString(@"l_SMS");
                cell.itemImage.image = [UIImage imageNamed:@"main3msm"];
                cell.detailText.text = @"";
                msmDataSwitch = [[UISwitch alloc]init];
                [msmDataSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
                [msmDataSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:msmDataSwitch];
            }else if(indexPath.row == 1){
                cell.cellNameLabel.text = LocalizedString(@"l_CALL");
                cell.cellNameLabel.textColor = [UIColor grayColor];
                cell.itemImage.image = [UIImage imageNamed:@"main3callalarm"];
                cell.detailText.text = @"";
                callDataSwitch = [[UISwitch alloc]init];
                [callDataSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
                [callDataSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:callDataSwitch];
                
            }else if(indexPath.row == 2){
                cell.cellNameLabel.text = LocalizedString(@"l_notification");
                cell.itemImage.image = [UIImage imageNamed:@"main3push"];
                pushDataSwitch = [[UISwitch alloc]init];
                [pushDataSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
                [pushDataSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:pushDataSwitch];
                cell.detailText.text = @"";
            }else if(indexPath.row == 3){
                cell.cellNameLabel.text = LocalizedString(@"l_mailalarm");
                cell.itemImage.image = [UIImage imageNamed:@"main3mailbox"];
                cell.detailText.text = @"";
                mailDataSwitch = [[UISwitch alloc]init];
                [mailDataSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
                [mailDataSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:mailDataSwitch];
            }
        }else if(indexPath.section == 3){
            if (indexPath.row == 0) {
                cell.cellNameLabel.text = LocalizedString(@"l_SMS");
                cell.itemImage.image = [UIImage imageNamed:@"main3msm"];
                cell.detailText.text = @"";
                msmStateSwitch = [[UISwitch alloc]init];
                [msmStateSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
                [msmStateSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:msmStateSwitch];
            }else if(indexPath.row == 1){
                cell.cellNameLabel.text = LocalizedString(@"l_CALL");
                cell.cellNameLabel.textColor = [UIColor grayColor];
                cell.itemImage.image = [UIImage imageNamed:@"main3callalarm"];
                cell.detailText.text = @"";
                callStateSwitch = [[UISwitch alloc]init];
                [callStateSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
                [callStateSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:callStateSwitch];
            }else if(indexPath.row == 2){
                cell.cellNameLabel.text = LocalizedString(@"l_notification");
                cell.itemImage.image = [UIImage imageNamed:@"main3push"];
                
                cell.detailText.text = @"";
                pushStateSwitch = [[UISwitch alloc]init];
                [pushStateSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
                [pushStateSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:pushStateSwitch];
                

            }else if(indexPath.row == 3){
                cell.cellNameLabel.text = LocalizedString(@"l_mailalarm");
                cell.itemImage.image = [UIImage imageNamed:@"main3mailbox"];
                cell.detailText.text = @"";
                mailStateSwitch = [[UISwitch alloc]init];
                [mailStateSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
                [mailStateSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:mailStateSwitch];
            }
        }
    }
    if ([[defaults objectForKey:@"alarmSwitch"] isEqualToString:@"NO"]){
        [allSwitch setOn:NO];
    }else{
        [allSwitch setOn:YES];
        if ([[defaults objectForKey:@"dataPushFlag"] isEqualToString:@"0"]){
            [pushDataSwitch setOn:NO];
        }else{
            [pushDataSwitch setOn:YES];
        }
        if ([[defaults objectForKey:@"statePushFlag"] isEqualToString:@"0"]){
            [pushStateSwitch setOn:NO];
        }else{
            [pushStateSwitch setOn:YES];
        }
        if ([[defaults objectForKey:@"dataCallFlag"] isEqualToString:@"0"]){
            [callDataSwitch setOn:NO];
        }else{
            [callDataSwitch setOn:YES];
        }
        if ([[defaults objectForKey:@"stateCallFlag"] isEqualToString:@"0"]){
            [callStateSwitch setOn:NO];
        }else{
            [callStateSwitch setOn:YES];
        }
        if ([[defaults objectForKey:@"dataMailFlag"] isEqualToString:@"0"]){
            [mailDataSwitch setOn:NO];
        }else{
            [mailDataSwitch setOn:YES];
        }
        if ([[defaults objectForKey:@"stateMailFlag"] isEqualToString:@"0"]){
            [mailStateSwitch setOn:NO];
        }else{
            [mailStateSwitch setOn:YES];
        }
        
        if ([[defaults objectForKey:@"dataMSMFlag"] isEqualToString:@"0"]){
            [msmDataSwitch setOn:NO];
        }else{
            [msmDataSwitch setOn:YES];
        }
        
        if ([[defaults objectForKey:@"stateMSMFlag"] isEqualToString:@"0"]){
            [msmStateSwitch setOn:NO];
        }else{
            [msmStateSwitch setOn:YES];
        }

    }
    


    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        PhoneViewController* numberManager = [[PhoneViewController alloc]init];
        [self.navigationController pushViewController:numberManager animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)alertMessage:(NSString*)str{
    ScottAlertView *alert = [ScottAlertView alertViewWithTitle:@"提示" message:str];
    
    ScottAlertAction *tipsOK = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    }];
    [alert addAction:tipsOK];
    [ScottShowAlertView showAlertViewWithView:alert backgroundDismissEnable:YES];
}




@end
