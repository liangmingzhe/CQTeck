//
//  ModifyThresholdView.m
//  CQTechApp
//
//  Created by 梁明哲 on 2016/12/1.
//  Copyright © 2016年 ChengQian. All rights reserved.
//

#import "ModifyThresholdView.h"
#import "GetMessage.h"
//#import "MBProgressHUD.h"
#import "UITextField+Extend.h"
#import "ScottAlertController.h"
#import "ItemValCell.h"
#import "Language.h"

#define kItemValCellID @"ItemValCell"
@interface ModifyThresholdView ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView* ItemTableView;
    NSMutableDictionary* Dic;
    NSMutableDictionary* Dic2;
    NSMutableDictionary *JSON;//http请求返回的JSON格式数据
    ItemValCell* cell;
    AFHTTPSessionManager* manager;
    NSUserDefaults* defaults;
    NSTimer* TipsTimer;
    UIView * CQKeyboard;
}

@end

@implementation ModifyThresholdView

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    //title背景
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = LocalizedString(@"l_threshold");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    
    UIButton* SetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0 , 60, 30)];
    [SetButton setTitle:LocalizedString(@"l_done") forState:normal];
    [SetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [SetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [SetButton addTarget:self action:@selector(ThredSetAndGoBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:SetButton];
    self.navigationItem.rightBarButtonItem = rightButton;


    ItemTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 300)];
    ItemTableView.backgroundColor = [UIColor whiteColor];
    ItemTableView.opaque = YES;
    ItemTableView.dataSource = self;
    ItemTableView.delegate = self;
    ItemTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //ItemTableView.separatorStyle = UITableViewCellSelectionStyleNone;//   取消分割线
    [self.view addSubview:ItemTableView];
    [ItemTableView registerNib:[UINib nibWithNibName:kItemValCellID bundle:nil] forCellReuseIdentifier:kItemValCellID];
    
    //提示
    UILabel* tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 310, [UIScreen mainScreen].bounds.size.width - 10, 80)];
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.textColor = [UIColor lightGrayColor];
    tipsLabel.numberOfLines = 3;
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tipsLabel.text = LocalizedString(@"t_the_threhold_message");
    [self.view addSubview:tipsLabel];

    
    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    Dic = [[NSMutableDictionary alloc]initWithCapacity:0];
 
    CQKeyboard = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 280 - 60, [UIScreen mainScreen].bounds.size.width,280)];
//    CQKeyboard.backgroundColor= [UIColor colorWithRed:36/255.0 green:75/255.0 blue:120/255.0 alpha:1];
//    [self.view addSubview:CQKeyboard];
    
    [self CreateKeyBoard];
    
}

- (void)viewWillAppear:(BOOL)animated{
    NSDictionary *params = @{@"snaddr": [defaults objectForKey:@"snaddr"]};
    [manager POST:cqtek_api parameters:params headers:@{@"type":@"getThreshold"} progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功:%@", responseObject);
        JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([[JSON objectForKey:@"code"] intValue] == 0) {
            Dic2 = [JSON objectForKey:@"array"];
        }else{
            [GetMessage showMessage:LocalizedString(@"Network_Error") image:[UIImage imageNamed:@"netErr.png"]];
        }
        //        timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(RequestDevDate) userInfo:nil repeats:YES];
        //        [timer fire];
        [ItemTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@", error.description);
        [GetMessage showMessage:LocalizedString(@"Network_Error") image:[UIImage imageNamed:@"netErr.png"]];
    }];
    if ([[defaults objectForKey:@"authority"]isEqualToString:@"1"]){
    
    }else{
        [GetMessage showMessage:LocalizedString(@"t_no_authority") image:[UIImage imageNamed:@"headIcon.png"]];
    }
    
}
- (void)ThredSetAndGoBack{
    if ([[defaults objectForKey:@"authority"] isEqualToString:@"1"]) {
        for (ItemValCell *cell2 in [cell.superview subviews]) {
            if ([cell2.ItemVal isFirstResponder]) {
                //隐藏键盘
                for (ItemValCell *cell2 in [cell.superview subviews]) {
                    [cell2.ItemVal resignFirstResponder];
                    break;
                }
            }
     
        if (cell2.ItemVal.tag == 2|cell2.ItemVal.tag == 5) {
            if (cell2.ItemVal.text.length > 3) {
                cell2.ItemVal.text = [cell2.ItemVal.text substringToIndex:3];
            }
            
        }
        else {
            if (cell2.ItemVal.text.length > 5) {
                cell2.ItemVal.text = [cell2.ItemVal.text substringToIndex:5];
            }
         
        }
        NSIndexPath* indexPath = [ItemTableView indexPathForCell:cell2];
        switch (indexPath.row) {
            case 0:
                [Dic2 setObject:cell2.ItemVal.text forKey:@"maxTemp"];
                NSLog(@"%@",cell2.ItemVal.text);
                break;
            case 1:
                [Dic2 setObject:cell2.ItemVal.text forKey:@"minTemp"];
                NSLog(@"%@",cell2.ItemVal.text);
                break;
            case 2:
                //温度回差
                [Dic2 setObject:cell2.ItemVal.text forKey:@"tempHC"];
                NSLog(@"%@",cell2.ItemVal.text);
                break;
            case 3:
                [Dic2 setObject:cell2.ItemVal.text forKey:@"maxHumi"];
                NSLog(@"%@",cell2.ItemVal.text);
                break;
            case 4:
                [Dic2 setObject:cell2.ItemVal.text forKey:@"minHumi"];
                NSLog(@"%@",cell2.ItemVal.text);
                break;
            case 5:
                //湿度回差
                [Dic2 setObject:cell2.ItemVal.text forKey:@"humiHC"];
                NSLog(@"%@",cell2.ItemVal.text);
                break;
                
            default:
                break;
        }
            if (indexPath.row == 0) {
                break;
            }

    }
        // 报警的 阈值 ，低温不能设置地比高温 的数据高 同理
        manager = [[AFHTTPSessionManager manager]init];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 15.0;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
        manager.securityPolicy.allowInvalidCertificates = NO;
        NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:[defaults objectForKey:@"cqUser"],@"user",[defaults objectForKey:@"snaddr"],@"snaddr",[Dic2 objectForKey:@"maxTemp"],@"maxTemp",[Dic2 objectForKey:@"minTemp"],@"minTemp",[Dic2 objectForKey:@"maxHumi"],@"maxHumi",[Dic2 objectForKey:@"minHumi"],@"minHumi",[Dic2 objectForKey:@"tempHC"],@"tempHC",[Dic2 objectForKey:@"humiHC"],@"humiHC", nil];
        if ([[Dic2 objectForKey:@"humiHC"]doubleValue] > 5) {
            [self AlertMessage:LocalizedString(@"t_temp_huicha")];
        }else if([[Dic2 objectForKey:@"tempHC"]doubleValue] > 1){
            [self AlertMessage:LocalizedString(@"t_humi_huicha")];
        }else if([[Dic2 objectForKey:@"maxTemp"]doubleValue] > 500){
            [self AlertMessage:LocalizedString(@"t_temp_max")];
        }else if([[Dic2 objectForKey:@"maxTemp"]doubleValue] <= [[Dic2 objectForKey:@"minTemp"]doubleValue]){
            [self AlertMessage:LocalizedString(@"t_temp_max_min")];
        }else if([[Dic2 objectForKey:@"minTemp"]doubleValue] < - 200){
            [self AlertMessage:LocalizedString(@"t_temp_min")];
        }else if([[Dic2 objectForKey:@"minTemp"]doubleValue] >= [[Dic2 objectForKey:@"maxTemp"]doubleValue]){
            [self AlertMessage:LocalizedString(@"t_temp_min_max")];
        }else if([[Dic2 objectForKey:@"maxHumi"]doubleValue] > 99.99){
            [self AlertMessage:LocalizedString(@"t_humi_max")];
        }else if([[Dic2 objectForKey:@"maxHumi"]doubleValue] <= [[Dic2 objectForKey:@"minHumi"]doubleValue]){
            [self AlertMessage:LocalizedString(@"t_humi_min")];
        }else if([[Dic2 objectForKey:@"minHumi"]doubleValue] < 0){
            [self AlertMessage:LocalizedString(@"t_humi_min_zero")];
        }else if([[Dic2 objectForKey:@"minHumi"]doubleValue] >= [[Dic2 objectForKey:@"maxHumi"]doubleValue]){
            [self AlertMessage:LocalizedString(@"t_humi_min_max")];
        }else{
            [manager POST:cqtek_api parameters:params headers:@{@"type":@"modifyTH"} progress:^(NSProgress * _Nonnull uploadProgress) {
                nil;
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"请求成功:%@", responseObject);
                NSMutableDictionary*JSON2 = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if ([[JSON2 objectForKey:@"code"] intValue] == 0) {
                    [self AlertMessage:LocalizedString(@"l_modifysuccess")];
                    //修改成功后返回所有数据
                    Dic2 = [JSON2 objectForKey:@"array"];
                    [ItemTableView reloadData];
                }else{
                    [self AlertMessage:[NSString stringWithFormat:@"%@,%@",LocalizedString(@"l_modifyfailed"),[JSON2 objectForKey:@"error"]]];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"请求失败:%@", error.description);
                [GetMessage showMessage:LocalizedString(@"Network_Error") image:[UIImage imageNamed:@"netErr.png"]];
                
            }];
            
        }
    }else{
        [self AlertMessage:LocalizedString(@"t_no_authority")];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    cell = [tableView dequeueReusableCellWithIdentifier:kItemValCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.ItemVal.tag = indexPath.row;
    cell.ItemVal.delegate = self;
    cell.ItemVal.inputView = CQKeyboard;
    
//    [cell.ItemVal addTarget:self action:@selector(thredTextFieldWithText:) forControlEvents:UIControlEventEditingChanged];
    
    switch (indexPath.row) {
        case 0:
            cell.ItemName.text = LocalizedString(@"l_maxTemp");
            cell.ItemVal.text = [Dic2 objectForKey:@"maxTemp"];
            cell.Unit.text = @"℃";
            break;
        case 1:
            cell.ItemName.text = LocalizedString(@"l_minTemp");
            cell.ItemVal.text = [Dic2 objectForKey:@"minTemp"];
            cell.Unit.text = @"℃";
            break;
        case 2:
            cell.ItemName.text = LocalizedString(@"l_TempHuiCha");
            cell.ItemVal.text = [Dic2 objectForKey:@"tempHC"];
            cell.Unit.text = @"℃";
            
            cell.ItemVal.enabled = NO;
            cell.ItemVal.textColor = [UIColor lightGrayColor];
            break;
        case 3:
            cell.ItemName.text = LocalizedString(@"l_maxHumi");
            cell.ItemVal.text = [Dic2 objectForKey:@"maxHumi"];
            cell.Unit.text = @"RH%";
            break;
        case 4:
            cell.ItemName.text = LocalizedString(@"l_minHumi");
            cell.ItemVal.text = [Dic2 objectForKey:@"minHumi"];
            cell.Unit.text = @"RH%";
            break;
        case 5:
            cell.ItemName.text = LocalizedString(@"l_HumiHuiCha");
            cell.ItemVal.text = [Dic2 objectForKey:@"humiHC"];
            cell.Unit.text = @"RH%";

            cell.ItemVal.enabled = NO;
            cell.ItemVal.textColor = [UIColor lightGrayColor];

            break;
            
}
    if([[defaults objectForKey:@"authority"]intValue] == 1){
        
    }else{
        //无权限不可修改
           cell.ItemVal.enabled = NO;
    }
    return cell;
}
- (void)thredTextFieldWithText:(UITextField *)textField{
    
    if (textField.tag == 2|textField.tag == 5) {
        if (textField.text.length > 3) {
            textField.text = [textField.text substringToIndex:3];
        }
    }
    else {
        if (textField.text.length > 5) {
            textField.text = [textField.text substringToIndex:5];
        }
    }
    switch (textField.tag) {
        case 0:
            [Dic2 setObject:textField.text forKey:@"maxTemp"];
            NSLog(@"%@",textField.text);
            break;
        case 1:
            [Dic2 setObject:textField.text forKey:@"minTemp"];
            NSLog(@"%@",textField.text);
            break;
        case 2:
            //温度回差
            [Dic2 setObject:textField.text forKey:@"tempHC"];
            NSLog(@"%@",textField.text);
            break;
        case 3:
            [Dic2 setObject:textField.text forKey:@"maxHumi"];
            NSLog(@"%@",textField.text);
            break;
        case 4:
            [Dic2 setObject:textField.text forKey:@"minHumi"];
            NSLog(@"%@",textField.text);
            break;
        case 5:
            //湿度回差
            [Dic2 setObject:textField.text forKey:@"humiHC"];
            NSLog(@"%@",textField.text);
            break;
            
        default:
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 2|indexPath.row == 5) {
        
    }else{
        [cell.ItemVal endEditing:YES];
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
 
}

//限制text长度
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    /*
     1.start with zero 0000.....was forbiden
     2.have no '.' & the first character is not '0'
     3.limit the count of '.'
     4.if the first character is '0',then the next one must be '.'
     5.condition like "0.0.0"was forbiden
     6.limit the num of zero after '.'
     */
    if(((string.intValue<0) || (string.intValue>9))){
        //MyLog(@"====%@",string);
        if ((![string isEqualToString:@"."])) {
            return NO;
        }
        return NO;
    }
    NSMutableString * futureString = [NSMutableString stringWithString:textField.text];
    [futureString  insertString:string atIndex:range.location];
    
    NSInteger dotNum = 0;
    NSInteger flag=0;
    const NSInteger limited = 2;
    if((int)futureString.length>=1){
        
        if([futureString characterAtIndex:0] == '.'){//the first character can't be '.'
            return NO;
        }
        if((int)futureString.length>=2){//if the first character is '0',the next one must be '.'
            if(([futureString characterAtIndex:1] != '.'&&[futureString characterAtIndex:0] == '0')){
                return NO;
            }
        }
    }
    NSInteger dotAfter = 0;
    @autoreleasepool{
        for (int i = (int)futureString.length-1; i>=0; i--) {
            if ([futureString characterAtIndex:i] == '.') {
                dotNum ++;
                dotAfter = flag+1;
                if (flag > limited) {
                    return NO;
                }
                if(dotNum>1){
                    return NO;
                }
            }
            flag++;
        }
    }

    if(futureString.length - dotAfter > 5){
        return NO;
    }
    return YES;
}


- (void)AlertMessage:(NSString*)message{
    //退出账户
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
    }];
    [alertView addAction:action];
    
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
    
}


- (void)Handle{
    [TipsTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

}

- (void)CreateKeyBoard{
    float buttonWidth = CQKeyboard.frame.size.width/3;
    float buttonHeight =CQKeyboard.frame.size.height/5;
    [self createButton:LocalizedString(@"l_hide") x:1 y:1 width:buttonWidth height:buttonHeight];
    [self createButton:LocalizedString(@"l_back") x:2 y:1 width:buttonWidth height:buttonHeight];
    [self createButton:LocalizedString(@"l_clear") x:3 y:1 width:buttonWidth height:buttonHeight];

    [self createButton:@"7" x:1 y:2 width:buttonWidth height:buttonHeight];
    [self createButton:@"8" x:2 y:2 width:buttonWidth height:buttonHeight];
    [self createButton:@"9" x:3 y:2 width:buttonWidth height:buttonHeight];
    
    [self createButton:@"4" x:1 y:3 width:buttonWidth height:buttonHeight];
    [self createButton:@"5" x:2 y:3 width:buttonWidth height:buttonHeight];
    [self createButton:@"6" x:3 y:3 width:buttonWidth height:buttonHeight];

    [self createButton:@"1" x:1 y:4 width:buttonWidth height:buttonHeight];
    [self createButton:@"2" x:2 y:4 width:buttonWidth height:buttonHeight];
    [self createButton:@"3" x:3 y:4 width:buttonWidth height:buttonHeight];
    
    [self createButton:@"." x:1 y:5 width:buttonWidth height:buttonHeight];
    [self createButton:@"0" x:2 y:5 width:buttonWidth height:buttonHeight];
    [self createButton:@"-" x:3 y:5 width:buttonWidth height:buttonHeight];


}
- (UIButton*) createButton:(NSString*)value x:(int)x y:(int)y width:(float)width height:(float)height{
    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake((x-1)*width, (y-1)*height, width, height)];
    
    button.backgroundColor = [UIColor clearColor];
//    button.layer.borderWidth = 0.4;
//    button.layer.borderColor = [UIColor blackColor].CGColor;
    if ([value isEqualToString:LocalizedString(@"l_hide")]) {
        [button setImage:[UIImage imageNamed:@"selectBtn"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"code2Btn"] forState:UIControlStateNormal];

        button.tag = 21;
    }else if([value isEqualToString:LocalizedString(@"l_back")]){
        [button setImage:[UIImage imageNamed:@"selectBtn"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"code2Btn"] forState:UIControlStateNormal];

        button.tag = 22;
    }else if([value isEqualToString:LocalizedString(@"l_clear")]){
        button.tag = 23;
        [button setImage:[UIImage imageNamed:@"selectBtn"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"code2Btn"] forState:UIControlStateNormal];

    }else if([value isEqualToString:@"-"]){
        button.tag = 30;
        [button setImage:[UIImage imageNamed:@"codeBtn"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"ucodeBtn"] forState:UIControlStateNormal];

    }else if([value isEqualToString:@"."]){
        button.tag = 11;
        [button setImage:[UIImage imageNamed:@"codeBtn"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"ucodeBtn"] forState:UIControlStateNormal];

    }else{
        [button setImage:[UIImage imageNamed:@"codeBtn"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"ucodeBtn"] forState:UIControlStateNormal];
        button.tag = [value intValue];
    }
    
    [CQKeyboard addSubview:button];
        
    UILabel * showLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    showLabel.textAlignment = NSTextAlignmentCenter;
    showLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    showLabel.text = value;
    showLabel.textColor = [UIColor whiteColor];
    [button addSubview:showLabel];
    [button addTarget:self action:@selector(padHandler:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (id)padHandler:(UIButton*)btn{
    //遍历tableView
    for (ItemValCell *cell2 in [cell.superview subviews]) {
        NSString* Value = cell2.ItemVal.text;
        //如果是当前第一响应
        if ([cell2.ItemVal isFirstResponder]) {
            if (btn.tag == 21) {
                //隐藏键盘
                for (ItemValCell *cell2 in [cell.superview subviews]) {
                    if(cell2.ItemVal.isFirstResponder){
                        [cell2.ItemVal resignFirstResponder];
                        break;
                    }
                }
                break;
            }else if(btn.tag == 22){
                //  退格
                if (Value.length == 0) {
                    
                }
                else if ([[Value substringWithRange:NSMakeRange(0, 1)]isEqualToString:@"-" ]&& Value.length == 2) {
                    Value = @"";
                    cell2.ItemVal.text = Value;
                }else{
                    NSString* Str;
                    //光标的位置
                    NSRange rangex = [cell2.ItemVal selectedRange];
                    if (rangex.location == 0) {
                        
                    }else if (rangex.location == Value.length && Value.length){
                        cell2.ItemVal.text = [cell2.ItemVal.text substringToIndex:cell2.ItemVal.text.length - 1];
                        
                    }else{
                        //光标退格
                        Str = [Value substringWithRange:NSMakeRange(rangex.location -1, 1)];
                        if ([Str isEqualToString:@"."]){
                            Value = [Value substringToIndex:rangex.location - 1];
                        }else{
                            Value = [Value stringByReplacingCharactersInRange:NSMakeRange(rangex.location -1, 1) withString:@""];
                        }
                        cell2.ItemVal.text = Value;
                        [cell2.ItemVal setSelectedRange:NSMakeRange(rangex.location - 1, 0)];
                    }
                }
                break;
            }else if(btn.tag == 23){
                //  清除
                cell2.ItemVal.text = @"";
                break;
            }else if(btn.tag == 30){
                //  - 负号
                if(Value.length == 0||[Value isEqualToString:@"0"]){
                
                }else{
                    if ([[Value substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"]) {
                        cell2.ItemVal.text = [Value substringFromIndex:1];
                    }else{
                        cell2.ItemVal.text = [NSString stringWithFormat:@"-%@",Value];
                    }
                }
                break;
            }else if(btn.tag == 11){
                //小数点
                
                if (Value.length == 0) {
                    Value = @"0.";
                    cell2.ItemVal.text = Value;
                }else{
                    //判断是否已经含有小数点
                    if([Value containsString:@"."]){
                    //不做任何处理
                    }else{
                        //判断光标位置
                        NSRange rangex = [cell2.ItemVal selectedRange];
                        if (rangex.location == 0) {
                            Value = [NSString stringWithFormat:@"0.%@",Value];
                        }else if (rangex.location == Value.length && Value.length){
                            Value = [Value stringByAppendingString:@"."];
                        }else{
                            NSMutableString* MutableValue = [NSMutableString stringWithFormat:@"%@",Value];
                            [MutableValue insertString:@"." atIndex:rangex.location];
                            Value = [NSString stringWithFormat:@"%@",MutableValue];
                        }
                    }
                    
                    cell2.ItemVal.text = Value;
                }
                break;
            }else{
                NSRange rangex = [cell2.ItemVal selectedRange];
                
                if ([Value isEqualToString:@"0"]||[Value isEqualToString:@""]) {
                    cell2.ItemVal.text = [NSString stringWithFormat:@"%ld",btn.tag];
                }else if(Value.length >5){
                
                }else{
                    if (rangex.location == 0) {
                        NSMutableString* MutableValue = [NSMutableString stringWithFormat:@"%@",Value];
                        [MutableValue insertString:[NSString stringWithFormat:@"%lu",btn.tag] atIndex:rangex.location];
                        Value = [NSString stringWithFormat:@"%@",MutableValue];
                    }else if (rangex.location == Value.length){
                        cell2.ItemVal.text = [Value stringByAppendingString:[NSString stringWithFormat:@"%ld",btn.tag]];
                        
                    }else{
                        NSMutableString* MutableValue = [NSMutableString stringWithFormat:@"%@",Value];
                        [MutableValue insertString:[NSString stringWithFormat:@"%lu",btn.tag] atIndex:rangex.location];
                        Value = [NSString stringWithFormat:@"%@",MutableValue];
                        cell2.ItemVal.text = Value;
                        [cell2.ItemVal setSelectedRange:NSMakeRange(rangex.location + 1, 0)];
                    }
                }
                break;
            }
        }
        
    }
    return btn;
}




@end







