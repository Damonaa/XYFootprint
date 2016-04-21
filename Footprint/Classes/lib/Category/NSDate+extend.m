//
//  NSDate+extend.m
//  XYCalendarView
//
//  Created by 李小亚 on 12/13/15.
//  Copyright © 2015 李小亚. All rights reserved.
//

#import "NSDate+extend.h"

@implementation NSDate (extend)
//- (BOOL)isToday{
//    return [[NSDate dateStartOfDay:self] isEqualToDate:[NSDate dateStartOfDay:[NSDate date]]];
//}

+ (NSDate *)dateStartOfDay:(NSDate *)date{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:date];
//    NSLog(@"date + extend components %@, date: %@", components, [gregorian dateFromComponents:components]);
    return [gregorian dateFromComponents:components];
}
//比较两个时间是否相同
+ (BOOL)isSameDayWithTime:(NSTimeInterval)firstTime andTime:(NSTimeInterval)secondTime{
    NSDate *firstDate = [NSDate dateWithTimeIntervalSince1970:firstTime];
    NSDate *secondDate = [NSDate dateWithTimeIntervalSince1970:secondTime];
    return [firstDate isSameDayWithDate:secondDate];
}
//比较连个日期是否相同
+ (BOOL)isSameDayWithDate:(NSDate *)firstDate andDate:(NSDate *)secondDate{
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:firstDate];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:secondDate];
    
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year];
}

//判断是否是同一天
- (BOOL)isSameDayWithDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:date];
    
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year];
}
///解析date，转变成date components，再转换得到一个date
+ (NSDate *)acquireTimeFromDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    
    NSDate *result = [calendar dateFromComponents:comps];
    return result;
}

+ (NSInteger)acquireWeekDayFromDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitWeekday;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    
    return [comps weekday];
}

- (NSInteger)minute{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitMinute fromDate:self];
    return [components minute];
}
- (NSInteger)hour{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitHour fromDate:self];
    return [components hour];
}
- (NSInteger)day{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitDay fromDate:self];
    return [components day];
}
- (NSInteger)month{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitMonth fromDate:self];
    return [components month];
}



- (NSInteger)year{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear fromDate:self];
    
    return [components year];
}

+ (NSString *)stringWithTimestemp:(NSTimeInterval)tt format:(NSString *)format{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:tt];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}
/**
 *  获取当前时间的字符串
 *
 *  @return yyyyMMddHHmmss
 */
+ (NSString *)currentDateStr{
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.dateFormat = @"yyyyMMddHHmmss";
    return [dateForm stringFromDate:[NSDate date]];
}

/**
 *  是否为今天
 */
- (BOOL)isToday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return
    (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}

- (BOOL)isTomorrow{
    
    NSDate *nowDate = [[NSDate date] dateWithYMD];
    
    NSDate *selfDate = [self dateWithYMD];
    
    // 两天的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *coms = [calendar components:NSCalendarUnitDay fromDate:nowDate toDate:selfDate options:0];
    return coms.day == 1;
}



- (BOOL)isTheDayAfterTomorrow{
    NSDate *nowDate = [[NSDate date] dateWithYMD];
    
    NSDate *selfDate = [self dateWithYMD];
    
    // 两天的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *coms = [calendar components:NSCalendarUnitDay fromDate:nowDate toDate:selfDate options:0];
    return coms.day == 2;
}

/**
 *  是否为昨天
 */
- (BOOL)isYesterday
{
    // 2014-05-01
    NSDate *nowDate = [[NSDate date] dateWithYMD];
    
    // 2014-04-30
    NSDate *selfDate = [self dateWithYMD];
    
    // 获得nowDate和selfDate的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day == 1;
}

- (NSDate *)dateWithYMD
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

/**
 *  是否为今年
 */
- (BOOL)isThisYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return nowCmps.year == selfCmps.year;
}

- (NSDateComponents *)deltaWithNow
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:unit fromDate:self toDate:[NSDate date] options:0];
}

/**
 *  字符串样式转换为时间
 *
 *  @param dateStr 字符串时间
 *  @param format  时间格式
 *
 *  @return 时间
 */
+ (NSDate *)dateTransformFromStr:(NSString *)dateStr format:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    //    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zn_US"];
    return [dateFormatter dateFromString:dateStr];
}

/**
 *  将时间转为字符串搁置
 *
 *  @param date   时间
 *  @param format 格式
 *
 *  @return 字符串时间
 */
+ (NSString *)dateTransformFromDate:(NSDate *)date format:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zn_US"];
    return [dateFormatter stringFromDate:date];
}

/**
 *  某一天距离今天相差的天数
 *
 *  @return 某一天距离今天相差的天数
 */
- (NSInteger)daysDifferentsToToday{
    NSDate *nowDate = [[NSDate date] dateWithYMD];
    
    NSDate *selfDate = [self dateWithYMD];
    
    // 两天的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *coms = [calendar components:NSCalendarUnitDay fromDate:nowDate toDate:selfDate options:0];
    return coms.day;
}
@end
