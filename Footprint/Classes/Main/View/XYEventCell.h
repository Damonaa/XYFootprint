//
//  XYEventCell.h
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYEventFrame, XYEventCell;


@protocol XYEventCellDelegate <NSObject>

@optional
//点击播放按钮，播放音频
- (void)eventCell:(XYEventCell *)eventCell didClickPlayButtonAtIndex:(NSInteger)index;
//左右滑动cell
- (void)eventCell:(XYEventCell *)eventCell slideToRightDoneWithIndex:(NSInteger)index;
- (void)eventCell:(XYEventCell *)eventCell slideToLeftDeleteWithIndex:(NSInteger)index;

@end


@interface XYEventCell : UITableViewCell
/**
 *  视图模型
 */
@property (nonatomic, strong) XYEventFrame *eventFrame;


@property (nonatomic, weak) id<XYEventCellDelegate> cellDelegate;

/**
 *  创建自定义的cell
 */
+ (instancetype)eventCellWithTableView:(UITableView *)tableView;

@end
