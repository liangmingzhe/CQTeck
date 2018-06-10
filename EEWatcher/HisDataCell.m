//
//  HisDataCell.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/2/5.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "HisDataCell.h"

@implementation HisDataCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self.backgroundColor = [UIColor clearColor];
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _tempValue = [[UILabel alloc]initWithFrame:CGRectMake(5, self.frame.size.height/2 - 10, 120, 20)];
        _tempValue.textAlignment = NSTextAlignmentCenter;
        _tempValue.font =[UIFont fontWithName:@"Arial" size:15];
        [self addSubview:_tempValue];
        _humiValue = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3 , self.frame.size.height/2 - 10, 120, 20)];
        _humiValue.font =[UIFont fontWithName:@"Arial" size:15];
        _humiValue.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_humiValue];
        _labelTime = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 150, self.frame.size.height/2 - 10, 150, 20)];
        _labelTime.font =[UIFont fontWithName:@"Arial" size:15];
        _labelTime.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_labelTime];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
