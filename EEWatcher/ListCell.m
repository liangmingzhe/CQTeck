//
//  ListCell.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/12/13.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "ListCell.h"
#import "Language.h"
@implementation ListCell

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
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, f.size.width, 100)];
        _backView.backgroundColor = [UIColor colorWithRed:36/255.0 green:75/255.0 blue:140/255.0 alpha:1];

        
        _title = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 200, 30)];
        _title.font = [UIFont fontWithName:@"Arial" size:24];
        _title.textColor = [UIColor whiteColor];
        _title.backgroundColor = [UIColor clearColor];
        _title.layer.borderWidth = 0;
        
        [_backView addSubview:_title];

        UIImageView *dataView = [[UIImageView alloc]initWithFrame:CGRectMake(3, 0 + 30, _backView.frame.size.width-6, _backView.frame.size.height-30 - 5)];
        
        dataView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
//        dataView.layer.cornerRadius = 3;
        [_backView addSubview:dataView];

        UILabel* tempLabel =[[UILabel alloc]initWithFrame:CGRectMake(3, _backView.frame.size.height/4 + 5, 60, 30)];
        tempLabel.textColor = [UIColor blackColor];
        tempLabel.text = [NSString stringWithFormat:@"%@:",LocalizedString(@"temperature")];
        tempLabel.font = [UIFont fontWithName:@"Arial" size:18];
        [_backView addSubview:tempLabel];
        _temp = [[UILabel alloc]initWithFrame:CGRectMake(tempLabel.frame.size.width + 5, tempLabel.frame.origin.y, 80, 30)];
        _temp.numberOfLines = 1;
        _temp.font = [UIFont fontWithName:@"Arial" size:16];
        _temp.textColor = [UIColor blackColor];
        _temp.backgroundColor = [UIColor clearColor];
        _temp.layer.borderWidth = 0;
        [_backView addSubview:_temp];
        
        _tempStatusImage = [[UIImageView alloc]initWithFrame:CGRectMake(_temp.frame.origin.x + _temp.frame.size.width,_temp.frame.origin.y + 9, 12, 12)];
        [_backView addSubview: _tempStatusImage];


        UILabel* humiLabel =[[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2, _temp.frame.origin.y, 55, 30)];
        humiLabel.textColor = [UIColor blackColor];
        humiLabel.text = [NSString stringWithFormat:@"%@:",LocalizedString(@"humidity")];
        humiLabel.font = [UIFont fontWithName:@"Arial" size:18];
        [_backView addSubview:humiLabel];

        _humi = [[UILabel alloc]initWithFrame:CGRectMake(humiLabel.frame.origin.x + humiLabel.frame.size.width + 5, humiLabel.frame.origin.y, 100, 30)];
        _humi.font = [UIFont fontWithName:@"Arial" size:16];
        _humi.textColor = [UIColor blackColor];
        _humi.backgroundColor = [UIColor clearColor];
        _humi.layer.borderWidth = 0;
        [_backView addSubview:_humi];
        _humiStatusImage = [[UIImageView alloc]initWithFrame:CGRectMake(_humi.frame.origin.x +_humi.frame.size.width,_humi.frame.origin.y + 9, 12, 12)];
        
        [_backView addSubview: _humiStatusImage];

        
        _lastTime = [[UILabel alloc]initWithFrame:CGRectMake(5, _backView.frame.size.height/8*5, 200, 30)];
        _lastTime.font = [UIFont fontWithName:@"Arial" size:20];
        _lastTime.text = @"2016.12.14 20:19";
        _lastTime.textColor  = [UIColor blackColor];
        [_backView addSubview:_lastTime];
        _OnlineImage = [[UIImageView alloc]initWithFrame:CGRectMake(_backView.frame.size.width - 25, _backView.frame.size.height/6 - 10, 20, 20)];
        [_backView addSubview:_OnlineImage];
        [self.contentView addSubview:_backView];
    }
@end
