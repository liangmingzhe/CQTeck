//
//  LmzFileTool.h
//  CQTechApp
//
//  Created by 梁明哲 on 2018/2/8.
//  Copyright © 2018年 ChengQian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LmzFileTool : NSObject{
    
}
/*
 删除文件夹
 @param: directoryPath 文件夹路径
 */
+ (void)removeDirectoryPath:(NSString *)directoryPath;

/*
 获取文件夹大小
 @param directoryPath 文件夹路径
 @param completion 文件夹尺寸
 */
+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger totalSize))completion;
@end
