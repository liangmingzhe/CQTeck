//
//  Algorithm.h
//  CQTechApp
//
//  Created by 梁明哲 on 2017/11/18.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Algorithm : NSObject

+ (NSString *)md5:(NSString *)input;
+ (BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)isOnlyNumberAndCharactors:(NSString*)string;//只包含数字或字母
@end
