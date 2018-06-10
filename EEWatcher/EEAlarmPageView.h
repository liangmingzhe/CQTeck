//
//  EEAlarmPageView.h
//  EEWatcher
//
//  Created by 梁明哲 on 16/7/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmCell.h"
#import "Singleton.h"
#import "cqtekHeader.pch"
@interface EEAlarmPageView : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
}
@property(nonatomic,strong)NSMutableDictionary* selectDic;
singleton_h(InstanceAlarm);
@end
