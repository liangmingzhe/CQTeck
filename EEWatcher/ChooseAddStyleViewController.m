//
//  ChooseAddStyleViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/2/20.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "ChooseAddStyleViewController.h"
#import "AddDevViewController.h"
#import "SNNumberViewController.h"
#import "Language.h"
@interface ChooseAddStyleViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UIButton* WifiDevice;
    UIButton* EthDevice;
    UITableView* table;
    NSUserDefaults* defaults;
}

@end

@implementation ChooseAddStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    self.navigationItem.title = LocalizedString(@"l_add_mode");
    self.view.backgroundColor = [UIColor whiteColor];
    [self theTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    
}
//懒加载tableView
- (UITableView*)theTableView{
    table = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    return table;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* idr = @"idr";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:idr];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idr];
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = LocalizedString(@"l_wireless");
            cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20];
            UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(120, cell.frame.size.height/2 - 15,cell.frame.size.width/3*2, 50)];
            tips.text = LocalizedString(@"t_tips_1");
            tips.textColor = [UIColor lightGrayColor];
            tips.numberOfLines = 2;
            [cell addSubview:tips];
            
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = LocalizedString(@"universal");
            cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20];
            UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(120, cell.frame.size.height/2 - 15,cell.frame.size.width/3*2, 50)];
            tips.text = LocalizedString(@"t_tips_2");
            tips.textColor = [UIColor lightGrayColor];
            tips.numberOfLines = 2;
            [cell addSubview:tips];

            
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        NSLog(@"");
        AddDevViewController* wifi = [[AddDevViewController alloc]init];
        [self.navigationController pushViewController:wifi animated:YES];

    }else if (indexPath.row == 1){
        [defaults setObject:nil forKey:@"barCode"];
        [defaults setObject:nil forKey:@"acCode"];
        
        SNNumberViewController *eth = [[SNNumberViewController alloc]init];
        [self.navigationController pushViewController:eth animated:YES];
        
    }else{
      
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
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
