//
//  Algorithm.m
//  CQTechApp
//
//  Created by 梁明哲 on 2017/11/18.
//  Copyright © 2017年 ChengQian. All rights reserved.
//

#import "Algorithm.h"
#import <CommonCrypto/CommonDigest.h>
@implementation Algorithm


//类方法 md5加密
+ (NSString *)md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}
//类方法 检查字符串是仅为数字或字母

//类方法 检查检查邮件格式
+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isOnlyNumberAndCharactors:(NSString*)string{
    NSString *regex = @"[0-9A-Za-z]{6,16}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:string];
}
@end
