//
//  XYTagsView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/11.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYEvent;

typedef void(^TagBlock)(NSString *tag);

@protocol XYTagsViewDelegate <NSObject>
/**
 *  已经选中标签
 */
- (void)tagsViewDidChooseTag;
/**
 *  添加新标签
 */
- (void)tagsViewAddNewTag;

@end

@interface XYTagsView : UIView

/**
 *  选中标签的block
 */
@property (nonatomic, copy) TagBlock tagStr;

@property (nonatomic, strong) XYEvent *event;

@property (nonatomic, weak) id<XYTagsViewDelegate> delegate;

/**
 *  返回按钮
 */
@property (nonatomic, weak) UIButton *backBtn;

/**
 *  隐藏标签视图
 */
- (void)hiddenTagsView;


+ (instancetype)show;
@end
