//
//  ListCell.h
//  CQTechApp
//
//  Created by 梁明哲 on 2016/12/13.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCell : UICollectionViewCell{
    CGRect f;
}
@property (nonatomic,strong) UILabel* title;
@property (nonatomic,strong) UILabel* temp;
@property (nonatomic,strong) UILabel* humi;
@property (nonatomic,strong) UILabel* lastTime;
@property (nonatomic,strong) UIView* backView;
@property (nonatomic,strong) UIImageView* OnlineImage;
@property (nonatomic,strong) UIImageView* tempStatusImage;
@property (nonatomic,strong) UIImageView* humiStatusImage;

@end
