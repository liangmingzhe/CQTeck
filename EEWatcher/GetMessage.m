//
//  GetMessage.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/12/11.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "GetMessage.h"
UIWindow *_window;
// 窗口的高度
#define XWWindowHeight 60
// 动画的执行时间
#define XWDuration 0.5
// 窗口的停留时间
#define XWDelay 1.5
// 字体大小
#define XWFont [UIFont systemFontOfSize:17]

@implementation GetMessage

////--------///------------------//
+ (void)showMessage:(NSString *)msg image:(UIImage *)image
{
    
    if (_window) return;
    
    // 创建Label
    UILabel*message = [[UILabel alloc]init];
    UIImageView* icon = [[UIImageView alloc]initWithImage:image];
    // 设置按钮文字大小
    message.font = XWFont;
    // 设置数据
    message.text = msg;
    message.textColor = [UIColor blackColor];
    
    // 创建窗口
    _window = [[UIWindow alloc] init];
    _window.layer.cornerRadius = 10.0f;
    // 窗口背景
    _window.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.8];
    _window.windowLevel = UIWindowLevelAlert;
    _window.frame = CGRectMake(0, -XWWindowHeight - 10, [UIScreen mainScreen].bounds.size.width, XWWindowHeight);
    message.frame = CGRectMake(50, _window.bounds.size.height/2 - 20, [UIScreen mainScreen].bounds.size.width - 50, 40);
    [_window addSubview:message];
    icon.frame = CGRectMake(10, _window.bounds.size.height/2 - 15, 30, 30);
    [_window addSubview:icon];
    _window.hidden = NO;
    
    // 状态栏 也是一个window
    // UIWindowLevelAlert > UIWindowLevelStatusBar > UIWindowLevelNormal
    
    // 动画
    [UIView animateWithDuration:XWDuration animations:^{
        CGRect frame = _window.frame;
        frame.origin.y = 0;
        _window.frame = frame;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:XWDuration delay:XWDelay options:kNilOptions animations:^{
            CGRect frame = _window.frame;
            frame.origin.y = - XWWindowHeight;
            _window.frame = frame;
        } completion:^(BOOL finished) {
            _window = nil;
        }];
    }];
}


@end
