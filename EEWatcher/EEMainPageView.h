//
//  EEMainPageView.h
//  EEWatcher
//
//  Created by 梁明哲 on 16/7/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "AFNetworking/AFNetworking.h"
#import "BlockCell.h"
#import "ListCell.h"
#import "HeaderView.h"
#import "DeviceSecondStageMenuController.h"
#import "ChooseAddStyleViewController.h"
#import "cqtekHeader.pch"

@interface EEMainPageView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
@property (strong,nonatomic)NSMutableArray* DeviceArray;//实时数据的数组
@property (strong,nonatomic)NSMutableArray* deviceListArray;//显示名称列表
@property (strong,nonatomic)NSMutableArray* deviceList;//设备列表数组
@property (strong,nonatomic)NSMutableDictionary* selectedDevice; //选中设备
 
singleton_h(Instance);
@end
