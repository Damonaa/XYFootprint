//
//  XYTagsTool.m
//  Footprint
//
//  Created by 李小亚 on 16/4/11.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYTagsTool.h"

@implementation XYTagsTool
 static XYTagsTool *tagsTool;
+ (instancetype)sharedTagsTool{
    if (tagsTool == nil) {
        tagsTool = [[self alloc] init];
    }
    return tagsTool;
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagsTool = [super allocWithZone:zone];
        
        //创建一个plist文件，存放标签
        NSString *tagFilePath = [NSString cacheFileWithName:@"tags"];
        NSString *tagDir = [tagFilePath stringByAppendingPathComponent:@"tags.plist"];
        [XYTagsTool sharedTagsTool].tagDir = tagDir;
        
        
        BOOL isDirectory;
        if ([[NSFileManager defaultManager]  fileExistsAtPath:tagDir isDirectory:&isDirectory] && !isDirectory) {
            //有此文件
        }else{//无此文件,创建新的
            NSArray *tags = @[@"工作", @"生活"];
            [tags writeToFile:tagDir atomically:YES];
        }
        
//        NSString *tagsPath = [[NSBundle mainBundle] pathForResource:@"Tags.plist" ofType:nil];
        tagsTool.tags = [NSMutableArray arrayWithContentsOfFile:tagDir];
    });
    return tagsTool;
}


- (NSMutableArray *)tags{
    if (!_tags) {
        _tags = [NSMutableArray array];
    }
    return _tags;
}

/**
 *  将tag写入plist文件中
 */
- (BOOL)writeTagToFileWithTag:(NSString *)tag{
    NSString *path = tagsTool.tagDir;
    
    NSMutableArray *inputM = [NSMutableArray arrayWithContentsOfFile:path];
    [inputM insertObject:tag atIndex:inputM.count];
    return [inputM writeToFile:path atomically:YES];
}
@end
