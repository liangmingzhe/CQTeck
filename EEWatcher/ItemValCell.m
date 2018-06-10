//
//  ItemValCell.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/12/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "ItemValCell.h"

@implementation ItemValCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1].CGColor;
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
