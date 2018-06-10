//
//  DateValueFormatter.h
//  LMZLogin
//
//  Created by 梁明哲 on 2017/3/9.
//  Copyright © 2017年 lmz. All rights reserved.
//

#import <UIKit/UIKit.h>  
#import "CQTechApp-Bridging-Header.h"
#import "CQTechApp-Swift.h"
@interface DateValueFormatter : NSObject <IChartAxisValueFormatter>
- (id)initWithDateArr:(NSArray *)arr;
@end
