//
//  UITextField+Extend.h
//  CQTechApp
//
//  Created by 梁明哲 on 2017/7/3.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Extend)
- (NSRange)selectedRange;
- (void) setSelectedRange:(NSRange) range;  // 备注：UITextField必须为第一响应者才有效
@end
