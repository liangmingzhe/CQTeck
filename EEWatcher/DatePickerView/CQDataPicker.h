//
//  XFDateView.h
//  XFPickerViewDemo

//  Copyright © 2016年 BigFly. All rights reserved.
//
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a/1.0]
#define ImageName(name) [UIImage imageNamed:name]
#define Font(x) [UIFont systemFontOfSize:x]
#define Frame(x,y,w,h) CGRectMake(x, y, w, h)
#define Size(w,h) CGSizeMake(w, h)
#define Point(x,y) CGPointMake(x, y)
#define ZeroRect CGRectZero
#define TouchUpInside UIControlEventTouchUpInside
#define NormalState UIControlStateNormal
#define SelectedState UIControlStateSelected
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define WH(x) (x)*SCREEN_WIDTH/375.0
#define MainRedColor [UIColor colorWithRed:48.0/255.0 green:95.0/255.0 blue:157.0/255.0 alpha:1]

#define BlackFontColor RGB(34,34,34)
#define WhiteColor RGB(255,255,255)
#define ContentBackGroundColor RGB(238,238,238)
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, CQDataPickerType){
    CQDataPickerTypeDate = 0,//年月日
    CQDataPickerTypeTime ,//时分秒
};

@class CQDataPicker;

@protocol CQDataPickerDelegate <NSObject>

- (void)daterViewDidClicked:(CQDataPicker *)daterView;
- (void)daterViewDidCancel:(CQDataPicker *)daterView;

@end

@interface CQDataPicker : UIView

@property (nonatomic, assign) id<CQDataPickerDelegate> delegate;

@property (nonatomic) CQDataPickerType dateViewType;//默认类型为日期
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSString *timeString;
@property (nonatomic, readonly) int year;
@property (nonatomic, readonly) int month;
@property (nonatomic, readonly) int day;
@property (nonatomic, readonly) int hour;
@property (nonatomic, readonly) int miniute;
@property (nonatomic, readonly) int second;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

- (void)setSelectTime:(int)year month:(int)month day:(int)day hour:(int)hour miniute:(int)miniute second:(int)second animated:(BOOL)animated;



@end

@interface UIView (Category)
@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat y;
@property (nonatomic,assign) CGFloat w;
@property (nonatomic,assign) CGFloat h;
@end

