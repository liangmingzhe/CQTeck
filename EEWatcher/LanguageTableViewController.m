//
//  LanguageTableViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/12/28.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "LanguageTableViewController.h"
#import "GeneralViewController.h"
#import "EEMoreSetPageView.h"
#import "ScottAlertController.h"
#import "EERootController.h"
#import "Language.h"
#import "AppDelegate.h"
#import "EERootController.h"
#import "EEMainPageView.h"
#import "EEAlarmPageView.h"
#import "EEMoreSetPageView.h"
@interface LanguageTableViewController (){
    UITableView* languageTable;
}
@property(nonatomic,assign)NSInteger checkedRow;
@property(nonatomic,assign)NSInteger sectionNow;
@end

@implementation LanguageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton* SetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0 , 60, 30)];
    [SetButton setTitle:LocalizedString(@"l_done") forState:normal];
    [SetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [SetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [SetButton addTarget:self action:@selector(changeLanguage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:SetButton];
    self.navigationItem.rightBarButtonItem = rightButton;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // 监控语言切换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChange:) name:NotificationLanguageChanged object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* idr = @"lang";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lang"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idr];
    }
    NSString* languageFlag = [Language getUserLanguage];
    
    if (indexPath.row == 0) {
        if ([languageFlag isEqualToString:@"en"]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        cell.textLabel.text = @"汉语简体";
    }else if(indexPath.row == 1){
        if ([languageFlag isEqualToString:@"en"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _checkedRow = indexPath.row;
            _sectionNow = indexPath.section;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = @"English";
        
    }
    
    return cell;
}

- (void)changeLanguage{
    
    NSString* curLang = [Language getUserLanguage];
    if ([curLang isEqualToString: EN]) {
        if(_checkedRow == 0){
            [Language setUserlanguage:CNS];
        }else{
            [self AlertMessage:@"当前"];

        }

        
    }else{

        if(_checkedRow == 0){
            [self AlertMessage:@"当前"];
        }else{

            [Language setUserlanguage:EN];
        }
        

    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *lastIndexPath=[NSIndexPath indexPathForRow:_checkedRow inSection:_sectionNow];
    UITableViewCell *lastCell=[tableView cellForRowAtIndexPath:lastIndexPath];
    lastCell.accessoryType=UITableViewCellAccessoryNone;
    // 设置当前选中的row 的checkMark
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType=UITableViewCellAccessoryCheckmark;
    
    // 重置 _rowNow _secitonNow  为当前选中改行的section 和 row
    _checkedRow = indexPath.row;
    _sectionNow = indexPath.section;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)languageChange:(NSNotification *)note{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    EERootController* root = [[EERootController alloc]init];
    root = (EERootController*)appDelegate.window.rootViewController;

    
}

- (void)AlertMessage:(NSString*)message{
    
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    }];
    [alertView addAction:action];
    
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}


@end
