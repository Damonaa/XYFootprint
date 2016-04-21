//
//  NSString+XY.h
//  Footprint
//
//  Created by 李小亚 on 16/4/7.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XY)

/**
 *  计算string所占的size
 *
 *  @param string   字符
 *  @param maxWidth 最大宽度
 *  @param size     字体size
 *
 *  @return string所占的size
 */
+ (CGSize)stringSizeWithString:(NSString *)string maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)size;


/**
 *  将时长转换成00：00格式
 *
 *  @param timeInterval 时间长度
 *
 *  @return 转换成00：00格式的字符串
 */
+(NSString *)timeStringForTimeInterval:(NSTimeInterval)timeInterval;

//
/**
 *  在缓存沙盒中创建一个文件夹
 *
 *  @param fileName 文件夹名称
 *
 *  @return 文件夹的路径
 */
+ (NSString *)cacheFileWithName:(NSString *)fileName;
@end
