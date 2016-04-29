//
//  XYSqliteTool.h
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XYEvent;

@interface XYSqliteTool : NSObject

/**
 *  执行SQL语句
 *
 *  @param sql 语句
 */
+ (BOOL)executeUpdate:(NSString *)sql;

/**
 *  查询指定tag下的数据
 *
 *  @param tag     指定标签
 *  @param require 搜索参数
 *
 *  @return 数组
 */
+ (NSArray *)executeQuarySqecifyTag:(NSString *)tag require:(NSString *)require;
/**
 *  查询未完成的事件
 *
 *  @return 未完成的事件数据
 */
+ (NSArray *)executeQuaryWithUncompletedEvent;

/**
 *  查询全部事件
 *
 *  @return 全部的事件数据
 */
+ (NSArray *)executeQuaryAllEvent;
/**
 *  查询相同tag的数据
 *
 *  @return 全部数据
 */
+ (NSArray *)executeTagQuaryWithName:(NSString *)tag;

/**
 *  查询数据
 *  @param require 搜索参数
 *
 *  @return 数组
 */
+ (NSArray *)executeQuarySqecifyRequire:(NSString *)require;

/**
 *  查询指定的notikey
 *
 *  @return 指定的notikey的数组
 */
+ (NSArray *)executeTagQuaryWithNotiKey:(NSString *)notiKey;
@end
