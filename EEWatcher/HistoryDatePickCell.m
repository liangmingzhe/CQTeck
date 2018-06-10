//
//  HistoryDatePickCell.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/2/5.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "HistoryDatePickCell.h"

@implementation HistoryDatePickCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self.backgroundColor = [UIColor clearColor];
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _labelName = [[UILabel alloc]initWithFrame:CGRectMake(5, self.frame.size.height/2 - 15, self.frame.size.width/2 - 5, 30)];
        _labelName.font = [UIFont fontWithName:@"Arial" size:18];
        [self addSubview:_labelName];
        
        _labelValue = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, self.frame.size.height/2 - 10, [UIScreen mainScreen].bounds.size.width/2 - 5, 20)];
        _labelValue.textAlignment = NSTextAlignmentRight;
        _labelValue.font = [UIFont fontWithName:@"Arial" size:16];
        [self addSubview:_labelValue];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
