//
//  modifyPassword.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/1/9.
//  Copyright © 2017年 ChengQian. All rights reserved.
//
/**
 *
 *----------Dragon be here!----------/
 *　　    ┏┓    ┏┓
 * 　　┏━━┛┻━━━━┛┻━┓
 * 　　┃           ┃
 * 　　┃     ━     ┃
 * 　　┃  ┳┛   ┗┳  ┃
 * 　　┃           ┃
 * 　　┃     ┻     ┃
 * 　　┃           ┃
 * 　　┗━┓     ┏━━━┛
 * 　 　 ┃     ┃神兽保佑
 * 　  　┃     ┃代码无BUG！
 * 　　  ┃     ┗━━━━┓
 * 　  　┃          ┣┓
 *  　　 ┃         ┏┛
 * 　　  ┗┓┓┏━┳┓┏━━┛
 * 　  　 ┃┫┫ ┃┫┫
 *   　　 ┗┻┛ ┗┻┛
 * ━━━━━━神兽出没━━━━━━
 */

#import "modifyPassword.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"
#import "ScottAlertController.h"
#import "CustmerServiceView.h"
#import "Language.h"
@interface modifyPassword ()<UITextViewDelegate>{
    UITextField* OldPass;
    UITextField* NewPass;
    UITextField* ConfirmNewPass;
    NSUserDefaults* defaults;
    AFHTTPSessionManager *manager;
}

@end

@implementation modifyPassword

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.title = LocalizedString(@"l_modifyPass");
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    
    UIButton* setButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [setButton setTitle:LocalizedString(@"l_done") forState:UIControlStateNormal];
    
    [setButton setBackgroundColor:[UIColor clearColor]];
    [setButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    setButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
    
    [setButton addTarget:self action:@selector(setAndBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:setButton];
    self.navigationItem.rightBarButtonItem = rightButton;

    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height/4)];
    view.backgroundColor = [UIColor clearColor];
    view.layer.cornerRadius = 3;
    [self.view addSubview:view];
    
    OldPass = [[UITextField alloc]initWithFrame:CGRectMake(view.frame.size.width/10, view.frame.size.height/6 - 20, view.frame.size.width/10*8, 40)];
    OldPass.borderStyle = UITextBorderStyleRoundedRect;
    OldPass.textAlignment = NSTextAlignmentCenter;
    OldPass.backgroundColor = [UIColor whiteColor];
    OldPass.textColor = [UIColor blackColor];
    OldPass.secureTextEntry = YES;
    OldPass.font = [UIFont fontWithName:@"Arial" size:20];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:LocalizedString(@"l_enter_old") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:OldPass.font}];
    OldPass.attributedPlaceholder = attrString;
    OldPass.layer.borderColor = [UIColor lightGrayColor].CGColor;
    OldPass.layer.borderWidth = 0.3;

    [view addSubview:OldPass];
    NewPass = [[UITextField alloc]initWithFrame:CGRectMake(OldPass.frame.origin.x, OldPass.frame.origin.y + OldPass.frame.size.height + 10, view.frame.size.width/10*8, OldPass.frame.size.height)];
    NewPass.borderStyle = UITextBorderStyleRoundedRect;
    NewPass.textAlignment = NSTextAlignmentCenter;
    NewPass.textColor = [UIColor blackColor];
    NewPass.backgroundColor = [UIColor whiteColor];
    NewPass.secureTextEntry = YES;
    NewPass.font = [UIFont fontWithName:@"Arial" size:20];

    NSAttributedString *attrString2 = [[NSAttributedString alloc] initWithString:LocalizedString(@"l_enter_new") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:NewPass.font}];
    NewPass.attributedPlaceholder = attrString2;
    NewPass.layer.borderColor = [UIColor lightGrayColor].CGColor;
    NewPass.layer.borderWidth = 0.3;
    [view addSubview:NewPass];

    ConfirmNewPass = [[UITextField alloc]initWithFrame:CGRectMake(NewPass.frame.origin.x, NewPass.frame.origin.y + NewPass.frame.size.height + 10, view.frame.size.width/10*8, NewPass.frame.size.height)];
    ConfirmNewPass.borderStyle = UITextBorderStyleRoundedRect;
    ConfirmNewPass.textAlignment = NSTextAlignmentCenter;
    ConfirmNewPass.textColor = [UIColor blackColor];
    ConfirmNewPass.backgroundColor = [UIColor whiteColor];
    ConfirmNewPass.secureTextEntry = YES;
    ConfirmNewPass.font = [UIFont fontWithName:@"Arial" size:20];
    ConfirmNewPass.placeholder = LocalizedString(@"l_enter_new_again");
    NSAttributedString *attrString3 = [[NSAttributedString alloc] initWithString:LocalizedString(@"l_enter_new_again") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:ConfirmNewPass.font}];
    ConfirmNewPass.attributedPlaceholder = attrString3;
    ConfirmNewPass.layer.borderColor = [UIColor lightGrayColor].CGColor;
    ConfirmNewPass.layer.borderWidth = 0.3;
    [view addSubview:ConfirmNewPass];
    
    UILabel* messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, view.frame.origin.y + view.frame.size.height, [UIScreen mainScreen].bounds.size.width, 50)];
    messageLabel.numberOfLines = 5;
    messageLabel.font = [UIFont fontWithName:@"Arial" size:18];
    messageLabel.textColor = [UIColor grayColor];
    messageLabel.text = LocalizedString(@"t_tips_modify_pass");
    [self.view addSubview:messageLabel];

    manager = [[AFHTTPSessionManager manager]init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
    
    defaults = [NSUserDefaults standardUserDefaults];


}
- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)backToMainView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAndBack{
    if (OldPass.text.length == 0) {
        [self AlertMessage:LocalizedString(@"t_old_empty")];
    }else if (NewPass.text == OldPass.text){
        [self AlertMessage:LocalizedString(@"t_old_new")];
    }
    else if (NewPass.text.length < 6){
        [self AlertMessage:LocalizedString(@"t_format_pass")];
    }else if (NewPass.text != ConfirmNewPass.text){
        [self AlertMessage:LocalizedString(@"t_pass_not_fit")];
    }
    else{
        NSDictionary *params = @{@"user":[defaults objectForKey:@"cqUser"]
                                 ,@"oldPass":[self md5:OldPass.text]
                                 ,@"newPass":[self md5:NewPass.text]};
        manager.securityPolicy.allowInvalidCertificates = NO;
        [manager POST:cqtek_api parameters:params headers:@{@"type":@"modifyPass"} progress:^(NSProgress * _Nonnull uploadProgress) {
            nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"请求成功:%@", responseObject);
            NSMutableDictionary*JSON;
            JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([[JSON objectForKey:@"code"]intValue] == 0){
                [self AlertMessage2:[JSON objectForKey:@"msg"]];
            }
            else if([[JSON objectForKey:@"code"]intValue] == 3){
                [self AlertMessage:LocalizedString(@"t_oldpass_incorrect")];
            }else{
                [self AlertMessage:[JSON objectForKey:@"msg"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"请求失败:%@", error.description);
        }];
    
    }
   
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [OldPass endEditing:YES];
    [NewPass endEditing:YES];
    [ConfirmNewPass endEditing:YES];
    
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)AlertMessage:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
}

- (void)AlertMessage2:(NSString*)message{
    ScottAlertView *alertView = [ScottAlertView alertViewWithTitle:LocalizedString(@"Tips") message:message];
    ScottAlertAction *action = [ScottAlertAction actionWithTitle:LocalizedString(@"Confirm") style:ScottAlertActionStyleDestructive handler:^(ScottAlertAction * _Nonnull action) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }];
    [alertView addAction:action];
    [ScottShowAlertView showAlertViewWithView:alertView backgroundDismissEnable:YES];
}

//md5加密运算
- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
