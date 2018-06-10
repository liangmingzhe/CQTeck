//
//  CustmerServiceView.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/12/10.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "CustmerServiceView.h"
#import "EEMoreSetPageView.h"
@interface CustmerServiceView ()

@end

@implementation CustmerServiceView

- (void)viewDidLoad {
    [super viewDidLoad];
    //技术支持QQ。电话，邮件。产品使用介绍文档等
    self.view.opaque = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.navigationItem.title = NSLocalizedString(@"l_AfterService", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UILabel* supportMail = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/8, [UIScreen mainScreen].bounds.size.height/4, [UIScreen mainScreen].bounds.size.width/4*3, 30)];
    supportMail.font = [UIFont fontWithName:@"Arial" size:18];
    supportMail.text = @"服务邮箱：cqtek1234@126.com";
    [self.view addSubview:supportMail];
    
}
- (void)viewWillAppear:(BOOL)animated{
 
}

- (void)goBackView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
