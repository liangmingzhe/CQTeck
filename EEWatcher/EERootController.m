//
//  EERootController.m
//  EEWatcher
//
//  Created by 梁明哲 on 16/8/9.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "EERootController.h"
#import "EEMainPageView.h"
#import "EEAlarmPageView.h"
#import "EEMoreSetPageView.h"
#import "MMDrawerController.h"
#import "LeftTableView.h"
#import "Language.h"
#import "Request.h"
@interface EERootController (){
    UINavigationController* navigationData;
    UINavigationController* navigationAlarm;
    UINavigationController* navigationMore;
    NSUserDefaults* defaults;
    UITabBarController* tab;

}
@property (nonatomic,strong) MMDrawerController * drawerController;
@end

@implementation EERootController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"navgationbar"] forBarPosition:0 barMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];//导航条左侧字体变白色
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor clearColor],NSForegroundColorAttributeName,nil]];//导航条title颜色设为白色
    self.view.backgroundColor = [UIColor clearColor];
    defaults = [NSUserDefaults standardUserDefaults];

    // Do any additional setup after loading the view.
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor lightGrayColor], NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateNormal];
    UIColor *titleHighlightedColor = [UIColor blackColor];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       titleHighlightedColor, NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateSelected];
    //当前点击的tabbar文字颜色
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:39.0/255.0 green:102.0/255.0 blue:162.0/255.0 alpha:1], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    UIViewController* RealItem = [[EEMainPageView alloc]init];
    navigationData = [[UINavigationController alloc]initWithRootViewController:RealItem];
    navigationData.tabBarItem.image = [[UIImage imageNamed:@"main1udata"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navigationData.tabBarItem.selectedImage = [[UIImage imageNamed:@"main1data"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIViewController* AlarmItem = [[EEAlarmPageView alloc]init];
    navigationAlarm = [[UINavigationController alloc]initWithRootViewController:AlarmItem];
    navigationAlarm.tabBarItem.image = [[UIImage imageNamed:@"main2ualarm"]  imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    navigationAlarm.tabBarItem.selectedImage = [[UIImage imageNamed:@"main2alarm"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    UIViewController* MoreItem = [[EEMoreSetPageView alloc]init];
    navigationMore = [[UINavigationController alloc]initWithRootViewController:MoreItem];
    navigationMore.tabBarItem.image = [[UIImage imageNamed:@"main3umore"]  imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    navigationMore.tabBarItem.selectedImage = [[UIImage imageNamed:@"main3more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    navigationData.tabBarItem.title = [NSString stringWithFormat:@"%@",LocalizedString(@"Data_RealData")];
    navigationAlarm.tabBarItem.title = [NSString stringWithFormat:@"%@",LocalizedString(@"Data_Alarm")];
    
    navigationMore.tabBarItem.title = [NSString stringWithFormat:@"%@",LocalizedString(@"Data_More")];
    
    tab = [[UITabBarController alloc]init];
    tab.viewControllers = @[navigationData,navigationAlarm,navigationMore];
    
    LeftTableView* leftView = [[LeftTableView alloc]init];
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:tab
                             leftDrawerViewController:leftView];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];//打开关闭手势
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeTapCenterView];//打开关闭手势
    [UIApplication sharedApplication].delegate.window.rootViewController = self.drawerController;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
