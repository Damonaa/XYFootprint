//
//  XYEventDetailView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/7.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYEvent;

@protocol XYEventDetailViewDelegate <NSObject>

- (void)eventDetailViewDidClickButton:(UIButton *)button;
/**
 *  点击播放按钮
 */
- (void)eventDetailViewDidClickPlayerButton;
/**
 *  滑动删除播放器
 */
- (void)eventDetailViewDidSwipePlayerButton;


@end

@interface XYEventDetailView : UIView


@property (nonatomic, weak) id<XYEventDetailViewDelegate> delegate;


@property (nonatomic, strong) XYEvent *event;

/**
 *  设定的提醒时间
 */
@property (nonatomic, copy) NSString *remindDateStr;

@end
