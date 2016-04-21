//
//  XYFileTool.h
//  Footprint
//
//  Created by 李小亚 on 16/4/14.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYFileTool : NSObject

/**
 *  保存图片的路径
 */
@property (nonatomic, copy) NSString *imagesPath;
/**
 *  保存音频的路径
 */
@property (nonatomic, copy) NSString *audiosPath;

//@property (nonatomic, copy) NSString *tagsPath;

/**
 *  创建管理文件的单例
 */
+ (instancetype)sharedFileTool;

/**
 *  移除音频文件
 *
 *  @param name 音频文件名
 */
- (void)removeAudioWithName:(NSString *)name;
/**
 *  移除图片文件
 *
 *  @param name 图片文件名
 */
- (void)removeImageWithName:(NSString *)name;
/**
 *  取消 通知
 *
 *  @param notiKey 通知的可以
 */
- (void)cancelLocalNotiWithKey:(NSString *)notiKey;
@end
