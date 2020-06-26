//
//  ModifyDevNameCell.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/11/30.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "ModifyDevNameCell.h"

@implementation ModifyDevNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
//cell初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self.backgroundColor = [UIColor clearColor];
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _DevTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width/2, self.frame.size.height)];
        _DevTextField.font = [UIFont fontWithName:@"Arial" size:18];
        _DevTextField.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_DevTextField];
        _DeleteTextField =[[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 30, self.frame.size.height/2 - 10, 20, 20)];
        [_DeleteTextField setImage:[UIImage imageNamed:@"deleteblack"] forState:UIControlStateNormal];
        [_DeleteTextField setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateHighlighted];
        [self addSubview:_DeleteTextField];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
