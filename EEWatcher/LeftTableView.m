//
//  LeftTableView.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/3.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "LeftTableView.h"
#import "leftCell.h"
#import "AFNetworking/AFNetworking.h"
#import "GetMessage.h"
#import "EEMainPageView.h"
#import "UIViewController+MMDrawerController.h"
#import "ModifyNameView.h"
#import "EERootController.h"
#import "Language.h"
@interface LeftTableView ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView* ItemTableView;
    NSMutableDictionary* areas;
    NSUserDefaults* defaults;
    AFHTTPSessionManager *manager;
    
    NSString* selectArea;
    UITextField* NewTextField;
    UIButton* btn;
    UIButton* listButton;
    UIButton* collectButton;
    NSNotification *notification;
    UILabel*  Label1;//Image
    UIImageView* imageView;
    UILabel* userLabel;
}

@end

@implementation LeftTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1.0];
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
}

//向服务器请求获取区域数据
- (void)requestArea{
    //网络服务参数设置
    NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"]};
    manager.securityPolicy.allowInvalidCertificates = NO;
    [manager POST:cqtek_api parameters:params headers:@{@"type":@"getAreaInfo"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功
        NSMutableDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        areas = JSON;
        [ItemTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
        [GetMessage showMessage:LocalizedString(@"Request_Failed") image:[UIImage imageNamed:@"netErr"]];
    }];
    
}
- (void)modifyAreaName{
    ModifyNameView* modify = [[ModifyNameView alloc]init];
    [self presentViewController:modify animated:YES completion:nil];
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    defaults = [NSUserDefaults standardUserDefaults];
    ItemTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/4, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height/4*3 - 98) style:UITableViewStylePlain];
    ItemTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    ItemTableView.backgroundColor = [UIColor clearColor];
    ItemTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    ItemTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    ItemTableView.layer.borderWidth = 1.0f;
    [ItemTableView setSeparatorColor:[UIColor grayColor]];
    ItemTableView.dataSource = self;
    ItemTableView.delegate = self;
    
    [self.view addSubview:ItemTableView];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(ItemTableView.frame.size.width/2 - 40,ItemTableView.frame.origin.y - 120, 80, 80)];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.image = [UIImage imageNamed:@"headIcon"];
    imageView.layer.cornerRadius = 40;
    imageView.layer.masksToBounds = YES;
    [self.view addSubview:imageView];
    userLabel = [[UILabel alloc]initWithFrame:CGRectMake(ItemTableView.frame.size.width/2 - 40,imageView.frame.origin.y + imageView.frame.size.height + 5, 80, 25)];
    userLabel.textAlignment = NSTextAlignmentCenter;
    userLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:userLabel];
    userLabel.text = [defaults objectForKey:@"cqUser"];
    

    [self requestArea];
    
    btn = [[UIButton alloc]init];
    [btn setImage:[UIImage imageNamed:@"main1leftmodify"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(modifyAreaName) forControlEvents:UIControlEventTouchUpInside];
    
    [btn setFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 99, ItemTableView.frame.size.width, 50)];
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:btn];
    
    
    listButton = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-50, ItemTableView.frame.size.width/2, 50) ];
    [listButton setTitle:LocalizedString(@"l_list") forState:UIControlStateNormal];
    [listButton setImage:[UIImage imageNamed:@"tapbutton"] forState:UIControlStateHighlighted];
    
    listButton.layer.borderWidth = 1;
    listButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    listButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
    [listButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [listButton setTitleColor:[UIColor colorWithRed:36.0/255.0 green:75.0/255.0 blue:120.0/255.0 alpha:1] forState:UIControlStateSelected];
    [self.view addSubview:listButton];
    [listButton addTarget:self action:@selector(listEvent) forControlEvents:UIControlEventTouchUpInside];
    
    collectButton = [[UIButton alloc]initWithFrame:CGRectMake(ItemTableView.frame.size.width/2 - 1, [UIScreen mainScreen].bounds.size.height - 50, ItemTableView.frame.size.width/2, 50)];
    [collectButton setTitle:LocalizedString(@"l_grid") forState:UIControlStateNormal];
    [collectButton setImage:[UIImage imageNamed:@"tapbutton"] forState:UIControlStateHighlighted];
   
    collectButton.layer.borderWidth = 1;
    collectButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    collectButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
    [collectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [collectButton setTitleColor:[UIColor colorWithRed:36.0/255.0 green:75.0/255.0 blue:120.0/255.0 alpha:1] forState:UIControlStateSelected];

    [collectButton addTarget:self action:@selector(collectionEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:collectButton];
    if ([defaults objectForKey:@"show"] == nil){
        [defaults setObject:@"Collection" forKey:@"show"]  ;
    }
    if ([[defaults objectForKey:@"show"] isEqualToString:@"List"]) {
        listButton.selected = YES;
        collectButton.selected = NO;
    }else if ([[defaults objectForKey:@"show"] isEqualToString:@"Collection"]){
        listButton.selected = NO;
        collectButton.selected = YES;

    }


}
- (void)listEvent{
    listButton.selected = YES;
    collectButton.selected = NO;
    [defaults setObject:@"List" forKey:@"show"];
    //创建通知
    notification =[NSNotification notificationWithName:@"zuochouti" object:nil userInfo:nil];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}

- (void)collectionEvent{
    listButton.selected = NO;
    collectButton.selected = YES;
    [defaults setObject:@"Collection" forKey:@"show"];
    //创建通知
    notification =[NSNotification notificationWithName:@"zuochouti" object:nil userInfo:nil];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [ItemTableView removeFromSuperview];
    [btn removeFromSuperview];
    [Label1 removeFromSuperview];
    [listButton removeFromSuperview];
    [imageView removeFromSuperview];
    [collectButton removeFromSuperview];
    [userLabel removeFromSuperview];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if(section == 1){
        return [[areas objectForKey:@"array"] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }else{
        return 20;
    }
    
}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0    ;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"leftCell";
    leftCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil)
    {
        cell = [[leftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//不可选择不可点击
    }
    if (indexPath.section == 0) {
        //cell右侧无箭头
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        cell.labelName.text = LocalizedString(@"l_alldevice");
        if ([defaults objectForKey:@"areaAll"] == nil){
            cell.labelName.textColor = [UIColor colorWithRed:36/255.0 green:75/255.0 blue:157/255.0 alpha:1];
        }else{
            cell.labelName.textColor = [UIColor whiteColor];
        }
        
    }else{
        cell.labelName.text = [areas objectForKey:@"array"][indexPath.row];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        if ([[defaults objectForKey:@"areaAll"] isEqualToString: [areas objectForKey:@"array"][indexPath.row]]) {
            cell.labelName.textColor = [UIColor colorWithRed:36/255.0 green:75/255.0 blue:157/255.0 alpha:1];
            selectArea = [defaults objectForKey:@"areaAll"];
        }
        else{
            cell.labelName.textColor = [UIColor whiteColor];
        }
    }
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];//创建一个视图
    headerView.backgroundColor = [UIColor colorWithRed:122.0/255.0 green:125.0/255.0 blue:127.0/255.0 alpha:1.0];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.view.frame.size.width - 5, 20)];
    nameLabel.font = [UIFont fontWithName:@"Arial" size:12];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = [NSString stringWithFormat:@"设备"];
    [headerView addSubview:nameLabel];
    if (section == 0){
        nameLabel.text = [NSString stringWithFormat:@"%@",LocalizedString(@"l_all")];
    }else{
        nameLabel.text = [NSString stringWithFormat:@"%@",LocalizedString(@"l_Area")];
    }
    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [defaults setObject:nil forKey:@"areaAll"];
    }else{
        [defaults setObject:[areas objectForKey:@"array"][indexPath.row] forKey:@"areaAll"];
        [defaults synchronize];
    }
    //创建通知
    notification =[NSNotification notificationWithName:@"zuochouti" object:nil userInfo:nil];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}

@end
