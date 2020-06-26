//
//  CQHttpService.m
//  CQTechApp
//
//  Created by 梁明哲 on 2020/3/30.
//  Copyright © 2020 ChengQian. All rights reserved.
//

#import "CQHttpService.h"
#import "Request.h"
@implementation CQHttpService

//登陆接口
+ (void)loginWithAccount:(NSString *)account password:(NSString *)password success:(void (^)(id successObject))success failure:(void (^)(id failureObject))failure {
    dispatch_queue_t  queue = dispatch_queue_create("com.manniu.wakeup", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        Request* request = [[Request alloc]init];
        [request setHeader:@"type" value:@"login"];
        [request setParameter:@"user" value:account];
        [request setParameter:@"password" value:password];
        [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
            success(data);
        } failure:^(NSError *error) {
            failure(error);
        }];
    });
}

+ (void)getDeviceListWithAccount:(NSString *)account success:(void (^)(id successObject))success failure:(void (^)(id failureObject))failure {
    dispatch_queue_t  queue = dispatch_queue_create("com.manniu.realdata", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        Request* request = [[Request alloc]init];
        [request setHeader:@"type" value:@"getUserRTData"];
        [request setParameter:@"user" value:account];
        [request setParameter:@"curve" value:@"allLast"];
        [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
            success(data);
        } failure:^(NSError *error) {
            failure(error);
        }];
    });
}

+ (void)registerPushTokenWithAccount:(NSString *)account pushToken:(NSString *)pushToken success:(void (^)(id successObject))success failure:(void (^)(id failureObject))failure {
    Request* request = [[Request alloc]init];
    [request setParameter:@"user" value:account];
    [request setParameter:@"token" value:pushToken];
    [request setParameter:@"accessToken" value:@"CQY"];
    [request setHeader:@"type" value:@"setDevToken"];
    [Request Post:cqtek_api outTime:15 success:^(NSDictionary *data) {
        success(data);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
@end
