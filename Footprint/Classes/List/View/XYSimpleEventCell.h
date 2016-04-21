//
//  XYSimpleEventCell.h
//  Footprint
//
//  Created by 李小亚 on 16/4/19.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYEvent, XYSimpleEventCell;

@protocol XYSimpleEventCellDelegate <NSObject>

- (void)simpleEventCell:(XYSimpleEventCell *)simpleEventCell didTapCompletedImageView:(UIImageView *)completedImageView;

@end

@interface XYSimpleEventCell : UITableViewCell

@property (nonatomic, strong) XYEvent *event;

@property (nonatomic, weak) id<XYSimpleEventCellDelegate> delegate;

/**
 *  创建自定义的cell
 */
+ (instancetype)simpleEventCellWithTableView:(UITableView *)tableView;

@end
