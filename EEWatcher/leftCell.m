//
//  leftCell.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/3.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "leftCell.h"

@implementation leftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        _imageItem = [[UIImageView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/2 - 15, 30, 30)];
        _labelName = [[UILabel alloc]initWithFrame:CGRectMake(35, self.frame.size.height/2 - 22.5, self.frame.size.width - 35, 50)];
        _labelName.textColor = [UIColor lightGrayColor];
        _labelName.font = [UIFont fontWithName:@"Arial" size:20];
        _labelName.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_labelName];
  //      [self addSubview:_imageItem];
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
