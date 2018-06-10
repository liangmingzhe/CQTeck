//
//  GeneralViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/12/28.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "GeneralViewController.h"
#import "AccountCellTableViewCell.h"
#import "LanguageTableViewController.h"
#import "Language.h"
@interface GeneralViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *generalTable;

@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _generalTable.dataSource = self;
    _generalTable.delegate = self;
    self.navigationItem.title = LocalizedString(@"General");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* idr = @"general";
    AccountCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idr];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (cell == nil) {
       
        cell = [[AccountCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idr];
        
    }
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.AccountIcon.image = [UIImage imageNamed:@"main3mailbox"];
        cell.AccountValue.text = LocalizedString(@"Language");
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        LanguageTableViewController* lang = [[LanguageTableViewController alloc]init];
        [self.navigationController pushViewController:lang animated:YES];
    }
}


@end
