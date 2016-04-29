//
//  XYSqliteTool.m
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYSqliteTool.h"
#import "FMDB.h"
#import <sqlite3.h>
#import "XYEvent.h"
#import "JSONKit.h"

@interface XYSqliteTool ()



@end

@implementation XYSqliteTool

static FMDatabase *_eventsDB;

//初始化创建数据库
+ (void)initialize{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:@"events.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    _eventsDB = db;
    //打开数据库
    if ([db open]) {
        XYLog(@"open success");
    }else{
        XYLog(@"open failure");
    }
    
    //创建数据库表autoincrement
    //id  text 文本，remindDate提醒时间， remindLoc提醒地点，region提醒区域，frequency提醒频率， images图片数组路径，record音频模型， notiKey通知的标示key，tag通知的归类标签, complete事件完成
    BOOL flag = [db executeUpdate:@"create table if not exists t_event (id integer primary key autoincrement, text text, remindDate text, remindLoc text, region blob, frequency integer, images text, audioName text, audioDuration integer, notiKey text, tag text, complete integer, weather text);"];
    if (flag) {
        XYLog(@"create success");
    }else{
        XYLog(@"create failure");
    }
}


//- (NSString *)tranformOCToString:(id)obj{
//    NSData *jsonRegion = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:NULL];
//    return [[NSString alloc] initWithData:jsonRegion encoding:NSUTF8StringEncoding];
//}
/**
 *  执行SQL语句
 *
 *  @param sql 语句
 */
+ (BOOL)executeUpdate:(NSString *)sql{
//    XYLog(@"%@", sql);

    BOOL flag = [_eventsDB executeUpdate:sql];
    if (flag) {
        XYLog(@"execute success");
    }else{
        XYLog(@"execute failure");
    }
//    XYLog(@"%@",[NSThread currentThread]);
    
    return flag;
}

/**
 *   NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_event WHERE TEXT LIKE '%%%@%%'", require];
 
 result = [_eventsDB executeQuery:query];
 */

/**
 *  查询指定tag下的数据
 *
 *  @param tag     指定标签
 *  @param require 搜索参数
 *
 *  @return 数组
 */
+ (NSArray *)executeQuarySqecifyTag:(NSString *)tag require:(NSString *)require{
    XYLog(@"%@",[NSThread currentThread]);
    FMResultSet *result ;
    if (require.length > 0) {//如果有筛选条件，则筛选
        NSString *query = [NSString stringWithFormat:@"select * from t_event where tag = '%@' and text like '%%%@%%'",tag, require];
        
       result = [_eventsDB executeQuery:query];
    }else{//require 为空
        NSString *query = [NSString stringWithFormat:@"select * from t_event where tag = '%@'",tag];
        
        result = [_eventsDB executeQuery:query];
    }
    
    return  [self quaryResultWith:result];
}

/**
 *  查询数据
 *  @param require 搜索参数
 *
 *  @return 数组
 */
+ (NSArray *)executeQuarySqecifyRequire:(NSString *)require{
//    XYLog(@"%@",[NSThread currentThread]);
    FMResultSet *result ;
    if (require.length > 0) {//如果有筛选条件，则筛选
        NSString *query = [NSString stringWithFormat:@"select * from t_event where text like '%%%@%%' order by complete asc",require];
        
        result = [_eventsDB executeQuery:query];
    }else{//require 为空
        NSString *query = [NSString stringWithFormat:@"select * from t_event order by complete asc"];
        
        result = [_eventsDB executeQuery:query];
    }
    
    return  [self quaryResultWith:result];
}

/**
 *  查询未完成的事件
 *
 *  @return 未完成的事件数据
 */
+ (NSArray *)executeQuaryWithUncompletedEvent{
//    XYLog(@"%@",[NSThread currentThread]);
    FMResultSet *result = [_eventsDB executeQuery:@"select * from t_event where complete = 0 order by id desc"];
    return  [self quaryResultWith:result];
}

/**
 *  查询全部事件
 *
 *  @return 全部的事件数据
 */
+ (NSArray *)executeQuaryAllEvent{
    //    XYLog(@"%@",[NSThread currentThread]);
    FMResultSet *result = [_eventsDB executeQuery:@"select * from t_event order by complete asc, id desc"];
    return  [self quaryResultWith:result];
}

/**
 *  查询相同tag的数据
 *
 *  @return 全部相同tag下的数据
 */
+ (NSArray *)executeTagQuaryWithName:(NSString *)tag{
//    XYLog(@"%@",[NSThread currentThread]);
    FMResultSet *result = [_eventsDB executeQuery:@"select * from t_event where tag = ? order by complete asc;",tag];
    
    return  [self quaryResultWith:result];
}


/**
 *  查询指定的notikey
 *
 *  @return 指定的notikey的数组
 */
+ (NSArray *)executeTagQuaryWithNotiKey:(NSString *)notiKey{
    //    XYLog(@"%@",[NSThread currentThread]);
    FMResultSet *result = [_eventsDB executeQuery:@"select * from t_event where notiKey = ?;",notiKey];
    
    return  [self quaryResultWith:result];
}

//查询结果写入数组
+ (NSArray *)quaryResultWith:(FMResultSet *)result{
    NSMutableArray *arrayM = [NSMutableArray array];
    while ([result next]) {
        XYEvent *getEvent = [[XYEvent alloc] init];
        
        //文本
        getEvent.text = [result stringForColumn:@"text"];
        //时间
        getEvent.remindDate = [result stringForColumn:@"remindDate"];
        //地址
        getEvent.remindLoc = [result stringForColumn:@"remindLoc"];
        //区域
        NSData *regionD = [result dataForColumn:@"region"];
        getEvent.region = [NSKeyedUnarchiver unarchiveObjectWithData:regionD];
        //频率
        getEvent.frequency = [result intForColumn:@"frequency"];
        //图片数组
        //        NSData *imagesD = [result dataForColumn:@"images"];
        //        getEvent.images = [NSKeyedUnarchiver unarchiveObjectWithData:imagesD];
        
        NSString *imagesStr = [result stringForColumn:@"images"];
        getEvent.images = (NSMutableArray *)[imagesStr objectFromJSONString];
        
        //音频
        getEvent.audioName = [result stringForColumn:@"audioName"];
        getEvent.audioDuration = [result doubleForColumn:@"audioDuration"];
        //通知标示
        getEvent.notiKey = [result stringForColumn:@"notiKey"];
        //通知的归类
        getEvent.tag = [result stringForColumn:@"tag"];
        getEvent.completeEvent = [result intForColumn:@"complete"];
        getEvent.weather = [result stringForColumn:@"weather"];
        
        [arrayM addObject:getEvent];
        
    }
    return arrayM;
}
@end
