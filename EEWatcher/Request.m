//
//  Request.m
//  HttpRequest
//
//  Created by 梁明哲 on 2017/8/21.
//  Copyright © 2017年 梁明哲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"

@interface Request (){

}

@end


@implementation Request
    static int timeOut;
    static NSMutableDictionary* HeaderDic;
    static NSMutableDictionary *params;


- (id)init
{
    self = [super init];
    if (self) {
        //初始化代码
        HeaderDic =[[NSMutableDictionary alloc]init];
        params =[[NSMutableDictionary alloc]init];
    }
    
    return self;
}



+ (void)Post:(NSString*)url outTime:(int)outTime success:(SuccessBlock)successBlock
        failure:(FailureBlock)failureBlock{
    NSLog(@"API = %@ header = %@",url,HeaderDic);
    dispatch_group_t group = dispatch_group_create();
    //2.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //3.添加请求
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        
        AFHTTPSessionManager *manager;
        manager = [[AFHTTPSessionManager manager]init];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 15;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json", nil];
        manager.securityPolicy.allowInvalidCertificates = NO;
        
        [manager POST:url parameters:params headers:HeaderDic progress:^(NSProgress * _Nonnull uploadProgress) {
            nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //请求成功
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            successBlock(dic);
            
            dispatch_group_leave(group);
            return ;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failureBlock) {
                
                failureBlock(error);

                NSLog(@"T_T(网络异常):%@", error);
                dispatch_group_leave(group);
            }
            return ;
        }];
        
    });

    
    
}


- (void)setTimeOut:(int)time{
    timeOut = time;
}

- (int)getTimeOut{
    timeOut = 15;
    return timeOut;
}
- (void)setHeader:(NSString*)key value:(NSString*)value{
    [HeaderDic setObject:value forKey:key];

}

- (void)setParameter:(NSString*)key value:(NSString*)value{
    [params setObject:value forKey:key];
}

- (void)setArrayParameter:(NSString*)key arrayValue:(NSMutableArray*)value{
    [params setObject:value forKey:key];
}






@end






