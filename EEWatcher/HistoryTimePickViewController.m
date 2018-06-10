//
//  HistoryTimePickViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/2/5.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "HistoryTimePickViewController.h"
#import "AFNetworking.h"
#import "EEMainPageView.h"
#import "CQDataPicker.h"
#import "HistoryDatePickCell.h"
#import "HistoryDataViewController.h"
#import "Language.h"
#import "ScottAlertController.h"
#import "MBProgressHUD.h"

@interface HistoryTimePickViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource,CQDataPickerDelegate>{
    AFHTTPSessionManager *manager;
    NSUserDefaults* defaults;
    UITableView* timeTable;
    CQDataPicker* datePicker;
    int row;
    HistoryDatePickCell *cell;
    MBProgressHUD* mLoading;
    UIButton* periodBtn;

}

@end

@implementation HistoryTimePickViewController
singleton_m(InstanceFive);
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = LocalizedString(@"l_history_data");//设备名
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
//时间选择器初始化
    datePicker = [[CQDataPicker alloc]initWithFrame:CGRectZero];
    datePicker.delegate = self;
    periodBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 120, [UIScreen mainScreen].bounds.size.width - 10, 30)];
    [periodBtn setTitleColor:[UIColor colorWithRed:81.0/255.0 green:105.0/255.0 blue:165.0/255.0 alpha:1] forState:UIControlStateNormal];
    [periodBtn setTitle:LocalizedString(@"t_please_choose_period") forState:UIControlStateNormal];
    
    [periodBtn addTarget:self action:@selector(selectPeriod) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:periodBtn];
//提示
    UILabel* tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 160, [UIScreen mainScreen].bounds.size.width - 10, 60)];
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.textColor = [UIColor lightGrayColor];
    tipsLabel.numberOfLines = 2;
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    
    tipsLabel.text = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"Tips"),LocalizedString(@"t_period_tips")];
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
    [checkBtn addTarget:self action:@selector(requestHistoryData) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated{
    [mLoading removeFromSuperview];
    //初次进入本页面默认指定查询七天的历史数据
    NSDate *nowDate = [NSDate date];
    NSDate *beforeDate;
    beforeDate = [nowDate initWithTimeIntervalSinceNow:-60*60*24*1];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    _teststring = [formatter stringFromDate:beforeDate];
    _endString = [formatter stringFromDate:nowDate];
    [timeTable reloadData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [mLoading removeFromSuperview];
}

- (void)requestHistoryData{
    if (_teststring == nil | _endString == nil) {
        //***************
        //***************
        //teststring 或 endString 未选择时处理方式
        //***************
        //***************
        [self AlertMessage:LocalizedString(@"t_choose_time")];
    }
    else{
        if (self.rangeTime == nil){
            [self AlertMessage:LocalizedString(@"t_please_choose_period")];
            
        }else{
            NSString*hourInterVal = [self intervalFromLastDate:_teststring toTheDate:_endString];
            NSLog(@"%@",hourInterVal);
            if ([hourInterVal intValue] > 24*7) {
                
                [self AlertMessage:[NSString stringWithFormat:@"%@",LocalizedString(@"t_period_tips")]];
            }else if([hourInterVal intValue]< 0){
                
                [self AlertMessage:LocalizedString(@"t_worm_history")];
            }else{
                mLoading = [[MBProgressHUD alloc]initWithView:self.view];
                mLoading.dimBackground = YES;
                mLoading.labelText = NSLocalizedString(@"l_loading", nil);
                [self.view addSubview:mLoading];
                [mLoading show:YES];
                
                defaults = [NSUserDefaults standardUserDefaults];
                //网络服务参数设置
                manager = [[AFHTTPSessionManager manager]init];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.requestSerializer.timeoutInterval = 15.0;
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
                NSDictionary *params =@{@"snaddr":[defaults objectForKey:@"snaddr" ],@"startTime":_teststring,@"endTime":_endString,@"rangeTime":self.rangeTime};
                
                manager.securityPolicy.allowInvalidCertificates = NO;
                [manager.requestSerializer setValue:@"getHisData" forHTTPHeaderField:@"type"];
                [manager POST:cqtek_api parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                    nil;
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSLog(@"请求成功:%@", responseObject);
                    NSMutableDictionary* JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    //将设备列表保存到_datatest中
                    [mLoading removeFromSuperview];
                    if([[JSON objectForKey:@"code"]intValue] == 0){
                        _historyDic = JSON;
                        HistoryDataViewController* historyDataViewController = [[HistoryDataViewController alloc]init];
                        [self.navigationController pushViewController:historyDataViewController animated:YES];
                    }else{
                        [self AlertMessage:[JSON objectForKey:@"msg"]];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [mLoading removeFromSuperview];
                }];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        cell = [[HistoryDatePickCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row == 0) {
        cell.labelName.text = [NSString stringWithFormat:@"%@:",LocalizedString(@"l_start_time")];
        cell.labelValue.text = [_teststring substringWithRange:NSMakeRange(0, 16)];
        
    }else if(indexPath.row == 1){
        cell.labelName.text = [NSString stringWithFormat:@"%@:",LocalizedString(@"l_end_time")];
        cell.labelValue.text = [_endString substringWithRange:NSMakeRange(0, 16)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//Cell点击后恢复未点击状态
    if (indexPath.row == 0) {
        //起始时间
        if (_teststring == nil) {
            
        }else{
            [datePicker setSelectTime:[[_teststring substringWithRange:NSMakeRange(0, 4)] intValue] month:[[_teststring substringWithRange:NSMakeRange(5, 2)] intValue] day:[[_teststring substringWithRange:NSMakeRange(8, 2)] intValue] hour:[[_teststring substringWithRange:NSMakeRange(11, 2)] intValue] miniute:[[_teststring substringWithRange:NSMakeRange(14, 2)] intValue] second:10 animated:YES];
        }
        [datePicker showInView:self.view animated:YES];
        row = 0;
    }else if(indexPath.row == 1){
        //结束时间
        if (_endString == nil) {
            
        }else{
            [datePicker setSelectTime:[[_endString substringWithRange:NSMakeRange(0, 4)] intValue] month:[[_endString substringWithRange:NSMakeRange(5, 2)] intValue] day:[[_endString substringWithRange:NSMakeRange(8, 2)] intValue] hour:[[_endString substringWithRange:NSMakeRange(11, 2)] intValue] miniute:[[_endString substringWithRange:NSMakeRange(14, 2)] intValue] second:10 animated:YES];
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
        _teststring = [NSString stringWithFormat: @"%@ %@",datePicker.dateString,datePicker.timeString];
    }else if(row == 1){
        _endString = [NSString stringWithFormat: @"%@ %@",datePicker.dateString,datePicker.timeString];
    }
    [timeTable reloadData];
}
- (void)daterViewDidCancel:(CQDataPicker *)daterView{
    
}

- (void)AlertMessage:(NSString*)message{
    //退出账户
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        [defaults setObject:nil forKey:@"cqPass"];
        
    }];
    [alertView addAction:action];
    
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}

- (void)selectPeriod{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"l_interval") message:@""];
//    UIButton* OneMinute = [[UIButton alloc]initWithFrame:CGRectMake(5,alertView.frame.size.height/2, 60, 30)];
//    [OneMinute setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [OneMinute setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
//    [OneMinute setTitle:@"1分钟" forState:UIControlStateNormal];
//    [alertView addSubview:OneMinute];
    
    ScottAlertAction *action1 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"1%@",LocalizedString(@"l_minute")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        self.rangeTime = @"1";
        [periodBtn setTitle:[NSString stringWithFormat:@"%@:1%@",LocalizedString(@"l_interval"),LocalizedString(@"l_minute")] forState:UIControlStateNormal];
    }];
    [alertView addAction:action1];
    
    ScottAlertAction *action2 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"5%@",LocalizedString(@"l_minute")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        self.rangeTime = @"5";
        [periodBtn setTitle:[NSString stringWithFormat:@"%@:5%@",LocalizedString(@"l_interval"),LocalizedString(@"l_minute")] forState:UIControlStateNormal];
    }];
    [alertView addAction:action2];
    
    ScottAlertAction *action3 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"10%@",LocalizedString(@"l_minute")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        self.rangeTime = @"10";
                [periodBtn setTitle:[NSString stringWithFormat:@"%@:10%@",LocalizedString(@"l_interval"),LocalizedString(@"l_minute")] forState:UIControlStateNormal];
    }];
    [alertView addAction:action3];

    ScottAlertAction *action4 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"1%@",LocalizedString(@"l_hour")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        self.rangeTime = @"60";
                [periodBtn setTitle:[NSString stringWithFormat:@"%@:1%@",LocalizedString(@"l_interval"),LocalizedString(@"l_hour")] forState:UIControlStateNormal];
    }];
    [alertView addAction:action4];
    ScottAlertAction *action5 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"2%@",LocalizedString(@"l_hour")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        self.rangeTime = @"120";
                [periodBtn setTitle:[NSString stringWithFormat:@"%@:2%@",LocalizedString(@"l_interval"),LocalizedString(@"l_hour")] forState:UIControlStateNormal];
    }];
    [alertView addAction:action5];
    ScottAlertAction *action6 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"6%@",LocalizedString(@"l_hour")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        self.rangeTime = @"360";
        [periodBtn setTitle:[NSString stringWithFormat:@"%@:6%@",LocalizedString(@"l_interval"),LocalizedString(@"l_hour")] forState:UIControlStateNormal];
    }];
    [alertView addAction:action6];

    ScottAlertAction *action7 = [ScottAlertAction actionWithTitle:[NSString stringWithFormat:@"12%@",LocalizedString(@"l_hour")] style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        self.rangeTime = @"720";
        [periodBtn setTitle:[NSString stringWithFormat:@"%@:12%@",LocalizedString(@"l_interval"),LocalizedString(@"l_hour")] forState:UIControlStateNormal];
    }];
    [alertView addAction:action7];

    
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
}
@end
