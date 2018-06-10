//
//  DeviceSetController.h
//  CQTechApp
//
//  Created by 梁明哲 on 2016/11/29.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DevSetCell.h"
#import "ModifyDevNameView.h"
#import "DeviceAreaView.h"
#import "ModifyThresholdView.h"
#import "MSMAlarmViewController.h"
//#import "ModifyUpDateTime.h"
#import "EEMainPageView.h"
#import "AFNetworking.h"
#import "Singleton.h"
#import "Reachability.h"
#import "cqtekHeader.pch"
@interface DeviceSetController : UIViewController{
}
@property (strong,nonatomic) NSMutableDictionary* Dic1;
@property (nonatomic,strong)CAShapeLayer* Shaper;
@property (nonatomic ,assign)CGFloat tt;
@property (nonatomic,strong)NSMutableArray* listArray;
singleton_h(Instance2);
@end
