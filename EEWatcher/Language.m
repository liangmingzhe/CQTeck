//
//  Language.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/12/28.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "Language.h"
static Language *currentLanguage;

@implementation Language

static NSBundle *bundle = nil;

+ (NSBundle *)bundle{
    return bundle;
}
// 初始化语言文件
+ (void)initUserLanguage{
    NSString *languageString = [[NSUserDefaults standardUserDefaults] valueForKey:LanguageKey];
    if(languageString.length == 0){
        // 获取系统当前语言版本
        NSArray *languagesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        languageString = languagesArray.firstObject;
        [[NSUserDefaults standardUserDefaults] setValue:languageString forKey:@"getUserLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // 避免缓存会出现 zh-Hans-CN 及其他语言的的情况
    if ([[Language chinese] containsObject:languageString]) {
        languageString = [[Language chinese] firstObject]; // 中文
    } else if ([[Language english] containsObject:languageString]) {
        languageString = [[Language english] firstObject]; // 英文
    } else {
        languageString = [[Language chinese] firstObject]; // 其他默认为中文
    }
    
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:languageString ofType:@"lproj"];
    // 生成bundle
    bundle = [NSBundle bundleWithPath:path];
}

// 英文类型数组
+ (NSArray *)english {
    return @[@"en"];
}

// 中文类型数组
+ (NSArray *)chinese{
    return @[@"zh-Hans", @"zh-Hant"];
}

// 获取应用当前语言
+ (NSString *)getUserLanguage {
    NSString *languageString = [[NSUserDefaults standardUserDefaults] valueForKey:LanguageKey];
    return languageString;
}
// 设置当前语言
+ (void)setUserlanguage:(NSString *)language {
    if([[self getUserLanguage] isEqualToString:language]) return;
    // 改变bundle的值
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    bundle = [NSBundle bundleWithPath:path];
    // 持久化
    [[NSUserDefaults standardUserDefaults] setValue:language forKey:LanguageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLanguageChanged object:currentLanguage];
}


@end
