//
//  ScanViewController.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/3/1.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "ScanViewController.h"
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "RedView.h"
#import <CommonCrypto/CommonDigest.h>
#import "Language.h"
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,CALayerDelegate>{
    MBProgressHUD* m_loading;
    NSUserDefaults* defaults;
    UIView* scanView;
}

@property (nonatomic,strong)CALayer * maskLayer;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    defaults = [NSUserDefaults standardUserDefaults];
}

- (void)viewWillAppear:(BOOL)animated{
    
    
}

- (void)viewWillDisappear:(BOOL)animated{

    [self stopReading];
    
}
- (void)viewDidAppear:(BOOL)animated{
    m_loading = [[MBProgressHUD alloc]initWithView:self.view];
    m_loading.dimBackground = YES;
    m_loading.labelText = LocalizedString(@"Wait");
    [m_loading show:YES];
    [self StartReading];

    UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/8, HEIGHT/4, WIDTH/4*3, 60)];
    tips.textAlignment = NSTextAlignmentCenter;
    tips.textColor = [UIColor whiteColor];
    tips.numberOfLines = 3;
    tips.text = LocalizedString(@"l_scan_bar");
    [self.view addSubview:tips];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(30, HEIGHT/2,WIDTH - 60, 2)];
    view.backgroundColor = [UIColor colorWithRed:59/255.0 green:110/255.0 blue:189/255.0 alpha:1];
    
    [self.view addSubview:view];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, CGRectGetMaxY(view.frame)-60, 30, 30)];
    imageView.image = [UIImage imageNamed:@"左上"];
    [self.view addSubview:imageView];
    
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(25, CGRectGetMaxY(view.frame)+30, 30, 30)];
    imageView2.image = [UIImage imageNamed:@"左下"];
    [self.view addSubview:imageView2];
    
    UIImageView *imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 55, CGRectGetMaxY(view.frame)-60, 30, 30)];
    imageView3.image = [UIImage imageNamed:@"右上"];
    [self.view addSubview:imageView3];
    
    UIImageView *imageView4 = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 55, CGRectGetMaxY(view.frame)+30, 30, 30)];
    imageView4.image = [UIImage imageNamed:@"右下"];
    [self.view addSubview:imageView4];
    
    scanView = [[UIView alloc]initWithFrame:CGRectMake(25, CGRectGetMaxY(view.frame)-60, [UIScreen mainScreen].bounds.size.width-50, 120)];
    scanView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scanView];

    UIButton* cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/8, [UIScreen mainScreen].bounds.size.height/8*7, 100, 30)];
    [cancelBtn setTitle:LocalizedString(@"Cancel") forState:UIControlStateNormal];
    [cancelBtn setTintColor:[UIColor whiteColor]];
    [cancelBtn addTarget:self action:@selector(cancelQRScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
}

- (void)cancelQRScan{
    [self stopReading];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)StartReading{
    NSError * error;
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _session =[[AVCaptureSession alloc]init];
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (!_input){
        NSLog(@"%@",[error localizedDescription]);
        return NO;
    }
    _output = [[AVCaptureMetadataOutput alloc]init];

    [_session addInput:_input];
    [_session addOutput:_output];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    
    //设置代理
    [_output setMetadataObjectsDelegate:self queue:dispatchQueue];
    //设置媒体输出类型为QRCode
    [_output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,//二维码
                                 //以下为条形码，如果项目只需要扫描二维码，下面都不要写
                                 AVMetadataObjectTypeEAN13Code,
                                 AVMetadataObjectTypeEAN8Code,
                                 AVMetadataObjectTypeUPCECode,
                                 AVMetadataObjectTypeCode39Code,
                                 AVMetadataObjectTypeCode39Mod43Code,
                                 AVMetadataObjectTypeCode93Code,
                                 AVMetadataObjectTypeCode128Code,
                                 AVMetadataObjectTypePDF417Code]];
    
    //实例化预览图层
    _preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    
    //设置预览图层填充方式
    [_preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_preview setFrame:self.view.frame];
    [self.view.layer addSublayer:_preview];
    
    //蒙版
    
    
    self.maskLayer = [[CALayer alloc]init];
    self.maskLayer.frame = self.view.layer.bounds;
    self.maskLayer.delegate = self;
    [self.view.layer insertSublayer:self.maskLayer above:_preview];
    [self.maskLayer setNeedsDisplay];
    
    
    //设置图层的frame
    _output.rectOfInterest = CGRectMake(0.1f, 0.2f, 0.8f, 0.8f);
    // 开始会话

    [m_loading removeFromSuperview];

    [_session startRunning];
    
    return YES;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
        } else if([[metadataObj type] isEqualToString:AVMetadataObjectTypeCode128Code]){
            NSLog(@"128");
            result = metadataObj.stringValue;
            NSLog(@"%@",result);
            
        }else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN8Code]){
            NSLog(@"8");
            result = metadataObj.stringValue;
            NSLog(@"%@",result);
            
        }else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN13Code]){
            NSLog(@"13");
            result = metadataObj.stringValue;
            NSLog(@"%@",result);
            
        }else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeCode93Code]){
            NSLog(@"93");
            result = metadataObj.stringValue;
            NSLog(@"%@",result);
            
        
        }else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypePDF417Code]){
            NSLog(@"417");
            NSLog(@"%@",result);
            
        }else{
            NSLog(@"------");
        }
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
    }
}
- (void)reportScanResult:(NSString *)result
{
    [self stopReading];
  // 截取result进行处理取倒数12位
    NSString* str;
    NSString* str2;
    NSString* str3;
    NSString* str4;
    if (result.length == 8) {
        str4 = [result substringWithRange:NSMakeRange(0, 6)];
        str = [self md5:[NSString stringWithFormat:@"%@_%@_%@",str4,str4,str4]];
        str2 = [str substringWithRange:NSMakeRange(0, 4)];
        str3 = [str substringWithRange:NSMakeRange(str.length - 4, 4)];
        str = [NSString stringWithFormat:@"%@%@",str2,str3];
        NSLog(@"%@",str);
        [defaults setObject:result forKey:@"barCode"];
        [defaults setObject:str forKey:@"acCode"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{

    }
}
- (void)stopReading
{
    // 停止会话
    self.maskLayer.delegate = nil;
    [_session stopRunning];
    _session = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    if (layer == self.maskLayer) {
        UIGraphicsBeginImageContextWithOptions(self.maskLayer.frame.size, NO, 1.0);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor);
        CGContextFillRect(ctx, self.maskLayer.frame);
        CGContextClearRect(ctx, scanView.frame);
    }
}

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
