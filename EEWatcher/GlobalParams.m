//
//  GlobalParams.m
//  CQTechApp
//
//  Created by 梁明哲 on 2020/6/3.
//  Copyright © 2020 ChengQian. All rights reserved.
//

#import "GlobalParams.h"
#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})																

@implementation GlobalParams
+ (NSString* )getHttpDomain {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *domain = [userDefaults objectForKey:@"http_domain"];
    if (domain == nil) {
        domain = @"http://iot.chengqianyun.com:2500";
        [userDefaults setObject:domain forKey:@"http_domain"];
        [userDefaults synchronize];
        return domain;
    }else {
        return domain;
    }
}

+ (void)switchHttpDomainToTest2501:(BOOL)toTest {
    NSString *domain = @"http://iot.chengqianyun.com:2500";
    if (toTest == YES) {
        domain = @"http://iot.chengqianyun.com:2501";
    }else {
        domain = @"http://iot.chengqianyun.com:2500";
    }
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:domain forKey:@"http_domain"];
    [userDefaults synchronize];
}


+ (UIInterfaceOrientation)gerCurrentOrientation {
    return [[[UIApplication sharedApplication] windows] firstObject].windowScene.interfaceOrientation;
}

+ (CGFloat)statusBarHeight {
    return kIsBangsScreen == YES?44:20;
}
+ (CGFloat)navgationBarHeight {
    if ([GlobalParams gerCurrentOrientation] == UIDeviceOrientationPortrait || [GlobalParams gerCurrentOrientation] == UIDeviceOrientationPortraitUpsideDown) {
        //当前竖屏
        return 44;
    } else {
       //当前横屏
        return 0;
    }
    
}

+ (CGFloat)navigationHeight {
    if ([GlobalParams gerCurrentOrientation] == UIDeviceOrientationPortrait || [GlobalParams gerCurrentOrientation] == UIDeviceOrientationPortraitUpsideDown) {
        //当前竖屏
        return [GlobalParams navgationBarHeight] + [GlobalParams statusBarHeight];
    } else {
       //当前横屏
        return [GlobalParams navgationBarHeight] + [GlobalParams statusBarHeight];
    }
}

+ (CGFloat)tabBarHeightWithSafeAreaInsets:(BOOL)value {
    if (value == YES) {
        return kIsBangsScreen == YES ? 49.0 + 34.0: 49.0;
    }else {
        return 49.0;
    }
}

+ (CGFloat)tabBarHeight {
    return 49.0;
}
@end
