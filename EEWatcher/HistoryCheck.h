//
//  HistoryCheck.h
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/2.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "cqtekHeader.pch"
@interface HistoryCheck : UIViewController

@property (nonatomic,strong) NSMutableArray* historyArray;
@property (nonatomic,strong) NSString* snaddr;
@property (nonatomic,strong) NSString* devName;
@property (nonatomic,strong) NSString* area;
@property (nonatomic,strong) NSString* teststring;
@property (nonatomic,strong) NSString* endString;

singleton_h(InstanceFour);
@end
