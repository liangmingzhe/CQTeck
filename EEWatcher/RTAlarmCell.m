//
//  RTAlarmCell.m
//  CQTechApp
//
//  Created by 梁明哲 on 2018/1/31.
//  Copyright © 2018年 ChengQian. All rights reserved.
//

#import "RTAlarmCell.h"
#import "ScottAlertController.h"
#import "Request.h"
#import "cqtekHeader.pch"
#import "Language.h"

@implementation RTAlarmCell
@synthesize confirm;
@synthesize ignore;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self confirm];
    [self ignore];
}
- (UIButton*)confirm{
    if(!confirm){
        confirm = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 90, self.frame.size.height-40, 80, 30)];
        confirm.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1].CGColor;
        confirm.layer.borderWidth = 1;
        
        [confirm setTitleColor:[UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1] forState:UIControlStateNormal];
        [confirm setTitleColor:[UIColor colorWithRed:0.3 green:0.6 blue:1 alpha:1] forState:UIControlStateHighlighted];
        [confirm setTitle:@"确认" forState:UIControlStateNormal];
        [confirm addTarget:self action:@selector(AddConfirmInfomation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirm];
    }
    return confirm;
}

- (UIButton*)ignore{
    if(!ignore){
        ignore = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 180, self.frame.size.height-40, 80, 30)];
        ignore.layer.borderColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1].CGColor;
        ignore.layer.borderWidth = 1;
        
        [ignore setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] forState:UIControlStateNormal];
        [ignore setTitleColor:[UIColor colorWithRed:0.3 green:0.6 blue:1 alpha:1] forState:UIControlStateHighlighted];
        [ignore setTitle:@"忽略" forState:UIControlStateNormal];
        [ignore addTarget:self action:@selector(IgnoreAlarm) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:ignore];
    }
    return ignore;
}

- (void)IgnoreAlarm{
    [self dealwithTheError:self.deviceName.text alarmId:self.alarmid.text additionInfo:@""];
    
}

- (void)AddConfirmInfomation{
    ScottAlertView *alert = [ScottAlertView alertViewWithTitle:NSLocalizedString(@"Tips", nil) message:@"请输入备注信息\n"];
    ScottAlertAction *cancel = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        
    }];
    ScottAlertAction *confirm = [ScottAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:ScottAlertActionStyleOther handler:^(ScottAlertAction * _Nonnull action) {
        [self dealwithTheError:self.deviceName.text alarmId:self.alarmid.text additionInfo:_infomation];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        _infomation = textField.text;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];

    }];
    [alert addAction:confirm];
    [alert addAction:cancel];
    [ScottShowAlertView showAlertViewWithView:alert backgroundDismissEnable:YES];
}
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    _infomation = textField.text;
    // Enforce a minimum length of >= 5 characters for secure text alerts.
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealwithTheError:(NSString*)sn alarmId:(NSString*)alarmId additionInfo:(NSString*)additionInfo{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:[defaults objectForKey:@"cqUser"]];
    [request setParameter:@"snaddr" value:sn];
    [request setParameter:@"alarmId" value:alarmId];
    [request setParameter:@"additionInfo" value:additionInfo];
    [request setHeader:@"type" value:@"dealwithTheError"];
    [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
        if ([[data objectForKey:@"code"] intValue] == 0) {
            [self Alart:@"报警已确认!"];
            
        }else if([[data objectForKey:@"code"] intValue] == 1){
            [self Alart:@"操作失败,报警尚未结束！"];
        }else{
            [self Alart:@"操作失败,未知异常！"];
        }
    } failure:^(NSError *error) {
            [self Alart:@"请求超时,请确认网络是否正常。"];
    }];
}


- (void)Alart:(NSString*)string{
    ScottAlertView *alert = [ScottAlertView alertViewWithTitle:NSLocalizedString(@"Tips", nil) message:string];
    [ScottShowAlertView showAlertViewWithView:alert backgroundDismissEnable:YES];
    
}


@end
