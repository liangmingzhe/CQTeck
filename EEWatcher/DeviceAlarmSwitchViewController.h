//
//  DeviceAlarmSwitchViewController.h
//  CQTechApp
//
//  Created by 梁明哲 on 2017/10/10.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"

@interface DeviceAlarmSwitchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)NSMutableArray* listArray;
singleton_h(Instance1);
@end
