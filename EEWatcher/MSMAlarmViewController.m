//
//  MSMAlarmViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/10/13.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "MSMAlarmViewController.h"
#import "DeviceSetController.h"
#import "Request.h"
#import "cqtekHeader.pch"
#import "ScottAlertController.h"
#import "Language.h"
@interface MSMAlarmViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray* numberArray;
    UITableView* ItemTableView;
    NSUserDefaults* defaults;
    NSMutableArray* selectArray;
}

@end

@implementation MSMAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view.
    ItemTableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    ItemTableView.dataSource = self;
    ItemTableView.delegate = self;
    [self.view addSubview:ItemTableView];
    self.navigationItem.title = LocalizedString(@"l_device");
}

- (void)viewWillAppear:(BOOL)animated{
    numberArray = [[NSMutableArray alloc]initWithCapacity:0];
    numberArray = [[DeviceSetController sharedInstance2] listArray];

   [self getSelectDevice];
}
- (void)getSelectDevice{
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setParameter:@"accessToken" value:@"CQY"];
    [request setParameter:@"snaddr" value:[defaults objectForKey:@"snaddr"]];
    [request setHeader:@"type" value:@"getDeviceMobileList"];
    [Request Post:cqtek_api outTime:15
          success:^(NSDictionary *data) {
              if ([[data objectForKey:@"code"]intValue] == 0) {
                  NSLog(@"%@",data);
                  selectArray = [data objectForKey:@"deviceMobileList"];
                  [ItemTableView reloadData];
              }else if([[data objectForKey:@"code"]intValue] == 1){
                  
              }
          } failure:^(NSError *error) {
              NSLog(@"网络问题，操作失败");
          }];

}

- (void)testbind:(NSString*)mobile{
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setParameter:@"accessToken" value:@"CQY"];
    NSMutableArray* nsay = [[NSMutableArray alloc]initWithObjects:[defaults objectForKey:@"snaddr"], nil];
    NSMutableArray* devay = [[NSMutableArray alloc]initWithObjects:mobile, nil];
    [request setArrayParameter:@"snaddr" arrayValue:nsay];
    [request setArrayParameter:@"deviceMobileList" arrayValue:devay];

    [request setHeader:@"type" value:@"addMobileToDevice"];
    [Request Post:cqtek_api outTime:15
          success:^(NSDictionary *data) {
              if ([[data objectForKey:@"code"]intValue] == 0) {
                  NSLog(@"%@",data);
                  [self getSelectDevice];
              }
          } failure:^(NSError *error) {
              NSLog(@"网络问题，操作失败");
          }];
    
}
- (void)testDisBind:(NSString*)mobile{
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setParameter:@"accessToken" value:@"CQY"];
    NSMutableArray* nsay = [[NSMutableArray alloc]initWithObjects:[defaults objectForKey:@"snaddr"], nil];
    NSMutableArray* devay = [[NSMutableArray alloc]initWithObjects:mobile, nil];
    [request setArrayParameter:@"snaddr" arrayValue:nsay];
    [request setArrayParameter:@"deviceMobileList" arrayValue:devay];
    
    [request setHeader:@"type" value:@"delMobileToDevice"];
    [Request Post:cqtek_api outTime:15
          success:^(NSDictionary *data) {
              if ([[data objectForKey:@"code"]intValue] == 0) {
                  NSLog(@"%@",data);
                  [self getSelectDevice];
              }
          } failure:^(NSError *error) {
              NSLog(@"网络问题，操作失败");
          }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return numberArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* adentifier = @"msmcell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:adentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:adentifier];
        cell.textLabel.text = @"电话语音报警";
    }
    if ([selectArray containsObject:[NSString stringWithFormat:@"%@",numberArray[indexPath.row]]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = numberArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([selectArray containsObject:[NSString stringWithFormat:@"%@",numberArray[indexPath.row]]]) {
       
        [self alertMessage:[NSString stringWithFormat:@"是否解除与%@的绑定?",numberArray[indexPath.row]] mobile:[NSString stringWithFormat:@"%@",numberArray[indexPath.row]] type:0];
    }else{
        [self alertMessage:[NSString stringWithFormat:@"是否将设备与%@绑定?",numberArray[indexPath.row]] mobile:[NSString stringWithFormat:@"%@",numberArray[indexPath.row]] type:1];
    }
    
}

- (void)alertMessage:(NSString*)message mobile:(NSString*)mobile type:(bool)type{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *cancel = [ScottAlertAction actionWithTitle:LocalizedString(@"Cancel") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        
    }];

    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        if (type == 0) {
            [self testDisBind:mobile];
        }else{
            [self testbind:mobile];
        }
    }];
    [alertView addAction:action];
    [alertView addAction:cancel];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}
@end
