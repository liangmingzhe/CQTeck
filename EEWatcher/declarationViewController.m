//
//  declarationViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2018/1/3.
//  Copyright © 2018年 ChengQian. All rights reserved.
//

#import "declarationViewController.h"

@interface declarationViewController (){
    UIButton* backBtn;
}

@end

@implementation declarationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    myWebView.backgroundColor = [UIColor whiteColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"免责声明" ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [myWebView loadRequest:request];
    //使文档的显示范围适合UIWebView的bounds
    [myWebView setScalesPageToFit:YES];
    [self.view addSubview:myWebView];
    [self backBtnInit];
}

- (UIButton*)backBtnInit{
    backBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 20, 40, 40)];
    [backBtn setImage:[UIImage imageNamed:@"main2deleteblack"] forState:UIControlStateNormal];
//    backBtn.backgroundColor = [UIColor redColor];
    [backBtn addTarget:self action:@selector(backHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    return backBtn;
}
- (void)backHandle{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
