//
//  ManNiuToastView.h
//  manniu
//
//  Created by benjaminlmz@qq.com on 2019/4/22.
//  Copyright © 2019 蛮牛科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

#define TOAST_LONG  2000
#define TOAST_SHORT 1000

#define kCBToastPadding         20
#define kCBToastMaxWidth        220
#define kCBToastCornerRadius    5.0
#define kCBToastFadeDuration    0.5
#define kCBToastTextColor       [UIColor whiteColor]
#define kCBToastBottomPadding   30

@interface ManNiuToastView : NSObject

+ (void)showToast:(NSString *)message withDuration:(NSUInteger)duration;

/**
 * 含有图片的信息提示
 *®
 *  1：表示ok
 *  0：表示warn
 */
+ (void)showToast:(NSString *)message imgType:(NSInteger)type withDuration:(NSUInteger)duration;
+ (void)showToastWithActivity:(NSString *)message withDuration:(NSUInteger)duration;
+ (void)dismissToast;

@end

NS_ASSUME_NONNULL_END
