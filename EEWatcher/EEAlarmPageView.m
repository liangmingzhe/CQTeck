//
//  EEAlarmPageView.m
//  EEWatcher
//
//  Created by 梁明哲 on 16/7/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "EEAlarmPageView.h"
#import "ScottAlertController.h"
#import "RTAlarmCell.h"
#import "MBProgressHUD.h"
#import "Request.h"
#import "Language.h"

@interface EEAlarmPageView (){
    UITableView* AlarmTableView;
    UILabel* updateTime;//显示更新时间
    NSTimer* timer;
    NSUserDefaults* defaults;
    NSMutableArray* allListArray;//本次获取的所有设备的分组
    NSMutableArray* subDetial;//某个设备下所有的报警信息；
    UILabel* tips;
    UIButton* freshButton;
    
}

@end

@implementation EEAlarmPageView
singleton_m(InstanceAlarm);

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = LocalizedString(@"l_alarm");
    //标题字体设置
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    allListArray = [NSMutableArray arrayWithCapacity:0];
//    tips = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, [UIScreen mainScreen].bounds.size.width - 30, 25)];
//    tips.text = LocalizedString(@"t_display_alarm");
//    tips.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:tips];
    
    UIButton* del = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 30, 5, 20, 20)];
    [del setImage:[UIImage imageNamed:@"main2deleteblack"] forState:UIControlStateNormal];
    [self.view addSubview:del];
    [del addTarget:self action:@selector(removeTips) forControlEvents:UIControlEventTouchUpInside];
   
    [self AlarmTableView];
    freshButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [freshButton setImage:[UIImage imageNamed:@"alarm_fresh"] forState:normal];
    UIView* btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btnView addSubview:freshButton];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:btnView];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [freshButton addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    
    //网络服务参数设置

    timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getErrList) userInfo:nil repeats:NO];
//    [self alertMessage:@"只能查询到最近24小时内的报警信息"];
}

- (UITableView*)AlarmTableView{
    AlarmTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 105.5) style:UITableViewStylePlain];
    AlarmTableView.delegate = self;
    AlarmTableView.dataSource = self;
    AlarmTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:AlarmTableView];
    return AlarmTableView;
}

//------------刷新数据---------------
- (void)refreshData{
    [freshButton setEnabled:false];
    //  加一个hud 数据刷新后hud移除
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //--
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setHeader:@"type" value:@"getUnresolvedError"];
    [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[data objectForKey:@"code"]intValue] == 0) {
            subDetial = [data objectForKey:@"array"];
            [freshButton setEnabled:true];
            [AlarmTableView reloadData];
     
        }else{
            //请求失败
            [freshButton setEnabled:true];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [freshButton setEnabled:true];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [timer fire];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self refreshData];

}

//移除提示
- (void)removeTips{
//    [tips removeFromSuperview];
    [AlarmTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 115)];
}
- (void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
}


- (void)getErrList{
    defaults = [NSUserDefaults standardUserDefaults];
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setHeader:@"type" value:@"getUnresolvedError"];
    [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
        if ([[data objectForKey:@"code"] intValue] == 0) {
            subDetial = [data objectForKey:@"array"];
            
        }else{
        
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    
//    return allListArray.count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return subDetial.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     static NSString *NODE_CELL_ID = @"RTAlarmCell";
    
    RTAlarmCell* cell = [tableView dequeueReusableCellWithIdentifier:NODE_CELL_ID];
    
    
    if (cell == nil) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [[[NSBundle mainBundle] loadNibNamed:NODE_CELL_ID owner:nil options:nil]lastObject];
        
    }
    NSMutableDictionary* array = [[NSMutableDictionary alloc]initWithCapacity:0];
        array = subDetial[indexPath.row];
        cell.alarmid.text = [array objectForKey:@"alarmId"];
        cell.deviceName.text = [NSString stringWithFormat:@"%@(%@)",[subDetial[indexPath.row] objectForKey:@"devName"],[subDetial[indexPath.row] objectForKey:@"snaddr"]];
    cell.startTime.text =[NSString stringWithFormat:@"开始报警:%@",[[array objectForKey:@"startTime"]substringWithRange:NSMakeRange(0, 16)]];
    

    if([[array objectForKey:@"endTime"] length] >15){
        cell.endTime.text =[NSString stringWithFormat:@"结束报警:%@",[[array objectForKey:@"endTime"]substringWithRange:NSMakeRange(0, 16)]];

    }else{
        cell.endTime.text = @"";
    }
    

        cell.msg.text = [array objectForKey:@"info"];
    
    
    if ([[array objectForKey:@"alarmState"] isEqualToString:@"0"]) {
        cell.AlarmState.text = @"正在报警";
        cell.duration.text = @"";
        cell.AlarmState.textColor = [UIColor colorWithRed:140/255.0 green:30/255.0 blue:50/255.0 alpha:1];
    }else{
        
        NSString* str = [self returnUploadTime:[array objectForKey:@"endTime"] start:[array objectForKey:@"startTime"]];
        cell.duration.text =  [NSString stringWithFormat:@"报警持续时间:%@",str];
        cell.AlarmState.text = @"报警结束";
        cell.AlarmState.textColor = [UIColor colorWithRed:10/255.0 green:130/255.0 blue:80/255.0 alpha:1];
        
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
- (void)alertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}


/*处理返回应该显示的时间*/
- (NSString *) returnUploadTime:(NSString *)end start:(NSString*)start
{
    
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"YY-MM-dd HH:mm:ss"];
    NSDate *endDate=[date dateFromString:end];
    
    NSTimeInterval now=[endDate timeIntervalSince1970]*1;
    
    
    NSDate* startDate = [date dateFromString:start];
    NSTimeInterval late=[startDate timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟", timeString];
        
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时", timeString];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天", timeString];
    }
    return timeString;
}
@end
