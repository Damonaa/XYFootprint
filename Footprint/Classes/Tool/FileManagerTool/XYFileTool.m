//
//  XYFileTool.m
//  Footprint
//
//  Created by 李小亚 on 16/4/14.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYFileTool.h"

@implementation XYFileTool

static XYFileTool *fileTool;

+ (instancetype)sharedFileTool{
    if (!fileTool) {
        fileTool = [[self alloc] init];
    }
    return fileTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileTool = [super allocWithZone:zone];
        
        fileTool.imagesPath = [NSString cacheFileWithName:@"images"];
        fileTool.audiosPath = [NSString cacheFileWithName:@"audios"];
        
    });
    
    return fileTool;
}

- (void)removeImageWithName:(NSString *)name{
    NSString *imagePath = [fileTool.imagesPath stringByAppendingPathComponent:name];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error];
    if (error) {
        XYLog(@"%@", error);
    }else{
        XYLog(@"remove image success");
    }
}

- (void)removeAudioWithName:(NSString *)name{
    NSString *imagePath = [fileTool.audiosPath stringByAppendingPathComponent:name];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error];
    if (error) {
        XYLog(@"%@", error);
    }else{
        XYLog(@"remove audio success");
    }
}

//取消通知
- (void)cancelLocalNotiWithKey:(NSString *)notiKey{
    for (UILocalNotification *localNoti in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([localNoti.userInfo[@"key"] isEqualToString:notiKey]) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNoti];
        }
    }
}
@end
