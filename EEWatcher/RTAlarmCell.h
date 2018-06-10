//
//  RTAlarmCell.h
//  CQTechApp
//
//  Created by 梁明哲 on 2018/1/31.
//  Copyright © 2018年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTAlarmCell : UITableViewCell<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *alarmid;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *msg;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *AlarmState;

@property(nonatomic,strong)UIButton* confirm;
@property(nonatomic,strong)UIButton* ignore;
@property(nonatomic,strong)NSString* infomation;
@end
