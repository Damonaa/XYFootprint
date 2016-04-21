//
//  XYTagsTool.h
//  Footprint
//
//  Created by 李小亚 on 16/4/11.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYTagsTool : NSObject

/**
 *  存放全部的标签列表
 */
@property (nonatomic, strong) NSMutableArray *tags;
/**
 *  存放tag的路径
 */
@property (nonatomic, copy) NSString *tagDir;

/**
 *  单例
 */
+ (instancetype)sharedTagsTool;

/**
 *  将tag写入plist文件中
 */
- (BOOL)writeTagToFileWithTag:(NSString *)tag;
@end
