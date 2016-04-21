//
//  NSDate+extend.h
//  XYCalendarView
//
//  Created by 李小亚 on 12/13/15.
//  Copyright © 2015 李小亚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (extend)

//- (BOOL)isToday;

+ (NSDate *)dateStartOfDay:(NSDate *)date;

//两个时间是否一致
+ (BOOL)isSameDayWithDate:(NSDate *)firstDate andDate:(NSDate *)secondDate;
+ (BOOL)isSameDayWithTime:(NSTimeInterval)firstTime andTime:(NSTimeInterval)secondTime;

//返回date的零点时间
+ (NSDate *)acquireTimeFromDate:(NSDate *)date;

//获取week在date中的index
+ (NSInteger)acquireWeekDayFromDate:(NSDate *)date;

- (NSInteger)day;
- (NSInteger)month;
- (NSInteger)year;
- (NSInteger)hour;
- (NSInteger)minute;

//从时间戳获取特定格式的时间字符串
+ (NSString *)stringWithTimestemp:(NSTimeInterval)tt format:(NSString *)format;

/**
 *  获取当前时间的字符串
 *
 *  @return yyyyMMddHHmmss
 */
+ (NSString *)currentDateStr;


/**
 *  是否为今天
 */
- (BOOL)isToday;
/**
 *  是否是明天
 */
- (BOOL)isTomorrow;
/**
 *  是否是后天
 */
- (BOOL)isTheDayAfterTomorrow;
/**
 *  是否为昨天
 */
- (BOOL)isYesterday;
/**
 *  是否为今年
 */
- (BOOL)isThisYear;

/**
 *  返回一个只有年月日的时间
 */
- (NSDate *)dateWithYMD;

/**
 *  获得与当前时间的差距
 */
- (NSDateComponents *)deltaWithNow;
/**
 *  字符串样式转换为时间
 *
 *  @param dateStr 字符串时间
 *  @param format  时间格式
 *
 *  @return 时间
 */
+ (NSDate *)dateTransformFromStr:(NSString *)dateStr format:(NSString *)format;
/**
 *  将时间转为字符串搁置
 *
 *  @param date   时间
 *  @param format 格式
 *
 *  @return 字符串时间
 */
+ (NSString *)dateTransformFromDate:(NSDate *)date format:(NSString *)format;
/**
 *  某一天距离今天相差的天数
 *
 *  @return 某一天距离今天相差的天数
 */
- (NSInteger)daysDifferentsToToday;
@end
