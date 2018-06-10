//
//  HistoryErrCell.h
//  CQTechApp
//
//  Created by 梁明哲 on 2018/4/4.
//  Copyright © 2018年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryErrCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *AlarmId;
@property (weak, nonatomic) IBOutlet UILabel *aMessage;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *endTime;

@property (weak, nonatomic) IBOutlet UILabel *handleTips;
@property (weak, nonatomic) IBOutlet UILabel *user;

@end
