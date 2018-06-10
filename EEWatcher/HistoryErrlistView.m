//
//  HistoryErrlistView.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/20.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "HistoryErrlistView.h"
#import "HistoryCheck.h"
#import "HistoryErrCell.h"
#import "HistoryCheck.h"
#import "Language.h"
@interface HistoryErrlistView ()

@end

@implementation HistoryErrlistView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LocalizedString(@"l_alarm_record");
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[HistoryCheck sharedInstanceFour]historyArray] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}
//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    UIView* headerBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80)];
//    headerBackView.backgroundColor = [UIColor redColor];
////    NSString* enddd =  [NSString stringWithFormat:@"[设备名:%@] \n [SN:%@]\n %@\n %@",[HistoryCheck sharedInstanceFour].devName,[HistoryCheck sharedInstanceFour].snaddr,[[HistoryCheck sharedInstanceFour]teststring],[[HistoryCheck sharedInstanceFour]endString]];
//    return headerBackView;
//}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* headerBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    headerBackView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    UILabel* DevName = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, [UIScreen mainScreen].bounds.size.width/2 - 10, 20)];
    DevName.text = [NSString stringWithFormat:@"设备名:%@",[HistoryCheck sharedInstanceFour].devName];
    [headerBackView addSubview:DevName];
    UILabel* SN = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2+5, 5, [UIScreen mainScreen].bounds.size.width/2 - 10, 20)];
    SN.text = [NSString stringWithFormat:@"SN号:%@",[HistoryCheck sharedInstanceFour].snaddr];
    [headerBackView addSubview:SN];
    
    
    UILabel* timeInterval = [[UILabel alloc]initWithFrame:CGRectMake(5, 5 + 30, [UIScreen mainScreen].bounds.size.width - 10, 20)];
    timeInterval.font = [UIFont fontWithName:@"Arial" size:14];
    NSString* start = [[HistoryCheck sharedInstanceFour] teststring];
    NSString* end = [[HistoryCheck sharedInstanceFour] endString];
    timeInterval.text = [NSString stringWithFormat:@"时间段: %@ 至 %@",start,end];
    [headerBackView addSubview:timeInterval];
    
    return headerBackView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"HistoryErrCell";
    HistoryErrCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:identifier owner:nil options:nil] lastObject];
    }
    
    cell.AlarmId.text = [[HistoryCheck sharedInstanceFour].historyArray[indexPath.row] objectForKey:@"alarmId"];
    NSString* start = [[HistoryCheck sharedInstanceFour].historyArray[indexPath.row] objectForKey:@"startTime"];
    NSString* end = [[HistoryCheck sharedInstanceFour].historyArray[indexPath.row] objectForKey:@"endTime"];
    cell.time.text = [NSString stringWithFormat:@"报警开始时间:%@",start];
    cell.endTime.text = [NSString stringWithFormat:@"报警结束时间:%@",end];
    cell.user.text = [[HistoryCheck sharedInstanceFour].historyArray[indexPath.row] objectForKey:@"handleUser"];
    cell.aMessage.text = [[HistoryCheck sharedInstanceFour].historyArray[indexPath.row] objectForKey:@"info"];
    cell.handleTips.text = [[HistoryCheck sharedInstanceFour].historyArray[indexPath.row] objectForKey:@"additionInfo"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
