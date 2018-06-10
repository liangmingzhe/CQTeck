//
//  DateValueFormatter.m
//  LMZLogin
//
//  Created by 梁明哲 on 2017/3/9.
//  Copyright © 2017年 lmz. All rights reserved.
//

#import "DateValueFormatter.h"

@interface DateValueFormatter () {
    NSArray *_dateArr;
    NSDateFormatter *_preFormatter;
    NSDateFormatter *_needFormatter;
}
@end
@implementation DateValueFormatter
- (id)initWithDateArr:(NSArray *)arr {
    if (self = [super init]) {
        _dateArr = [NSArray arrayWithArray:arr];
        
        _preFormatter = [[NSDateFormatter alloc] init];
        _preFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        _needFormatter = [[NSDateFormatter alloc] init];
        
        _needFormatter.dateFormat = @"MM.dd HH:mm";
    }
    return self;
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {

    NSString *dateStr;
    NSDate *date;
    if (_dateArr.count > 0) {
        dateStr = _dateArr[(int)value];
        date = [_preFormatter dateFromString:dateStr];
        return [_needFormatter stringFromDate:date];
    }else{
        return @"";
    }
}
@end





