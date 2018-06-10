//
//  BlockCell.m
//  EEWatcher
//
//  Created by 梁明哲 on 16/8/10.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "BlockCell.h"

@implementation BlockCell

- (instancetype)initWithFrame:(CGRect)frame
{
    f = frame;
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
    }
    return self;
}
- (void)createSubViews{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, f.size.width, 80)];
    //背景色渐变
    
    _backView.backgroundColor = [UIColor colorWithRed:36/255.0 green:75/255.0 blue:142/255.0 alpha:1];

    _title = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, _backView.frame.size.width/7*6, _backView.frame.size.height/4)];
    _title.numberOfLines = 2;
    _title.textColor = [UIColor whiteColor];
    _title.backgroundColor = [UIColor clearColor];
    
    _title.font = [UIFont systemFontOfSize:15];
    _title.layer.borderWidth = 0;
    
    [_backView addSubview:_title];
    
    UIImageView *dataView = [[UIImageView alloc]initWithFrame:CGRectMake(3,_backView.frame.size.height/4, _backView.frame.size.width-6, _backView.frame.size.height/4*3 - 2)];
    
    dataView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    //dataView.layer.cornerRadius = 3;
    [_backView addSubview:dataView];
    
    _temp = [[UILabel alloc]initWithFrame:CGRectMake(3, _title.frame.origin.y + _title.frame.size.height , 100, 20)];
    _temp.numberOfLines = 1;
    _temp.textColor = [UIColor darkGrayColor];
    _temp.backgroundColor = [UIColor clearColor];
    _temp.font = [UIFont systemFontOfSize:15];
    _temp.layer.borderWidth = 0;
    [_backView addSubview:_temp];
    
    _tempStatusImage = [[UIImageView alloc]initWithFrame:CGRectMake(_backView.frame.size.width - 14,_temp.frame.origin.y + 4, 12, 12)];
    [_backView addSubview: _tempStatusImage];
    
    _humi = [[UILabel alloc]initWithFrame:CGRectMake(3, _temp.frame.origin.y + _temp.frame.size.height , 100, 20)];
    _humi.numberOfLines = 1;
    _humi.textColor = [UIColor darkGrayColor];
    _humi.backgroundColor = [UIColor clearColor];
    _humi.font = [UIFont systemFontOfSize:15];
    _humi.layer.borderWidth = 0;
    [_backView addSubview:_humi];
    
    _humiStatusImage = [[UIImageView alloc]initWithFrame:CGRectMake(_backView.frame.size.width - 14,_humi.frame.origin.y + 4, 12, 12)];
    
    [_backView addSubview: _humiStatusImage];

    
    _lastTime = [[UILabel alloc]initWithFrame:CGRectMake(3, _humi.frame.origin.y + _humi.frame.size.height , dataView.frame.size.width - 3, 20)];
    _lastTime.numberOfLines = 1;
    _lastTime.textColor = [UIColor darkGrayColor];
    _lastTime.backgroundColor = [UIColor clearColor];
    _lastTime.font = [UIFont systemFontOfSize:12];
    _lastTime.layer.borderWidth = 0;
    _lastTime.text = @"0000.00.00 00:00";
    [_backView addSubview:_lastTime];
    _OnlineImage = [[UIImageView alloc]initWithFrame:CGRectMake(_backView.frame.size.width - 20, _backView.frame.size.height/6 - 12, 18, 18)];
    [_backView addSubview:_OnlineImage];

    [self.contentView addSubview:_backView];
}
@end
