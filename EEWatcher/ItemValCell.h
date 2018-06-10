//
//  ItemValCell.h
//  CQTechApp
//
//  Created by 梁明哲 on 2016/12/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemValCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *ItemName;
@property (strong, nonatomic) IBOutlet UITextField *ItemVal;
@property (strong, nonatomic) IBOutlet UILabel *Unit;

@end
