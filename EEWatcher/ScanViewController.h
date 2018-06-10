//
//  ScanViewController.h
//  CQTechApp
//
//  Created by 梁明哲 on 2017/3/1.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";

@interface ScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>


@property (strong,nonatomic)AVCaptureDevice *device;
@property (strong,nonatomic)AVCaptureDeviceInput *input;
@property (strong,nonatomic)AVCaptureMetadataOutput *output;
@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *preview;
@property (nonatomic) BOOL lastResult;


@end
