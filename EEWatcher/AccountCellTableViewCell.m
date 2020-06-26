//
//  AccountCellTableViewCell.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/12.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "AccountCellTableViewCell.h"

@implementation AccountCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self.backgroundColor = [UIColor clearColor];
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _AccountIcon = [[UIImageView alloc]initWithFrame:CGRectMake(17, self.frame.size.height/2 - 12.5, 25, 25)];
        _AccountValue = [[UILabel alloc]initWithFrame:CGRectMake(45, self.frame.size.height/2 - 15, self.frame.size.width - 35, 30)];
        _AccountValue.textColor = [UIColor blackColor];
        _AccountValue.font = [UIFont fontWithName:@"Arial" size:18];
        _AccountValue.backgroundColor = [UIColor whiteColor];
        [self addSubview:_AccountValue];
        [self addSubview:_AccountIcon];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
