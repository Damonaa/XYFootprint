//
//  NSString+XY.m
//  Footprint
//
//  Created by 李小亚 on 16/4/7.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "NSString+XY.h"

@implementation NSString (XY)

/**
 *  计算string所占的size
 *
 *  @param string   字符
 *  @param maxWidth 最大宽度
 *  @param size     字体size
 *
 *  @return string所占的size
 */
+ (CGSize)stringSizeWithString:(NSString *)string maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)size{
    CGSize maxSize = CGSizeMake(maxWidth, MAXFLOAT);
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]} context:nil].size;
}

/**
 *  将时长转换成00：00格式
 *
 *  @param timeInterval 时间长度
 *
 *  @return 转换成00：00格式的字符串
 */
+(NSString *)timeStringForTimeInterval:(NSTimeInterval)timeInterval{
    NSInteger ti = (NSInteger)timeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minute = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02li:%02li:%02li",(long)hours,(long)minute,(long)seconds];
    }else{
        return [NSString stringWithFormat:@"%02li:%02li",(long)minute, (long)seconds];
    }
}

//创建一个文件夹
+ (NSString *)cacheFileWithName:(NSString *)fileName{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imageDir = [cacheDir stringByAppendingPathComponent:fileName];
    //判断文件夹是否存在
    if (![fileManager fileExistsAtPath:imageDir]) {//不存在，创建
        BOOL cre = [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:NULL];
        if (cre) {
            XYLog(@"success");
        }
    }
    return imageDir;
}

@end
