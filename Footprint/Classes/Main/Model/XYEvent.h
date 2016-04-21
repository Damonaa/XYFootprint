//
//  XYEvent.h
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

typedef enum{
    RepeatFrequenceNever,
    RepeatFrequenceDay,
    RepeatFrequenceMonToFir,
    RepeatFrequenceWeek,
    RepeatFrequenceMonth,
    RepeatFrequenceYear
}RepeatFrequence;


#import <Foundation/Foundation.h>

@class XYRecord;

@interface XYEvent : NSObject

/**
 *  文本
 */
@property (nonatomic, copy) NSString *text;
/**
 *  提醒日期
 */
@property (nonatomic, copy) NSString *remindDate;
/**
 *  提醒地点
 */
@property (nonatomic, copy) NSString *remindLoc;
/**
 *  提醒区域
 */
@property (nonatomic, strong) CLRegion *region;

/**
 *  重复频率
 */
@property (nonatomic, assign) RepeatFrequence frequency;
/**
 *  是否显示频率选项， 默认为NO
 */
@property (nonatomic, assign, getter=isShowOptions) BOOL showOptions;
/**
 *  图片信息(存放图片名称)
 */
@property (nonatomic, strong) NSMutableArray *images;
/**
 *  音频路径
 */
//@property (nonatomic, copy) XYRecord *record;
/**
 *  音频路径
 */
//@property (nonatomic, copy) NSString *audioPath;
@property (nonatomic, copy) NSString *audioName;
/**
 *  音频的长度，已经转换为00：00格式
 */
@property (nonatomic, assign) double audioDuration;

/**
 *  通知的key
 */
@property (nonatomic, copy) NSString *notiKey;

/**
 *  事件类别
 */
@property (nonatomic, copy) NSString *tag;

/**
 *  是否有天气预报， 默认NO
 */
@property (nonatomic, assign, getter=isHasWeather) BOOL hasWeather;
/**
 *  天气情况
 */
@property (nonatomic, copy) NSString *weather;
/**
 *  完成事件，不再重复，但不删除
 */
@property (nonatomic, assign, getter=isCompleteEvent) BOOL completeEvent;

/**
 *  是否禁用tag按钮的点击，默认是NO，允许操作
 */
@property (nonatomic, assign, getter=isDisableChangeTag) BOOL disableChangeTag;


@end
