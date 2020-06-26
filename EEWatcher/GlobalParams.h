//
//  GlobalParams.h
//  CQTechApp
//
//  Created by 梁明哲 on 2020/6/3.
//  Copyright © 2020 ChengQian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalParams : NSObject

/// 获取系统的域名
+ (NSString* )getHttpDomain;
/// 切换到测试域名
+ (void)switchHttpDomainToTest2501:(BOOL)toTest;


/// 当前横竖屏状态
+ (UIInterfaceOrientation)gerCurrentOrientation;
/// 状态栏高度
+ (CGFloat)statusBarHeight;
/// 导航条高度
+ (CGFloat)navgationBarHeight;
/// 导航高度
+ (CGFloat)navigationHeight;

/// 底部 tabbar高度
+ (CGFloat)tabBarHeight;
/// 底部 tabbar高度 + 安全区可选
+ (CGFloat)tabBarHeightWithSafeAreaInsets:(BOOL)value;
@end

NS_ASSUME_NONNULL_END
