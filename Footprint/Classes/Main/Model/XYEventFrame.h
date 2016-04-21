//
//  XYEventFrame.h
//  Footprint
//
//  Created by 李小亚 on 16/4/14.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XYEvent;

@interface XYEventFrame : NSObject
/**
 *  事件模型
 */
@property (nonatomic, strong) XYEvent *event;

/**
 * 显示提醒时间的frame， 若有时间，则优先显示时间；若无时间，则显示地址
 */
@property (nonatomic, assign) CGRect remindFrame;
/**
 *  显示事件标签的frame
 */
@property (nonatomic, assign) CGRect tagFrame;

/**
 * 显示天气的frame
 */
@property (nonatomic, assign) CGRect weatherFrame;

/**
 * 显示文本的frame
 */
@property (nonatomic, assign) CGRect textFrame;
/**
 * 显示图片的frame
 */
@property (nonatomic, assign) CGRect picturesFrame;
/**
 * 显示音频的frame
 */
@property (nonatomic, assign) CGRect audioFrame;
/**
 * 显示下一次重复提醒的frame
 */
@property (nonatomic, assign) CGRect nextRepeatFrame;
/**
 * 显示地址的frame
 */
@property (nonatomic, assign) CGRect addressFrame;


/**
 *  行高
 */
@property (nonatomic, assign) float rowHeight;


@end
