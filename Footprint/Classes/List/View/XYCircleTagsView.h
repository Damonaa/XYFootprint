//
//  XYCircleTagsView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/18.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYCircleTagsView, XYTagView;

@protocol XYCircleTagsViewDelegate <NSObject>

- (void)circleTagsView:(XYCircleTagsView *)circleTagsView didTapTagView:(XYTagView *)tagView;
- (void)circleTagsView:(XYCircleTagsView *)circleTagsView didLongPressTagView:(XYTagView *)tagView;
@end

@interface XYCircleTagsView : UIView
/**
 *  存放全部的标签视图
 */
@property (nonatomic, strong) NSMutableArray *tagViews;

@property (nonatomic, weak) id<XYCircleTagsViewDelegate> delegate;


/**
 *  全部数据成员由 XYSingleTag组成
 */
@property (nonatomic, strong) NSMutableArray *allTagsEvents;
@end
