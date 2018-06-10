//
//  HistoryTimePickViewController.h
//  CQTechApp
//
//  Created by 梁明哲 on 2017/2/5.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "cqtekHeader.pch"
@interface HistoryTimePickViewController : UIViewController
@property (nonatomic,strong)NSMutableDictionary* historyDic;
@property (nonatomic,strong)NSString* snaddr;
@property (nonatomic,strong)NSString* area;
@property (nonatomic,strong)NSString* rangeTime;
@property(nonatomic,strong) NSString* teststring;
@property(nonatomic,strong) NSString* endString;
singleton_h(InstanceFive);
@end
