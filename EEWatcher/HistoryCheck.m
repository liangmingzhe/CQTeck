//
//  HistoryCheck.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/2.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "HistoryCheck.h"
#import "AFNetworking.h"
#import "EEMainPageView.h"
#import "CQDataPicker.h"
#import "HistoryCell.h"
#import "ScottAlertController.h"
#import "HistoryErrlistView.h"
#import "MBProgressHUD.h"
#import "Language.h"

@interface HistoryCheck ()<UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource,CQDataPickerDelegate>{
    AFHTTPSessionManager *manager;
    NSUserDefaults* defaults;
    UITableView* timeTable;
    CQDataPicker* datePicker;
    int row;
    HistoryCell *cell;
    MBProgressHUD* mLoading;
    
}

@end

@implementation HistoryCheck
@synthesize teststring;
@synthesize endString;
singleton_m(InstanceFour);
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = [NSString stringWithFormat:@"%@",LocalizedString(@"l_history_alarm")];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    datePicker = [[CQDataPicker alloc]initWithFrame:CGRectZero];
    datePicker.delegate=self;

    //网络服务参数设置
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
    timeTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    timeTable.delegate = self;
    timeTable.dataSource = self;
    [self.view addSubview:timeTable];
    timeTable.scrollEnabled = NO;
//  时间选择器初始化
    datePicker = [[CQDataPicker alloc]initWithFrame:CGRectZero];
    datePicker.delegate = self;
//提示
    UILabel* tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 120, [UIScreen mainScreen].bounds.size.width - 10, 60)];
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.textColor = [UIColor lightGrayColor];
    tipsLabel.numberOfLines = 2;
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tipsLabel.text =[NSString stringWithFormat:@"%@:%@",LocalizedString(@"Tips"),LocalizedString(@"l_tips_history_alarm")];
    
    [self.view addSubview:tipsLabel];
//查询按键
    UIButton* checkBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/16, [UIScreen mainScreen].bounds.size.height/8*3, [UIScreen mainScreen].bounds.size.width/8*7, 50)];
    [checkBtn setTitle:LocalizedString(@"l_inquire") forState:UIControlStateNormal];
    checkBtn.titleLabel.font = [UIFont fontWithName:@"Arial" size:22];
    [checkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    checkBtn.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:95.0/255.0 blue:157.0/255.0 alpha:1];
    checkBtn.layer.cornerRadius = 3;
    checkBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    checkBtn.layer.shadowOffset = CGSizeMake(1,1);
    checkBtn.layer.shadowOpacity = 0.4;//阴影透明度，默认0
    checkBtn.layer.shadowRadius = 1;//阴影半径，默认3
    [self.view addSubview:checkBtn];
    [checkBtn addTarget:self action:@selector(requestHistoryError) forControlEvents:UIControlEventTouchUpInside];
    
    //初次进入本页面默认指定查询七天的历史数据
    NSDate *nowDate = [NSDate date];
    NSDate *beforeDate;
    beforeDate = [nowDate initWithTimeIntervalSinceNow:-60*60*24*7];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if (teststring == nil) {
        teststring = [formatter stringFromDate:beforeDate];
    }
    if (endString == nil) {
        endString = [formatter stringFromDate:nowDate];
    }
    //
    
    //

}

- (void)EndTimeCheck{
//    [datePicker showInView:self.view  animated:YES];

}
- (void)viewWillAppear:(BOOL)animated{
    [mLoading removeFromSuperview];
    
    //初次进入本页面默认指定查询七天的历史数据
    NSDate *nowDate = [NSDate date];
    NSDate *beforeDate;
    beforeDate = [nowDate initWithTimeIntervalSinceNow:-60*60*24*7];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    teststring = [formatter stringFromDate:beforeDate];
    endString = [formatter stringFromDate:nowDate];
    [timeTable reloadData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [mLoading removeFromSuperview];
}
- (void)requestHistoryError{
    if (teststring == nil | endString == nil) {
        //***************
        //***************
        //teststring 或 endString 未选择时处理方式
        //***************
        //***************
        [self AlertMessage:@"请先选择时间段"];
    }else{
        NSString*hourInterVal = [self intervalFromLastDate:teststring toTheDate:endString];
        NSLog(@"%@",hourInterVal);
        if ([hourInterVal intValue] > 24*7) {
            
            [self AlertMessage:@"查询的时间段长度最大为七天，请重新选择"];
        }else if([hourInterVal intValue]< 0){
         
            [self AlertMessage:@"开始时间不能晚于结束时间"];
        }else{
            mLoading = [[MBProgressHUD alloc]initWithView:self.view];
            mLoading.dimBackground = YES;
            mLoading.labelText = NSLocalizedString(@"l_loading", nil);
            [self.view addSubview:mLoading];
            [mLoading show:YES];

            defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *params = @{@"snaddr":[defaults objectForKey:@"snaddr" ],@"startTime":teststring,@"endTime":endString};
            manager.securityPolicy.allowInvalidCertificates = NO;
            [manager.requestSerializer setValue:@"getHistoryAlarm" forHTTPHeaderField:@"type"];
            [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                nil;
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"请求成功:%@", responseObject);
                NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                //将设备列表保存到_datatest中
                NSLog(@"%@",JSON);
                [mLoading removeFromSuperview];
                if([[JSON objectForKey:@"code"]intValue] == 0){
                    _historyArray = [JSON objectForKey:@"detail"];
                    _snaddr = [JSON objectForKey:@"snaddr"];
                    _devName = [JSON objectForKey:@"devName"];
                    _area = [JSON objectForKey:@"area"];
                    if (_historyArray.count == 0 |_historyArray == nil) {
                        [self AlertMessage:@"当前时间内没有报警记录"];
                    }else{
                        HistoryErrlistView* historyErrlistViewController = [[HistoryErrlistView alloc]init];
                        [self.navigationController pushViewController:historyErrlistViewController animated:YES];
                    }

                }else{
                    
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"请求失败:%@", error.description);
                //请求失败，关闭hud
                [mLoading removeFromSuperview];
                [self AlertMessage:@"请求超时，您的网络在开小差。"];
                //网络异常计数+1
            }];

        }

    }
}

- (NSString *)intervalFromLastDate: (NSString *) dateString1  toTheDate:(NSString *) dateString2
{
    NSArray *timeArray1=[dateString1 componentsSeparatedByString:@"."];
    dateString1=[timeArray1 objectAtIndex:0];
    NSArray *timeArray2=[dateString2 componentsSeparatedByString:@"."];
    dateString2=[timeArray2 objectAtIndex:0];
    NSLog(@"%@.....%@",dateString1,dateString2);
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d1=[date dateFromString:dateString1];
    
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    NSDate *d2=[date dateFromString:dateString2];
    
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    NSTimeInterval cha=late2-late1;
    NSString *timeString=@"";
    NSString *hour=@"";
    NSString *min=@"";
    NSString *sen=@"";
    
    
    
    sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    //        min = [min substringToIndex:min.length-7];
    //    秒
    sen=[NSString stringWithFormat:@"%@", sen];
    min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    //        min = [min substringToIndex:min.length-7];
    //    分
    min=[NSString stringWithFormat:@"%@", min];
    //    小时
    hour = [NSString stringWithFormat:@"%d", (int)cha/3600];
    //        house = [house substringToIndex:house.length-7];
    hour = [NSString stringWithFormat:@"%@", hour];
    timeString=[NSString stringWithFormat:@"%@",hour];

    return timeString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//tableview 相关---------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"HistoryCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (cell == nil)
    {
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row == 0) {
        cell.labelName.text = [NSString stringWithFormat:@"%@:",LocalizedString(@"l_start_time")];
        cell.labelValue.text = [teststring substringWithRange:NSMakeRange(0, 16)];
        
    }else if(indexPath.row == 1){
        cell.labelName.text = [NSString stringWithFormat:@"%@:",LocalizedString(@"l_end_time")];
        cell.labelValue.text = [endString substringWithRange:NSMakeRange(0, 16)];
    }
    NSLog(@"%ld",(long)indexPath.row);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//Cell点击后恢复未点击状态
    if (indexPath.row == 0) {
     //起始时间
        if (teststring == nil) {
            
        }else{
            [datePicker setSelectTime:[[teststring substringWithRange:NSMakeRange(0, 4)] intValue] month:[[teststring substringWithRange:NSMakeRange(5, 2)] intValue] day:[[teststring substringWithRange:NSMakeRange(8, 2)] intValue] hour:[[teststring substringWithRange:NSMakeRange(11, 2)] intValue] miniute:[[teststring substringWithRange:NSMakeRange(14, 2)] intValue] second:10 animated:YES];
        }
        [datePicker showInView:self.view animated:YES];
        row = 0;
    }else if(indexPath.row == 1){
    //结束时间
        if (endString == nil) {
            
        }else{
            [datePicker setSelectTime:[[endString substringWithRange:NSMakeRange(0, 4)] intValue] month:[[endString substringWithRange:NSMakeRange(5, 2)] intValue] day:[[endString substringWithRange:NSMakeRange(8, 2)] intValue] hour:[[endString substringWithRange:NSMakeRange(11, 2)] intValue] miniute:[[endString substringWithRange:NSMakeRange(14, 2)] intValue] second:10 animated:YES];
        }
        [datePicker showInView:self.view animated:YES];
        row = 1;
    }

}

//----------------------------------------
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 6;
}


- (void)daterViewDidClicked:(CQDataPicker *)daterView{
    if (row == 0) {
        teststring = [NSString stringWithFormat: @"%@ %@",datePicker.dateString,datePicker.timeString];
    }else if(row == 1){
        endString = [NSString stringWithFormat: @"%@ %@",datePicker.dateString,datePicker.timeString];
    }
    [timeTable reloadData];
}
- (void)daterViewDidCancel:(CQDataPicker *)daterView{
    
}
- (void)AlertMessage:(NSString*)message{
    //退出账户
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:NSLocalizedString(@"Tips", nil) message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        [defaults setObject:nil forKey:@"cqPass"];
        
    }];
    [alertView addAction:action];
    
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}


@end
