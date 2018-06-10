//
//  Language.h
//  CQTechApp
//
//  Created by 梁明哲 on 2017/12/28.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LanguageKey @"userLanguage"

#define CNS @"zh-Hans"

#define EN @"en"

#define NotificationLanguageChanged  @"LanguageChanged"
#define LocalizedString(key)  [[Language bundle] localizedStringForKey:(key) value:@"" table:@"Localizable"]

@interface Language : NSObject
/**
 *  获取当前资源文件
 */
+ (NSBundle *)bundle;
/**
 *  初始化语言文件
 */
+ (void)initUserLanguage;
/**
 *  获取应用当前语言
 */
+ (NSString *)getUserLanguage;
/**
 *  设置当前语言
 */
+ (void)setUserlanguage:(NSString *)language;

@end
