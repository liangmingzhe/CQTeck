//
//  CQHttpService.h
//  CQTechApp
//
//  Created by 梁明哲 on 2020/3/30.
//  Copyright © 2020 ChengQian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CQHttpService : NSObject
/// 登陆接口
+ (void)loginWithAccount:(NSString *)account password:(NSString *)password success:(void (^)(id successObject))success failure:(void (^)(id failureObject))failure;
/// 设备实时数据
+ (void)getDeviceListWithAccount:(NSString *)account success:(void (^)(id successObject))success failure:(void (^)(id failureObject))failure;
/// 注册推送
+ (void)registerPushTokenWithAccount:(NSString *)account pushToken:(NSString *)pushToken success:(void (^)(id successObject))success failure:(void (^)(id failureObject))failure;
@end

NS_ASSUME_NONNULL_END
