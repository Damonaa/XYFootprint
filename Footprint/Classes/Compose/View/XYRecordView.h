//
//  XYRecordView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/10.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYWaveView;

@protocol XYRecordViewDelegate <NSObject>

- (void)recordViewDidFinishRecord;

@end

@interface XYRecordView : UIView

@property (nonatomic, weak) id<XYRecordViewDelegate> delegate;

/**
 *  波浪线视图
 */
@property (nonatomic, weak) XYWaveView *waveView;

/**
 *  显示录音时长的label
 */
@property (nonatomic, weak) UILabel *durationLabel;
@end
