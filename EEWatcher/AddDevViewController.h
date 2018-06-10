//
//  AddDevViewController.h
//  CQTechApp
//
//  Created by 梁明哲 on 2016/11/29.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "cqtekHeader.pch"
@interface AddDevViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic,strong)UITextField* SSIDText;
@property (nonatomic,strong)UITextField* PasswordText;
@property (nonatomic,strong)NSMutableArray* listArray;
singleton_h(InstanceThree);
@end
