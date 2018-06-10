//
//  RedView.m
//  huibam
//
//  Created by Apple on 2016/11/23.
//  Copyright © 2016年 huibam. All rights reserved.
//

#import "RedView.h"

@implementation RedView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2, 2)];
        view.backgroundColor = [UIColor colorWithRed:59/255.0 green:110/255.0 blue:189/255.0 alpha:1];
        [self addSubview:view];
        
        
       
        
    }
    return self;
}

@end
