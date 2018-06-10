//
//  AlarmCell.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/11/30.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "AlarmCell.h"

@implementation AlarmCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_errorMessage sizeToFit];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self.backgroundColor = [UIColor clearColor];
    UIImageView* back = [[UIImageView alloc]initWithFrame:self.frame];
    back.image = [UIImage imageNamed:@"cellback"];
    [self addSubview:back];
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _icon = [[UIImageView alloc]initWithFrame:CGRectMake(5, self.frame.size.height/2 - 12, 24, 24)];
        [self addSubview:_icon];
        _errorMessage = [[UILabel alloc]initWithFrame:CGRectMake(_icon.frame.origin.x + _icon.frame.size.width + 5, self.frame.size.height/2 - 15,self.frame.size.width - _icon.frame.size.width - 10,30)];
        _errorMessage.textAlignment = NSTextAlignmentLeft;
        _errorMessage.font = [UIFont fontWithName:@"Arial" size:18];
        [self addSubview:_errorMessage];
        _alarmTime = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 1, [UIScreen mainScreen].bounds.size.width/2 - 3, 15)];
        _alarmTime.font = [UIFont fontWithName:@"Arial" size:10];
        _alarmTime.textAlignment = NSTextAlignmentRight;
        [self addSubview:_alarmTime];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
