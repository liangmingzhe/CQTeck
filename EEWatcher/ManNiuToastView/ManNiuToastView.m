//
//  ManNiuToastView.m
//  manniu
//
//  Created by benjaminlmz@qq.com on 2019/4/22.
//  Copyright © 2019 蛮牛科技. All rights reserved.
//

#import "ManNiuToastView.h"
#define FLT_APP_WINDOW  [[UIApplication sharedApplication] keyWindow]

@implementation ManNiuToastView
+ (void)showToast:(NSString *)message withDuration:(NSUInteger)duration {
    [ManNiuToastView dismissToast];
    dispatch_async(dispatch_get_main_queue(), ^{
        // build the toast label
        UILabel *toast = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        toast.text = message;
        toast.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
        toast.textColor = kCBToastTextColor;
        toast.numberOfLines = 1000;
        toast.tag = 1024;
        toast.textAlignment = NSTextAlignmentCenter;
        toast.lineBreakMode = NSLineBreakByWordWrapping;
        toast.font = [UIFont systemFontOfSize:14.0f];
        toast.layer.cornerRadius = kCBToastCornerRadius;
        toast.layer.masksToBounds = YES;
        
        // resize based on message
        CGSize maximumLabelSize = CGSizeMake(kCBToastMaxWidth, 9999);
        CGSize expectedLabelSize = [toast.text boundingRectWithSize:maximumLabelSize
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:toast.font}
                                                            context:nil].size;
        //adjust the label to the new height
        CGRect newFrame = toast.frame;
        newFrame.size = CGSizeMake(expectedLabelSize.width + kCBToastPadding,
                                   expectedLabelSize.height + kCBToastPadding);
        toast.frame = newFrame;
        
        // add the toast to the root window (so it overlays everything)
        if ([toast.text length] > 0) {
            [FLT_APP_WINDOW addSubview:toast];
            
            // get the window frame to determine placement
            CGRect windowFrame = FLT_APP_WINDOW.frame;
            
            // align the toast properly
            toast.center = CGPointMake(windowFrame.size.width / 2, windowFrame.size.height / 2);
            
            // round the x/y coords so they aren't 'split' between values (would appear blurry)
            toast.frame = CGRectMake(round(toast.frame.origin.x),
                                     round(toast.frame.origin.y),
                                     toast.frame.size.width,
                                     toast.frame.size.height);
            
            // set up the fade-in
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:kCBToastFadeDuration];
            
            // values being aninmated
            toast.alpha = 1.0f;
            
            // perform the animation
            [UIView commitAnimations];
            
            // calculate the delay based on fade-in time + display duration
            NSTimeInterval delay = duration;
            
            // set up the fade out (to be performed at a later time)
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:delay];
            [UIView setAnimationDuration:kCBToastFadeDuration];
            [UIView setAnimationDelegate:toast];
            [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
            
            // values being animated
            toast.alpha = 0.0f;
            
            // commit the animation for being performed when the timer fires
            [UIView commitAnimations];
        }
    });
}

+ (void)showToast:(NSString *)message imgType:(NSInteger)type withDuration:(NSUInteger)duration {
    [ManNiuToastView dismissToast];// 加上这句话避免重复点击时出现叠加
    dispatch_async(dispatch_get_main_queue(), ^{
        // build the toast label
        UIView *toastView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40,40)];
        toastView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
        toastView.layer.cornerRadius = kCBToastCornerRadius;
        toastView.layer.masksToBounds = YES;
        toastView.tag = 1024;
        
        // 图片添加
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(kCBToastPadding/2, kCBToastPadding/2, 15, 15)];
        if (type == 0) {
            imageview.image = [UIImage imageNamed:@"alert_warn"];
        } else {
            imageview.image = [UIImage imageNamed:@"alert_ok"];
        }
        [toastView addSubview:imageview];
        
        // label添加
        UILabel *toast = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        toast.backgroundColor = [UIColor clearColor];
        toast.text = message;
        toast.textColor = kCBToastTextColor;
        toast.numberOfLines = 1000;
        toast.textAlignment = NSTextAlignmentCenter;
        toast.lineBreakMode = NSLineBreakByWordWrapping;
        toast.font = [UIFont systemFontOfSize:14.0f];
        
        // resize based on message
        CGSize maximumLabelSize = CGSizeMake(kCBToastMaxWidth, 9999);
        CGSize expectedLabelSize = [toast.text boundingRectWithSize:maximumLabelSize
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:toast.font}
                                                            context:nil].size;
        //        //adjust the label to the new height
        toast.frame = CGRectMake(kCBToastPadding+15, kCBToastPadding/2 - 1.5, expectedLabelSize.width, expectedLabelSize.height);
        toastView.frame = CGRectMake(0, 0, expectedLabelSize.width+kCBToastPadding*1.5+15, expectedLabelSize.height+kCBToastPadding);
        
        [toastView addSubview:toast];
        
        // add the toast to the root window (so it overlays everything)
        if ([message length] > 0) {
            [FLT_APP_WINDOW addSubview:toastView];
            
            // get the window frame to determine placement
            CGRect windowFrame = FLT_APP_WINDOW.frame;
            
            // align the toast properly
            toastView.center = CGPointMake(windowFrame.size.width / 2, windowFrame.size.height / 2);
            
            // round the x/y coords so they aren't 'split' between values (would appear blurry)
            toastView.frame = CGRectMake(round(toastView.frame.origin.x),
                                         round(toastView.frame.origin.y),
                                         toastView.frame.size.width,
                                         toastView.frame.size.height);
            
            // set up the fade-in
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:kCBToastFadeDuration];
            
            // values being aninmated
            toastView.alpha = 1.0f;
            
            // perform the animation
            [UIView commitAnimations];
            
            // calculate the delay based on fade-in time + display duration
            NSTimeInterval delay = duration;
            
            // set up the fade out (to be performed at a later time)
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:delay];
            [UIView setAnimationDuration:kCBToastFadeDuration];
            [UIView setAnimationDelegate:toastView];
            [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
            
            // values being animated
            toastView.alpha = 0.0f;
            
            // commit the animation for being performed when the timer fires
            [UIView commitAnimations];
        }
    });
}

+ (void)showToastWithActivity:(NSString *)message withDuration:(NSUInteger)duration {
    [ManNiuToastView dismissToast];// 加上这句话避免重复点击时出现叠加
    dispatch_async(dispatch_get_main_queue(), ^{
        // build the toast label
        UIView *toastView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40,40)];
        toastView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
        
        
        toastView.tag = 1024;
        
        UIActivityIndicatorView *m_activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(kCBToastPadding, kCBToastPadding/2, 10, 10)];
        [toastView addSubview:m_activity];
        [m_activity startAnimating];
        // label添加
        UILabel *toast = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        toast.backgroundColor = [UIColor clearColor];
        toast.text = message;
        toast.textColor = kCBToastTextColor;
        toast.numberOfLines = 1000;
        toast.textAlignment = NSTextAlignmentCenter;
        toast.lineBreakMode = NSLineBreakByWordWrapping;
        toast.font = [UIFont systemFontOfSize:12.0f];
        
        // resize based on message
        CGSize maximumLabelSize = CGSizeMake(kCBToastMaxWidth, 9999);
        CGSize expectedLabelSize = [toast.text boundingRectWithSize:maximumLabelSize
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:toast.font}
                                                            context:nil].size;
        //        //adjust the label to the new height
        toast.frame = CGRectMake(kCBToastPadding+25, kCBToastPadding/2, expectedLabelSize.width, expectedLabelSize.height);
        toastView.frame = CGRectMake(0, 0, expectedLabelSize.width+kCBToastPadding*1.5+25, expectedLabelSize.height + kCBToastPadding);
        toastView.layer.cornerRadius = (expectedLabelSize.height+kCBToastPadding)*0.5;
        toastView.layer.masksToBounds = YES;
        
        [m_activity setCenter:CGPointMake(m_activity.center.x, toastView.center.y)];
        [toastView addSubview:toast];
        
        // add the toast to the root window (so it overlays everything)
        if ([message length] > 0) {
            [FLT_APP_WINDOW addSubview:toastView];
            
            // get the window frame to determine placement
            CGRect windowFrame = FLT_APP_WINDOW.frame;
            
            // align the toast properly
            toastView.center = CGPointMake(windowFrame.size.width / 2, HEIGHT + 40);
            
            // round the x/y coords so they aren't 'split' between values (would appear blurry)
            toastView.frame = CGRectMake(round(toastView.frame.origin.x),
                                         round(toastView.frame.origin.y),
                                         toastView.frame.size.width,
                                         toastView.frame.size.height);
            
            // set up the fade-in
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:kCBToastFadeDuration];
            
            // values being aninmated
            toastView.alpha = 1.0f;
            
            // perform the animation
            [UIView commitAnimations];
            
            // calculate the delay based on fade-in time + display duration
            NSTimeInterval delay = duration;
            
            // set up the fade out (to be performed at a later time)
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:delay];
            [UIView setAnimationDuration:kCBToastFadeDuration];
            [UIView setAnimationDelegate:toastView];
            [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
            
            // values being animated
            toastView.alpha = 0.0f;
            
            // commit the animation for being performed when the timer fires
            [UIView commitAnimations];
        }
    });
}


+ (void)dismissToast {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *toast = (UIView *)FLT_APP_WINDOW.subviews.lastObject;
        
        if (toast.tag == 1024) {
            [toast removeFromSuperview];
        }
    });
}

@end
