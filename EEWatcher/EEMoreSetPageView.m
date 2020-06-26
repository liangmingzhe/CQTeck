//
//  EEMoreSetPageView.m
//  EEWatcher
//
//  Created by 梁明哲 on 16/7/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "EEMoreSetPageView.h"
#import "EEMoreSetPageView.h"
#import "ScottAlertController.h"
#import "CustmerServiceView.h"
#import "AccountViewViewController.h"
#import "LmzFileTool.h"
#import "Request.h"
#import "cqtekHeader.pch"
#import "MoreItemCell.h"
#import "AlarmManagerViewController.h"
#import "ScottAlertView.h"
#import "Language.h"
//#import "ScottCustomAlertView.h"

@interface EEMoreSetPageView ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView* itemTable;
    NSUserDefaults* defaults;
    UILabel* money;
    NSTimer* refreshTheCatchesTimer;
    int authoflag;
}
@property (nonatomic,assign) int tapnum;

@end

@implementation EEMoreSetPageView

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/5)];
    view.backgroundColor = [UIColor colorWithRed:36/255.0 green:97/255.0 blue:160/255.0 alpha:1];
    [self.view addSubview:view];

    self.tapnum = 0;
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *iconBtn = [[UIImageView alloc]initWithFrame:CGRectMake(20, view.frame.size.height - view.frame.size.width/5 - 30, view.frame.size.width/5, view.frame.size.width/5)];
    iconBtn.image= [UIImage imageNamed:@"headIcon"]; //image = [UIImage imageNamed:@"headIcon"];
    iconBtn.backgroundColor = [UIColor whiteColor];
    iconBtn.layer.cornerRadius = view.frame.size.width/10;
    iconBtn.layer.borderWidth = 3;
    iconBtn.layer.borderColor = [UIColor colorWithRed:100.0/255.0 green:132.0/255.0 blue:201.0/255.0 alpha:1].CGColor;
    [view addSubview:iconBtn];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapIconHandle:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [iconBtn addGestureRecognizer:tapGestureRecognizer];
    iconBtn.userInteractionEnabled = YES;
    
    UILabel* user = [[UILabel alloc]initWithFrame:CGRectMake(iconBtn.frame.origin.x + iconBtn.frame.size.width + 10, iconBtn.frame.origin.y + iconBtn.frame.size.height/2 - 30, 300, 30)];
    user.textColor = [UIColor whiteColor];
    user.font = [UIFont fontWithName:@"Arial" size:22];
    user.text = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"Account"),[defaults objectForKey:@"cqUser"]];
    user.textAlignment = NSTextAlignmentLeft;
    [view addSubview:user];
    
    money = [[UILabel alloc]initWithFrame:CGRectMake(iconBtn.frame.origin.x + iconBtn.frame.size.width + 10, iconBtn.frame.origin.y + iconBtn.frame.size.height/2 + 10, 300, 30)];
    money.textColor = [UIColor whiteColor];
    money.font = [UIFont fontWithName:@"Arial" size:22];
    money.text = [NSString stringWithFormat:@"%@:",LocalizedString(@"Balance")];
    money.textAlignment = NSTextAlignmentLeft;
    [view addSubview:money];
    
    
    itemTable = [[UITableView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/5 + 6, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - view.frame.origin.y - view.frame.size.height - 10 - 49.5 + 4)];
    
    itemTable.backgroundColor = [UIColor whiteColor];
    itemTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//取消不显示的Cell
    itemTable.delegate = self;
    itemTable.dataSource = self;
    [self.view addSubview:itemTable];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    refreshTheCatchesTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        [itemTable reloadData];
    }];
    [refreshTheCatchesTimer fire];
    //隐藏导航条
    
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    
    [request setHeader:@"type" value:@"getAlarmAccountInfo"];
    [Request Post:cqtek_api outTime:15
          success:^(NSDictionary *data) {
              if ([[data objectForKey:@"code"]intValue] == 0) {
                  NSLog(@"%@",data);
                  //authoflag = 6 可以进入报警管理
                  authoflag = 6;
                  if ([data objectForKey:@"credit_money"] == nil) {
                      money.text = [NSString stringWithFormat:@"%@:0",LocalizedString(@"Balance")];
                  }else{
                      money.text = [NSString stringWithFormat:@"%@: %.2f 元",LocalizedString(@"Balance"),[[data objectForKey:@"credit_money"] floatValue] ];
                  }
              }else if([[data objectForKey:@"code"]intValue] == 1) {
                  //authoflag = 3 不允许进入报警管理
                  authoflag = 3;
              }else if([[data objectForKey:@"code"]intValue] == 2){
                  //没有填写手机号码
                  authoflag = 6;
              }
          } failure:^(NSError *error) {
              NSLog(@"网络问题，操作失败");
          }];
}



- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [refreshTheCatchesTimer invalidate];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* SeCell= @"MoreItemCell";
    MoreItemCell* cell = [tableView dequeueReusableCellWithIdentifier:SeCell];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MoreItemCell" owner:nil options:nil] lastObject];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:18];
        cell.itemImage.contentMode = UIViewContentModeScaleAspectFit;
        cell.detailText.text = @"";
        if (indexPath.row == 0){
            cell.itemImage.image = [UIImage imageNamed:@"main3alarm"];
            cell.cellNameLabel.text = LocalizedString(@"AlarmManager");
           
        }else if(indexPath.row == 1){
            cell.itemImage.image = [UIImage imageNamed:@"main3account"];
            cell.cellNameLabel.text = LocalizedString(@"Account");

        }
        else if(indexPath.row == 2){
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.itemImage.image = [UIImage imageNamed:@"main3account"];
            cell.cellNameLabel.text = LocalizedString(@"Caches");
            // 计算缓存
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject];
            
            
            [LmzFileTool getFileSize:cachePath completion:^(NSInteger totalSize) {
                NSLog(@"%lu",totalSize);
                NSString* String = [self cacheSizeStr:totalSize];
                
                cell.detailText.text = [NSString stringWithFormat:@"%@",String];
            }];
        }
    }
    return cell;
}

- (NSString *)cacheSizeStr:(NSInteger)totalSize {
    
    NSString *sizeStr;
    if (totalSize > 1000 * 1000) {
        float sizeF = totalSize / 1000.0 / 1000.0;
        sizeStr = [NSString stringWithFormat:@"%.1fMB", sizeF];
    } else if (totalSize > 1000) {
        float sizeF = totalSize / 1000.0;
        sizeStr = [NSString stringWithFormat:@"%.1fKB", sizeF];
    } else if (totalSize > 0) {
        sizeStr = [NSString stringWithFormat:@"%.ldB", totalSize];
    }else if(totalSize == 0){
        sizeStr = @"0dB";
    }
    return sizeStr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        //报警管理
        if (authoflag == 6) {
            AlarmManagerViewController* AlarmManager = [[AlarmManagerViewController alloc]init];
            [self.navigationController pushViewController:AlarmManager animated:YES];
        }else if(authoflag == 3){
            [self alertMessage:[NSString stringWithFormat:@"%@",LocalizedString(@"t_no_authority")]];
        }else{
            [self alertMessage:@"Error"];
        }
    }else if(indexPath.row == 1){
        AccountViewViewController* Account = [[AccountViewViewController alloc]init];
        [self.navigationController pushViewController:Account animated:YES];
    }else if(indexPath.row == 2){
//点击缓存
//        NSString *cachePath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject];
//        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
        [self alertMessage:@"是否清除缓存？"];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//清除缓存操作
- (void)alertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) lastObject];
        [LmzFileTool removeDirectoryPath:cachePath];
        
    }];
    ScottAlertAction *action2 = [ScottAlertAction actionWithTitle:LocalizedString(@"Cancel") style:ScottAlertActionStyleDestructive handler:nil];
    [alertView addAction:action];
    [alertView addAction:action2];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}

//切换测试环境
- (void)tapIconHandle:(id)sender {
    if (self.tapnum < 5) {
        self.tapnum++;
    }else if(self.tapnum >=5 && self.tapnum < 11){
        if(self.tapnum == 5){
            [GlobalParams switchHttpDomainToTest2501:YES];
            [ManNiuToastView showToast:@"切到测试环境" withDuration:2];
        }
        self.tapnum ++;
        
    }else {
        self.tapnum = 0;
        if(self.tapnum == 0){
            [GlobalParams switchHttpDomainToTest2501:NO];
            [ManNiuToastView showToast:@"切到正式环境" withDuration:2];

        }
    }
}
@end







