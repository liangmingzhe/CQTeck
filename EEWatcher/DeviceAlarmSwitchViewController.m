//
//  DeviceAlarmSwitchViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/10/10.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "DeviceAlarmSwitchViewController.h"
#import "TelephoneAlarmViewController.h"
#import "MSMAlarmViewController.h"
#import "Request.h"
#import "cqtekHeader.pch"

@interface DeviceAlarmSwitchViewController (){
    UITableView* itemTableView;
    NSUserDefaults* defaults;
}

@end

@implementation DeviceAlarmSwitchViewController
singleton_m(Instance1);
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaults = [NSUserDefaults standardUserDefaults];
    self.navigationItem.title = @"报警方式";
    self.view.backgroundColor = [UIColor whiteColor];
    itemTableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    itemTableView.dataSource = self;
    itemTableView.delegate = self;
    [self.view addSubview:itemTableView];
}
- (void)viewWillAppear:(BOOL)animated{
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setParameter:@"accessToken" value:@"CQY"];
    [request setParameter:@"snaddr" value:[defaults objectForKey:@"snaddr"]];
    [request setHeader:@"type" value:@"getAccountMobileList"];
    [Request Post:cqtek_api outTime:15
          success:^(NSDictionary *data) {
              if ([[data objectForKey:@"code"]intValue] == 0) {
                  _listArray = [data objectForKey:@"mobileList"];
                  
              }
          } failure:^(NSError *error) {
              NSLog(@"网络问题，操作失败");
          }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* str = @"divceAlarmCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"电话报警";
        }else{
            cell.textLabel.text = @"短信报警";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        TelephoneAlarmViewController* telephone = [[TelephoneAlarmViewController alloc]init];
        [self.navigationController pushViewController:telephone animated:YES];
    }else if(indexPath.row == 1){
        MSMAlarmViewController* msm = [[MSMAlarmViewController alloc]init];
        [self.navigationController pushViewController:msm animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
