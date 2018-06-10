//
//  WhatisRTUViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/11/3.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "WhatisRTUViewController.h"
#import "Language.h"
@interface WhatisRTUViewController ()

@end

@implementation WhatisRTUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    [self ImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImageView*)ImageView{
    UIImageView* backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    backImageView.image = [UIImage imageNamed:@"rtuExplame.png"];
    [self.view addSubview:backImageView];
    UIButton* BackButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/8, [UIScreen mainScreen].bounds.size.height/4*3 - 60, [UIScreen mainScreen].bounds.size.width/4*3, 40)];
    [BackButton setTitle:LocalizedString(@"l_return") forState:UIControlStateNormal];
    BackButton.backgroundColor = [UIColor colorWithRed:59/255.0 green:100/255.0 blue:189/255.0 alpha:1];
    [BackButton addTarget:self action:@selector(backHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:BackButton];
    
    return backImageView;
}

- (void)backHandle{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
