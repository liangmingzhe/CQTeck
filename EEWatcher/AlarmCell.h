//
//  AlarmCell.h
//  CQTechApp
//
//  Created by 梁明哲 on 2016/11/30.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmCell : UITableViewCell
@property (strong, nonatomic)  UIImageView *icon;
@property (strong, nonatomic)  UILabel *deviceName;
@property (strong, nonatomic)  UILabel *errorMessage;
@property (strong, nonatomic)  UILabel *area;
@property (strong, nonatomic)  UILabel *alarmTime;

@end
