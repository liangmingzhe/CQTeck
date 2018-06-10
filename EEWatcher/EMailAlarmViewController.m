//
//  EMailAlarmViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/9/12.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "EMailAlarmViewController.h"
#import "cqtekHeader.pch"
#import "ScottAlertController/ScottAlertController.h"
@interface EMailAlarmViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView* mailTable;
    UISwitch* mailSwitch;
    NSUserDefaults* defaults;
}

@end

@implementation EMailAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"邮件报警";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    mailTable = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    mailTable.delegate = self;
    mailTable.dataSource = self;
    [self.view addSubview:mailTable];
}

- (void)viewWillAppear:(BOOL)animated{
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setParameter:@"channel" value:@"status_mail"];
    [request setHeader:@"type" value:@"getAlarmChannel"];
    [Request Post:cqtek_api outTime:15
          success:^(NSDictionary *data) {
              if ([[data objectForKey:@"code"]intValue] == 0) {
                  if ([[data objectForKey:@"alarmStatus"] isEqualToString:@"0"]) {
                      [mailSwitch setOn:NO];
                  }else{
                      [mailSwitch setOn:YES];
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
        cell.textLabel.text = @"邮件报警";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        mailSwitch = [[UISwitch alloc]init];
        [mailSwitch setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width - 50, cell.frame.size.height/2 + 5)];
        [mailSwitch addTarget:self action:@selector(switchHandle:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:mailSwitch];
        
    }
    return cell;
}

- (void)switchHandle:(id)sender{
    if (sender == mailSwitch) {
        
    }
}

- (void)AlertMessage:(NSString*)str{
    ScottAlertView *alert = [ScottAlertView alertViewWithTitle:@"提示" message:str];
    
    ScottAlertAction *tipsOK = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:tipsOK];
    [ScottShowAlertView showAlertViewWithView:alert backgroundDismissEnable:YES];
}

@end
